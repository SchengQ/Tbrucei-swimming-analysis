function exists = is_summary_recorded(ID, excel_file)

    if ~isfile(excel_file)
        exists = false;
        return;
    end

    try
        T = readtable(excel_file);
        if ~ismember('UniqueID', T.Properties.VariableNames)
            exists = false;
            return;
        end
        exists = any(string(T.UniqueID) == string(ID));
    catch
        warning('Could not read summary file: %s', excel_file);
        exists = false;
    end

end
