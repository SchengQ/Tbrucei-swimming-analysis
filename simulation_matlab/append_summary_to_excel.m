function append_summary_to_excel(summary_data, excel_file)

    output_dir = fileparts(excel_file);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    if isfile(excel_file)
        T = readtable(excel_file);

        if ~isequal(T.Properties.VariableNames, summary_data.Properties.VariableNames)
            error('Existing summary file has incompatible columns: %s', excel_file);
        end

        new_id = string(summary_data.UniqueID(1));
        existing_ids = string(T.UniqueID);

        if ~any(existing_ids == new_id)
            T = [T; summary_data];
            writetable(T, excel_file, 'WriteMode', 'overwrite');
            fprintf('Added summary record to %s: ID = %s\n', excel_file, new_id);
        else
            fprintf('Summary record already exists: ID = %s\n', new_id);
        end
    else
        writetable(summary_data, excel_file);
        fprintf('Created summary file: %s\n', excel_file);
    end

end
