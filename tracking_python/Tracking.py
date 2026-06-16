import numpy as np
import os
import matplotlib.pyplot as plt
import cv2
import imutils
import multiprocessing as mp
import functools
import math

#-----------------------------------------------------------------------------------------------------------------------
# Input
p_lib = 'example calibration library'
p_video = 'example video'
p_center = '2D centers.txt'

Center_ignore = 10  # Pixel radius to ignore around the center when calculating correlation
scale = 6.1         # Number of pixels per 1 μm in x and y directions
R_max = 80          # Maximum radius for Ir calculation and correlation comparison
obj_z = 3561        # Microscope height during video recording
lib_start = 3475    # Starting height of the library
lower_limit = 0.9   # Correlation coefficient threshold for reliable results
interpolation_parameter = 5  # Percentile setting for correlation interpolation (5 → 95th percentile as minimum)
D = 0.500           # Library step height
Nm = 1.32           # Medium refractive index correction

#-----------------------------------------------------------------------------------------------------------------------
# Functions

def average_r(pic, x0, y0, z, r):
    xmin = int(x0 - r) - 1
    ymin = int(y0 - r) - 1
    xmax = int(x0 + r) + 1
    ymax = int(y0 + r) + 1
    Itot = 0
    i = 0
    for x in range(xmin, xmax+1):
        for y in range(ymin, ymax+1):
            r2 = (x-x0)**2+(y-y0)**2
            if r2 <= r**2:
                Itot = Itot + pic[z][x][y]
                i = i + 1
    In = Itot/i
    return In, Itot, i


def read_center(path):
    data = np.loadtxt(path)
    return data


def read_photo(path):
    image_filenames = [os.path.join(path, filename) for filename in sorted(os.listdir(path)) if filename.endswith(".tif")]
    images = []
    for filename in image_filenames:
        image = cv2.imread(filename, cv2.IMREAD_UNCHANGED)
        image = image.astype(np.float32)
        images.append(image)
    images = np.array(images)
    return images


def average_r1_to_r2_fast(pic, x0, y0, z, r1, r2):
    xmin = x0 - int(r1) - 1
    xmax = x0 + int(r1) + 1
    Itot = 0
    i = 0
    for x in range(xmin, xmax + 1):
        if (x-x0)**2 <= r1**2:
            ymax1 = y0 + int((r1**2 - (x-x0)**2)**0.5) + 1
            ymin2 = y0 - int((r1**2 - (x-x0)**2)**0.5) - 1
            if (x-x0)**2 >= r2**2:
                ymin1 = y0 + 0
                ymax2 = y0 - 0
            else:
                ymin1 = y0 + int((r2**2 - (x-x0)**2)**0.5)
                ymax2 = y0 - int((r2 ** 2 - (x-x0) ** 2) ** 0.5)
            for y in range(ymin1, ymax1+1):
                rt = (x - x0) ** 2 + (y - y0) ** 2
                if rt <= r1 ** 2 and rt > r2 ** 2:
                    Itot = Itot + pic[z][x][y]
                    i = i + 1
            if ymax2 == y0:
                for y in range(ymin2, ymax2):
                    rt = (x - x0) ** 2 + (y - y0) ** 2
                    if rt <= r1 ** 2 and rt > r2 ** 2:
                        Itot = Itot + pic[z][x][y]
                        i = i + 1
            else:
                for y in range(ymin2, ymax2 + 1):
                    rt = (x - x0) ** 2 + (y - y0) ** 2
                    if rt <= r1 ** 2 and rt > r2 ** 2:
                        Itot = Itot + pic[z][x][y]
                        i = i + 1
    In = Itot / i
    return In


def i_r(pic, center, r_max, z):
    x0 = int(center[z][1])
    y0 = int(center[z][0])
    rmax = int(min(x0, y0, pic.shape[1]-x0, pic.shape[2]-y0, r_max)-2)
    In = np.array([0 for i in range(rmax)])
    for i in range(rmax):
        if i == 0:
            In[i], a, b = average_r(pic, x0, y0, z, 0)
        else:
            In[i] = average_r1_to_r2_fast(pic, x0, y0, z, i, i - 1)
    return In


def read_photos(path):
    files = [file for file in sorted(os.listdir(path)) if not os.path.isdir(os.path.join(path, file))]
    num = len(files)
    im = cv2.imread(path + "/" + files[0], cv2.IMREAD_UNCHANGED)
    pic = np.ones((num, im.shape[0], im.shape[1]))  # (z,row,col)
    center = np.ones((num, 2))

    for num, file in enumerate(files):
        pic[num] = cv2.imread(path + "/" + file, cv2.IMREAD_UNCHANGED)

        gray_16m = (pic[num] / np.max(pic[num])) * 255
        gray_8 = np.array(gray_16m, dtype='uint8')

        blurred = cv2.GaussianBlur(gray_8, (5, 5), sigmaX=20, sigmaY=20, borderType=0)
        thresh = cv2.threshold(blurred, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]

        cnts = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        cnts = imutils.grab_contours(cnts)
        i = 0
        j = 0
        r = 1000
        for c in cnts:
            area = cv2.contourArea(c)
            length = cv2.arcLength(c, True)
            # Filter out small/noisy contours
            if area > 20 and length > 20:
                roundness = 4 * np.pi * area / length ** 2
                if abs(roundness - 1) < r:
                    r = abs(roundness - 1)
                    j = i
            i = i + 1

        M = cv2.moments(cnts[j])
        if M["m00"] != 0:
            cX = int(M["m10"] / M["m00"])
            cY = int(M["m01"] / M["m00"])
            center[num][0] = cX
            center[num][1] = cY

    return pic, center


def corrco1(ird, picB, centerB, rmax, j, output_prefix):
    w = np.array([0 for i in range(len(ird))], dtype=np.float64)
    irp = i_r(picB, centerB, rmax, j)
    print(j, '/', len(picB) - 1)
    for i in range(len(ird)):
        ir = min(len(irp), len(ird[i]))
        w[i] = np.corrcoef(irp[Center_ignore:ir], ird[i][Center_ignore:ir])[0][1]
    w_max = max(w)
    output_path = f"{output_prefix}_{j}.txt"
    with open(output_path, "w") as file:
        file.write(str(w[np.argmax(w)-1])+','+str(w_max)+','+str(w[np.argmax(w)+1])+','+str(j)+'\n')
    if w_max > lower_limit:
        zh = np.argmax(w)
    else:
        zh = -1
    return zh


def merge_results(file_prefix, num_files):
    with open("Three_correlations.txt", "w") as outfile:
        for i in range(num_files):
            temp_file_path = f"{file_prefix}_{i}.txt"
            with open(temp_file_path, "r") as infile:
                outfile.write(infile.read())
            os.remove(temp_file_path)  # Delete temporary file

#-----------------------------------------------------------------------------------------------------------------------
# Tracking
if __name__ == '__main__':
    file_prefix = "temp_output"

    lib, center_lib = read_photos(p_lib)
    video = read_photo(p_video)
    center_video = read_center(p_center)

    partial_i_r = functools.partial(i_r, lib, center_lib, R_max)
    with mp.Pool(6) as pool:
        IRD = pool.map(partial_i_r, [j for j in range(len(lib))])

    partial_corrco1 = functools.partial(corrco1, IRD, video, center_video, R_max, output_prefix=file_prefix)
    with mp.Pool(6) as pool:
        Z = pool.map(partial_corrco1, [j for j in range(len(video))])
    merge_results(file_prefix, len(video))

    Z = np.array(Z)
    Z_inter = Z * D
    # Convert to corrected Z using objective height and medium refractive index
    Z = (obj_z - (lib_start + Z * D)) * Nm

    tt = range(len(video))
    t = np.array(tt)

#-----------------------------------------------------------------------------------------------------------------------
# Load correlation file

    data_corr = np.loadtxt('Three_correlations.txt', delimiter=',')
    # Sort by the fourth column (index 3)
    sorted_indices = np.argsort(data_corr[:, 3])
    sorted_data = data_corr[sorted_indices]
    three_correlations = sorted_data[:, :3]

#-----------------------------------------------------------------------------------------------------------------------
# Fit interpolation function
    correlations = three_correlations[:, 1]
    max_cor = np.max(correlations)
    min_cor = np.percentile(correlations, interpolation_parameter)

    a = 4*(max_cor-min_cor)/D**2
    b = max_cor
    print(f"Interpolation function: correlation = -{a:.2f}*x^2+{b:.2f}")

#-----------------------------------------------------------------------------------------------------------------------
# Perform interpolation
    interpolation = []
    three_correlations = three_correlations.tolist()
    for row in three_correlations:
        max_num = max(row)
        second_max_num = max(num for num in row if num != max_num)
        if max_num >= lower_limit:
            if row.index(second_max_num) == 0:
                c = -math.sqrt((b - max_num) / a)
            elif row.index(second_max_num) == 2:
                c = math.sqrt((b - max_num) / a)
        else:
            c = 0
        interpolation.append(c)

#-----------------------------------------------------------------------------------------------------------------------
# Calculate new coordinates
    Z_new = Z_inter + interpolation
    Z_new = (obj_z - (lib_start + Z_new)) * Nm

    X = center_video[:, 0] / scale
    Y = center_video[:, 1] / scale

    plt.plot(t, Z_new, color='red', label='After interpolation')
    plt.xlabel("Time (frame)")
    plt.ylabel("Z (um)")
    plt.show()

    fig = plt.figure()
    ax1 = plt.axes(projection='3d')
    ax1.plot3D(X, Y, Z_new, 'gray')
    ax1.set_xlabel("X (um)")
    ax1.set_ylabel("Y (um)")
    ax1.set_zlabel("Z (um)")
    plt.show()

    f = open('XYZ Trajectory.txt', 'w')
    for i in range(len(Z_new)):
        f.write((str(X[i]) + ' , ' + str(Y[i]) + ' , ' + str(Z_new[i])) + '\n')
    f.close()
