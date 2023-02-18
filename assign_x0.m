function x = assign_x0(varargin)
% **************************************************
% Assgin initial value
% Shuai Lu
% Southeast University, Nanjing, China
% shuai.lu.seu@outlook.com
% 17-Aug-2022
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
global model;
assign_value(varargin{1});

%% time
if DisplayTime
    t1 = clock;
    fprintf('%10.2f%s\n', etime(t1,t0), 's');
end

%% -------------------------- getVarName ---------------------------
    function assign_value(var_name)
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
            assign(eval(var_name), value(eval(var_name)));
        else

        end
    end

end