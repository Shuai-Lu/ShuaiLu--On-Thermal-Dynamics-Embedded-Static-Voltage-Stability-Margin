function x = my_assign(varargin)
% **************************************************
% Assgin initial value
% Shuai Lu
% Southeast University, Nanjing, China
% shuai.lu.seu@outlook.com
% 19-Aug-2022
% **************************************************
if find(strcmp(varargin, 'DisplayTime'))
    DisplayTime = varargin{find(strcmp(varargin, 'DisplayTime'))+1};
else
    DisplayTime = 1;
end
if DisplayTime
    fprintf('%-40s\t\t','  -- Assign initial value');
    t0 = clock;
end

%%
global model record num_iter;
num_iter = varargin{1};
assign_value('model');

%% time
if DisplayTime
    t1 = clock;
    fprintf('%10.2f%s\n', etime(t1,t0), 's');
end

%% -------------------------- getVarName ---------------------------
    function assign_value(var_name)
%         global model record num_iter;
        % % cell
        if iscell(eval(var_name))
            for i = 1 : size(eval(var_name), 1)
                assign_value([var_name '{' num2str(i) '}']);
            end

        % % struct
        elseif isstruct(eval(var_name))
            for i = 1 : size(eval(var_name), 1)
                subfield = fieldnames(eval([var_name '(i)']));
                for num_subfield = 1:length(subfield)
                    assign_value([var_name '(' num2str(i) ')' '.' subfield{num_subfield}]);
                end
            end

        % % sdpvar or nsdpvar
        elseif isa(eval(var_name), 'sdpvar') || ...
                isa(eval(var_name), 'ndsdpvar')
            loc_str = find(var_name == '.');
            str = var_name(loc_str + 1 : end);
            assign(eval(var_name), ...
                eval(['record' '(' num2str(num_iter) ').results.' str]));
        else

        end
    end

end