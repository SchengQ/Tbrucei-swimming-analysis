function summary_data = reconstruct_summary_from_saved_files(ID, params, results_dir, grid)

    base = fullfile(results_dir, [char(ID), '_']);
    direction_file = fullfile(results_dir, [char(ID), '_direction.mat']);
    file_Xcm = [base, 'Xcm_rotated.mat'];
    file_OmegaT = [base, 'OmegaT_rotated.mat'];

    if ~isfile(file_Xcm) || ~isfile(file_OmegaT) || ~isfile(direction_file)
        error('Required files are missing. Cannot reconstruct summary for ID %s.', ID);
    end

    Xcm_data = load(file_Xcm, 'Xcm');
    OmegaT_data = load(file_OmegaT, 'OmegaT');
    direction_data = load(direction_file);

    Xcm = Xcm_data.Xcm;
    OmegaT = OmegaT_data.OmegaT;
    dir = getfield_safe(direction_data, 'dir', [NaN, NaN, NaN]);

    dt = grid.dt;
    Totreps = params.Nper * grid.Nt + 1;

    meanOmegaT3 = mean(OmegaT(3, :)) / (2 * pi);
    avg_z_velocity = (Xcm(3, end) - Xcm(3, 1)) / (Totreps * dt);

    summary_data = table(string(ID), params.f, -meanOmegaT3, avg_z_velocity, ...
        rad2deg(params.T1), params.O1, params.B1, ...
        dir(1), dir(2), dir(3), ...
        grid.Ns, grid.ds, params.epsilon / grid.ds, params.epsilon, ...
        'VariableNames', {'UniqueID', 'f', 'MeanOmegaT3', 'AvgZVelocity', ...
                          'T1', 'O1', 'B1', ...
                          'MovingDir_X', 'MovingDir_Y', 'MovingDir_Z', ...
                          'Grid_Ns', 'Grid_ds', ...
                          'Epsilon_Relative', 'Epsilon_Absolute'});

end

function val = getfield_safe(structure, fieldname, default)
    if isfield(structure, fieldname)
        val = structure.(fieldname);
    else
        val = default;
    end
end
