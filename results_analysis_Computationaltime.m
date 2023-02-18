clc; clear all; close all;
%% results analysis
for dhs_control_mode = 1 : 4
    filename = ['record_24_' num2str(dhs_control_mode) '.mat'];
    data = load(filename);
    record = data.record;
    for k = 2 : size(record, 2)-1
        solvertime(dhs_control_mode).results(k-1, 1) = ...
            record(k).results.ies_vsm.sol.solvertime;
    end

    min(solvertime(dhs_control_mode).results)
    max(solvertime(dhs_control_mode).results)
    mean(solvertime(dhs_control_mode).results)
end
