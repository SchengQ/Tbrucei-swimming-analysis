# 3D tracking code

This folder contains the Python tracking script and representative example image files used to reconstruct 3D trajectories from microscopy image sequences.

## Folder structure

```text
tracking_python/
├── Tracking.py
├── requirements.txt
├── 2D centers.txt
├── example video/
│   ├── frame_0001.tif
│   ├── frame_0002.tif
│   └── ...
└── example calibration library/
    ├── image_0001.tif
    ├── image_0002.tif
    └── ...
```

## Tested environment

The Python tracking code was tested with Python 3.7.9 on Windows. Other Python 3 versions may also work but were not specifically tested. Required packages are listed in `requirements.txt`.

The tested package versions included:

* `numpy==1.21.6`
* `matplotlib==3.5.3`
* `opencv-python==4.13.0.92`
* `imutils==0.5.4`

## Input files

* `Tracking.py`: main Python script for 3D trajectory reconstruction.
* `2D centers.txt`: 2D center coordinates of the tracked object in each video frame.
* `example video/`: representative microscopy image sequence to be tracked.
* `example calibration library/`: calibration image library acquired at known microscope heights.

The folder names are used directly in `Tracking.py`. If the folder or file names are changed, please update the input paths at the beginning of the script.

## Running the example

Run the tracking script from this folder:

```bash
python Tracking.py
```

The script reads the calibration library and video frames, calculates radial intensity profiles, compares the video frames with the calibration library using correlation analysis, and reconstructs the 3D trajectory.

>[!IMPORTANT]
>The script displays the Z-position plot and 3D trajectory plot during execution. Please close each plot window to allow the script to continue and finish writing the output files.

## Output files

The script generates:

* `Three_correlations.txt`: correlation values around the best-matched calibration plane for each frame.
* `XYZ Trajectory.txt`: reconstructed 3D trajectory coordinates.

The script also displays plots of the Z position and the 3D trajectory.

## Notes

The example image folders are provided as representative input files for demonstrating the tracking workflow. The numerical parameters, including pixel size, library step height, objective height, and refractive-index correction, are defined near the beginning of `Tracking.py` and can be adjusted for other datasets.

