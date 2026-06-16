function Xp = get_shape_t_3D_xy_bodyaxis_new(tin, grid, params, Points, unique_id)

results_dir = './results/';

Np = grid.Ns;
Xo = zeros(1, Np);
Yo = zeros(1, Np);
Zo = zeros(1, Np);
XO = zeros(1, Np);
YO = zeros(1, Np);
ZO = zeros(1, Np);
Xp = zeros(Np, 3);
vector = zeros(3, Np);
tangent_vector = zeros(3, Np);
beating_direction = zeros(3, Np);
norm_dir = zeros(1, Np);
unit_dir = zeros(3, Np);

f = params.f;
k_o = params.k_o;
k_b = params.k_b;
ph_o = params.ph_o;
ph_b = params.ph_b;

Nl1 = params.Nl1;
Nl2 = params.Nl2;
Nl3 = params.Nl3;
Nl4 = params.Nl4;
Nl5 = params.Nl5;

node = [Nl1, Nl2, Nl3, Nl4, Nl5];
nodex = [0, params.x1, params.x2, params.x3, params.x4, params.x5];
nodez = [0, params.z1, params.z2, params.z3, params.z4, params.z5];
cumnode = cumsum(node);

all_layers = [Points.NL];
[~, ~, layer_idx] = unique(all_layers);
N_layers = max(layer_idx);

Xc_layer = zeros(1, N_layers);
Zc_layer = zeros(1, N_layers);
s_layer = zeros(1, N_layers);

for j = 1:N_layers
    idx = find(layer_idx == j, 1);
    Xc_layer(j) = Points(idx).Xc;
    Zc_layer(j) = Points(idx).Zc;
end

for j = 2:N_layers
    dx = Xc_layer(j) - Xc_layer(j - 1);
    dz = Zc_layer(j) - Zc_layer(j - 1);
    s_layer(j) = s_layer(j - 1) + sqrt(dx^2 + dz^2);
end

s = s_layer(layer_idx);

for i = 1:Np
    Xo(i) = Points(i).Xc;
    Yo(i) = 0;
    Zo(i) = Points(i).Zc;

    index = find(cumnode >= Points(i).NL, 1);
    vector(:, i) = [nodex(index) - nodex(index + 1); 0; nodez(index) - nodez(index + 1)];
    axis_rc = vector(:, i);
    tangent_vector(:, i) = [0; 1; 0];
    beating_direction(:, i) = cross(tangent_vector(:, i), vector(:, i));
    norm_dir(i) = norm(beating_direction(:, i));
    unit_dir(:, i) = beating_direction(:, i) / (norm_dir(i) + (norm_dir(i) == 0));

    wave_B = Points(i).B * sin(2*pi*f*tin - k_b * s(i) + ph_b);
    wave_O = Points(i).O * sin(2*pi*f*tin - k_o * s(i) + ph_o);

    XO(i) = Xo(i) + wave_B * unit_dir(1, i) + wave_O * tangent_vector(1, i);
    YO(i) = Yo(i) + wave_B * unit_dir(2, i) + wave_O * tangent_vector(2, i);
    ZO(i) = Zo(i) + wave_B * unit_dir(3, i) + wave_O * tangent_vector(3, i);

    xph = Points(i).Rc * cos(Points(i).Ph);
    yph = Points(i).Rc * sin(Points(i).Ph);
    zph = 0;

    norm_axis = axis_rc / norm(axis_rc);
    z_axis = [0; 0; 1];

    if abs(dot(z_axis, norm_axis) - 1) < 1e-6
        XYZ = [xph; yph; zph] + [XO(i); YO(i); ZO(i)];
    else
        axis_Rc = cross(z_axis, norm_axis);
        axis_Rc = axis_Rc / norm(axis_Rc);
        theta_Rc = acos(dot(z_axis, norm_axis));
        K = [0, -axis_Rc(3), axis_Rc(2); ...
             axis_Rc(3), 0, -axis_Rc(1); ...
            -axis_Rc(2), axis_Rc(1), 0];
        rotation_matrix = eye(3) + sin(theta_Rc) * K + (1 - cos(theta_Rc)) * (K * K);
        XYZ = rotation_matrix * [xph; yph; zph] + [XO(i); YO(i); ZO(i)];
    end

    Xp(i, :) = XYZ';
end

direction_file = fullfile(results_dir, [char(unique_id), '_direction.mat']);

if isfile(direction_file)
    success = false;
    retryCount = 0;
    maxRetries = 5;

    while ~success && retryCount < maxRetries
        try
            direction_data = load(direction_file);
            if isfield(direction_data, 'dir')
                dir = direction_data.dir;
                Xp = Rotate_to_z(Xp, dir(1), dir(2), dir(3), 0, 0, 0);
                success = true;
            else
                warning('Direction field was not found in %s.', direction_file);
                break;
            end
        catch ME
            retryCount = retryCount + 1;
            fprintf('Could not process direction file (%d/%d): %s\n', ...
                retryCount, maxRetries, ME.message);
            pause(5);
        end
    end

    if ~success
        warning('Could not process direction file after multiple attempts: %s.', direction_file);
    end
end

end
