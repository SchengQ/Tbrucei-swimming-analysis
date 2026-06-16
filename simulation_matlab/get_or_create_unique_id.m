function [unique_id, is_new] = get_or_create_unique_id(params, grid, table_filename)

    success = false;
    retryCount = 0;
    maxRetries = 3;

    while ~success && retryCount < maxRetries
        try
            if isfile(table_filename)
                load(table_filename, 'params_table');
            else
                params_table = table([], [], [], 'VariableNames', {'Params', 'Grid', 'UniqueID'});
            end
            success = true;
        catch
            retryCount = retryCount + 1;
            pause(1);
        end
    end

    if ~success
        error('Could not load or create parameter table: %s', table_filename);
    end

    row_idx = find(arrayfun(@(i) isequal(params_table.Params{i}, params) && ...
                                     isequal(params_table.Grid{i}, grid), ...
                                     1:height(params_table)));

    if isempty(row_idx)
        unique_id = matlab.lang.makeUniqueStrings(string(randi(1e6)), string(params_table.UniqueID));
        new_entry = table({params}, {grid}, {unique_id}, ...
                          'VariableNames', {'Params', 'Grid', 'UniqueID'});
        params_table = [params_table; new_entry];
        save(table_filename, 'params_table');
        is_new = true;
    else
        unique_id = params_table.UniqueID{row_idx};
        is_new = false;
    end

end
