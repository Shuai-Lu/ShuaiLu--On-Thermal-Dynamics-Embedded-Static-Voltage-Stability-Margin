clc; clear all; close all;

global data model record;


for dhs_control_mode = 1 : 4
    yalmip('clear');
    data = [];
    model = [];
    record = [];
    %% read dat
    read_data('testdata_9bus.xlsx', 1); % 1: filename; 2: flag_clear
    data.dhn.pipe_0 = data.dhn.pipe;
    data.dhn.node_0 = data.dhn.node;

    %% settings
    my_settings();


    %% opf
    my_oef();
    record(1).results = model;
    fprintf('\n');

    %% voltage security margin

    %% dhs control strategy
    % % #   dhn temp    building temp
    % % 1   constant    constant
    % % 2   constant    variable
    % % 3   variable    constant
    % % 4   variable    variable


    %%
    for k = 1 : 1e4
        fprintf('%s\n', ['************** k = ' num2str(k) ' **************']);
        yalmip('clear');
        my_oef_vsm(dhs_control_mode, k);
        record(k+1).results = model;
        record(k+1).lambda_e = model.ies_vsm.var.lambda_e;
        record(k+1).lambda_h = model.ies_vsm.var.lambda_h;

        if ~ record(end).results.ies_vsm.sol.problem
            fprintf('%s%.4f%s%s%0.4f%s\n\n', ...
                'lambda_e = ', record(end).results.ies_vsm.var.lambda_e, '; ', ...
                'lambda_h = ', record(end).results.ies_vsm.var.lambda_h, '.');
        else
            break;
        end
    end

    filename = ['record_' num2str(data.settings.num_period) '_' num2str(dhs_control_mode) '.mat'];
    save(filename, 'record');

end
