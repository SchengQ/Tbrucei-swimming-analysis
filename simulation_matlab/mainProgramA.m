function mainProgramA(ID, summary_excel_file)

    if iscell(ID)
        ID = string(ID{1});
    else
        ID = string(ID);
    end

    results_dir = './results/';
    if ~exist(results_dir, 'dir'); mkdir(results_dir); end

    table_file = 'params_table.mat';
    direction_file = fullfile(results_dir, [char(ID), '_direction.mat']);

    load(table_file, 'params_table');
    row_idx = find(string(params_table.UniqueID) == ID);

    if isempty(row_idx)
        error('ID %s was not found in params_table.', ID);
    end

    params = params_table.Params{row_idx};
    grid = params_table.Grid{row_idx};
    [~, Points, ~] = estimate_shape(grid, params);

    Totreps = params.Nper * grid.Nt + 1;

    FT = zeros(grid.Ns, 3, Totreps);
    OmegaT = zeros(3, Totreps);
    XlabT = zeros(grid.Ns, 3, Totreps);

    X0 = [0, 0, 0];
    R = eye(3);

    rotated = false;
    direction_struct = struct('dir', []);

    if isfile(direction_file)
        direction_struct = load(direction_file);
        if isfield(direction_struct, 'dir')
            rotated = true;
            fprintf('[%s] Loaded moving direction: %.4f %.4f %.4f\n', ...
                char(ID), direction_struct.dir(1), direction_struct.dir(2), direction_struct.dir(3));
        end
    end

    for j = 1:Totreps
        tin = (j - 1) * grid.dt;

        if mod(j, 100) == 0 || j == 1 || j == Totreps
            fprintf('[%s] Step %d / %d\n', char(ID), j, Totreps);
        end

        [Xp, Up] = get_shape_t_3D_xy_bodyaxis2(tin, grid, params, Points, ID);
        [XL, U0, Omega, F] = cons_solve(Xp, Up, X0, R, params.epsilon, params.mu);

        X0 = X0 + grid.dt * U0;
        OmegMat = [0, -Omega(3), Omega(2); ...
                   Omega(3), 0, -Omega(1); ...
                  -Omega(2), Omega(1), 0];
        R = expm(OmegMat * grid.dt) * R;

        FT(:, :, j) = F;
        OmegaT(:, j) = Omega;
        XlabT(:, :, j) = XL;
    end

    Xcm = squeeze(mean(XlabT));
    meanOmegaT3 = mean(OmegaT(3, :)) / (2 * pi);
    avg_z_velocity = (Xcm(3, end) - Xcm(3, 1)) / (Totreps * grid.dt);

    if ~rotated
        direction_struct.dir = Xcm(:, end)' - Xcm(:, 1)';
        save(direction_file, '-struct', 'direction_struct');
        fprintf('[%s] First pass completed. Moving direction saved.\n', char(ID));

        mainProgramA(ID, summary_excel_file);
        return;
    end

    base = fullfile(results_dir, [char(ID), '_']);
    save([base, 'XlabT_rotated.mat'], 'XlabT');
    save([base, 'Xcm_rotated.mat'], 'Xcm');
    save([base, 'OmegaT_rotated.mat'], 'OmegaT');
    save([base, 'FT_rotated.mat'], 'FT');

    summary_data = table(string(ID), params.f, -meanOmegaT3, avg_z_velocity, ...
        rad2deg(params.T1), params.O1, params.B1, ...
        direction_struct.dir(1), direction_struct.dir(2), direction_struct.dir(3), ...
        grid.Ns, grid.ds, params.epsilon / grid.ds, params.epsilon, ...
        'VariableNames', {'UniqueID', 'f', 'MeanOmegaT3', 'AvgZVelocity', ...
                          'T1', 'O1', 'B1', ...
                          'MovingDir_X', 'MovingDir_Y', 'MovingDir_Z', ...
                          'Grid_Ns', 'Grid_ds', ...
                          'Epsilon_Relative', 'Epsilon_Absolute'});

    append_summary_to_excel(summary_data, summary_excel_file);
    fprintf('[%s] Rotated output completed.\n', char(ID));

end
