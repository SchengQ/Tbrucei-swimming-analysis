function main()

    results_dir = './results/';
    summary_dir = './summary/';
    if ~exist(results_dir, 'dir'); mkdir(results_dir); end
    if ~exist(summary_dir, 'dir'); mkdir(summary_dir); end

    summary_excel_file = fullfile(summary_dir, 'summary.xlsx');
    excel_file = 'params_record.xlsx';
    table_file = 'params_table.mat';

    % Parameter scan settings
    f_values = [1.8, 7.2];
    A_azi_values = [1, 2, 3];
    A_rad_values = [1, 2, 3];
    theta_values = [0, pi/12, pi/6, pi/4, pi/3];
    combinations = [sqrt(1), sqrt(1)];  % Mo, Mr

    ds_values = [2*pi*0.4/5];
    epsilon_rel_values = [1.4];

    total = size(combinations, 1) * numel(A_azi_values) * numel(A_rad_values) * ...
        numel(theta_values) * numel(f_values) * numel(ds_values) * numel(epsilon_rel_values);
    idx = 0;

    for i = 1:size(combinations, 1)
        Mo = combinations(i, 1);
        Mr = combinations(i, 2);

        for A_azi = A_azi_values
        for A_rad = A_rad_values
        for theta = theta_values
        for f = f_values
        for ds = ds_values
        for epsilon_rel = epsilon_rel_values

            idx = idx + 1;
            fprintf('Parameter set %d / %d\n', idx, total);

            [params, grid, ~] = build_params_struct(Mo, Mr, A_azi, A_rad, theta, f, ds, epsilon_rel);
            [unique_id, is_new] = get_or_create_unique_id(params, grid, table_file);

            if is_new
                export_params_to_excel(params, grid, unique_id, excel_file);
            end

            rotated_file = fullfile(results_dir, [char(unique_id), '_XlabT_rotated.mat']);

            if isfile(rotated_file)
                if ~is_summary_recorded(unique_id, summary_excel_file)
                    summary_data = reconstruct_summary_from_saved_files(unique_id, params, results_dir, grid);
                    append_summary_to_excel(summary_data, summary_excel_file);
                    fprintf('[%s] Added missing summary record.\n', char(unique_id));
                else
                    fprintf('[%s] Rotated output and summary already exist. Skipping.\n', char(unique_id));
                end
            else
                mainProgramA(unique_id, summary_excel_file);
            end

        end
        end
        end
        end
        end
        end
    end

end

function [params, grid, Points] = build_params_struct(Mo, Mr, A_azi, A_rad, theta, f, ds, epsilon_rel)

    params.f = f;
    params.T1 = theta;
    params.O1 = A_azi * Mo;
    params.B1 = A_rad * Mr;

    % Cell-shape parameters
    params.L1 = 7; params.L2 = 3; params.L3 = 4; params.L4 = 2; params.L5 = 4;
    params.T2 = 0; params.T3 = 0; params.T4 = pi/12;
    params.D1 = 0.4; params.D2 = 0.825; params.D3 = 1.05;
    params.D4 = 1.35; params.D5 = 1.5; params.D6 = 0.4;
    params.Z0 = 16;

    % Beating amplitudes
    params.O2 = 0.8 * Mo; params.O3 = 0.53 * Mo; params.O4 = 0.18 * Mo;
    params.O5 = 0.0; params.O6 = 0.6 * Mo;

    params.B2 = 0.8 * Mr; params.B3 = 0.53 * Mr; params.B4 = 0.18 * Mr;
    params.B5 = 0.0; params.B6 = 0.6 * Mr;

    % Wave parameters
    params.k_b = 4*pi / (params.L1 + params.L2 + params.L3 + params.L4 + params.L5);
    params.k_o = params.k_b;
    params.ph_b = 0;
    params.ph_o = 3*pi/2;

    grid.ds = ds;
    [Np, Points, params] = estimate_shape(grid, params);
    grid.Ns = Np;

    % Time and fluid parameters
    params.Tper = 1;
    params.Nper = 3;
    grid.Nt = 100 * 2^(round(log2(grid.Ns - 1)) - 5);
    grid.dt = params.Tper / grid.Nt;

    params.mu = 1;
    params.epsilon = epsilon_rel * grid.ds;

end
