function T = flatten_struct(s, prefix)

    fields = fieldnames(s);
    data = cell(1, numel(fields));
    names = cell(1, numel(fields));

    for i = 1:numel(fields)
        val = s.(fields{i});
        if isnumeric(val) && isscalar(val)
            data{i} = val;
        else
            data{i} = NaN;
        end
        names{i} = [prefix '_' fields{i}];
    end

    T = cell2table(data, 'VariableNames', names);

end
