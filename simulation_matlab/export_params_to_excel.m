function export_params_to_excel(params, grid, unique_id, excel_filename)

    flat_params = flatten_struct(params, 'params');
    flat_grid = flatten_struct(grid, 'grid');

    combined = [flat_params, flat_grid];
    combined.UniqueID = string(unique_id);

    if isfile(excel_filename)
        T_old = readtable(excel_filename);
        T_new = [T_old; combined];
    else
        T_new = combined;
    end

    writetable(T_new, excel_filename);

end
