function read_data(filename, flag_clear)
fprintf('%-40s\t\t', '- Reading data');
t0 = clock;
global data;

%% reading data ...
if ~flag_clear && exist([cd '\mydata.mat'], 'file')
    mydata = load('mydata.mat');
    data = mydata.data;
    clear mydata;
else
    % % test
    %  filename = 'testdata_6bus.xlsx';
    
    [sheet_bus, sheet_branch, sheet_gen, sheet_gencost, ...
        sheet_node, sheet_pipe, sheet_device, sheet_building, sheet_profile] = ...
        deal(1,2,3,4,5,6,7,8,9);
    data_bus = xlsread(filename,sheet_bus);
    data_branch = xlsread(filename,sheet_branch);
    data_gen = xlsread(filename,sheet_gen);
    data_gencost = xlsread(filename,sheet_gencost);
    data_node = xlsread(filename,sheet_node);
    data_pipe = xlsread(filename,sheet_pipe);
    data_device = xlsread(filename,sheet_device);
    data_building = xlsread(filename,sheet_building);
    data_profile = xlsread(filename,sheet_profile);
    
    %%
    data.eps.bus = data_bus;
    data.eps.branch = data_branch;
    data.eps.gen = data_gen;
    data.eps.gencost = data_gencost;
    
    for i = 1 : size(data_gen, 1)
        if data.eps.gen(i,24) == 2  % chp
            data.eps.gen_feasibleregion(i,1).a(1:2,1) = [1 -1]';
            data.eps.gen_feasibleregion(i,1).b(1:2,1) = ...
                - (data.eps.gen(i, [26 28]) - data.eps.gen(i, [28 30]))' ./ ...
                (data.eps.gen(i, [27 29]) - data.eps.gen(i, [29 31]))' .* ...
                data.eps.gen_feasibleregion(i,1).a;
            data.eps.gen_feasibleregion(i,1).c = ...
                (-data.eps.gen(i, [26 28]) .* data.eps.gen(i, [29 31]) + ...
                data.eps.gen(i, [28 30]) .* data.eps.gen(i, [27 29]))' ./ ...
                (data.eps.gen(i, [27 29]) - data.eps.gen(i, [29 31]))' .* ...
                data.eps.gen_feasibleregion(i,1).a;
            data.eps.gen_feasibleregion(i,1).Hmax = data.eps.gen(i, 29);
        elseif data.eps.gen(i,24) == 1
            data.eps.gen_feasibleregion(i,1).a = 0;
            data.eps.gen_feasibleregion(i,1).b = 0;
            data.eps.gen_feasibleregion(i,1).c = 0;
            data.eps.gen_feasibleregion(i,1).Hmax = 0;
        end
    end

    %%
    data.dhn.node = data_node;
    data.dhn.pipe = data_pipe;
    data.dhn.device = data_device;
    
    %%
    data.building.table = data_building;

    %% profile
    indexset_elecload = find(data_profile(:,2)== 1);
    indexset_resload = find(data_profile(:,2) == 2);
    indexset_Tout = find(data_profile(:,2) == 3);
    data.profile.bus_elecload = data_profile(indexset_elecload, 1);
    data.profile.bus_resload = data_profile(indexset_resload, 1);
    powerfactor = data_profile(indexset_elecload, 4);

    for i = 1 : size(indexset_elecload,1)
        data.profile.P_load(:,i) = data_profile(indexset_elecload(i,1), 3) * ...
            data_profile(indexset_elecload(i,1), 5:end)';
        data.profile.Q_load(:,i) = sqrt(1 - powerfactor(i,1).^2) / ...
            powerfactor(i,1) * ...
            data.profile.P_load(:,i);
    end
    for i = 1 : size(indexset_resload,1)
        data.profile.resload = data_profile(indexset_resload(i,1), 3) * ...
            data_profile(indexset_resload(i,1), 5:end)';
    end
    data.profile.Tout = data_profile(indexset_Tout, 3) * ...
        data_profile(indexset_Tout, 5:end)';

    
    %% loc
    %% dhn
    % pipe
    [data.loc.dhn.pipe.fnode, data.loc.dhn.pipe.tnode, data.loc.dhn.pipe.length, data.loc.dhn.pipe.diameter, ...
        data.loc.dhn.pipe.rough, data.loc.dhn.pipe.conductivity, data.loc.dhn.pipe.massflow, data.loc.dhn.pipe.Tamb, ...
        data.loc.dhn.pipe.Ts_initial, data.loc.dhn.pipe.Tr_initial, ...
        data.loc.dhn.pipe.Ts_min, data.loc.dhn.pipe.Ts_max, ...
        data.loc.dhn.pipe.min, data.loc.dhn.pipe.max] = ...
        deal(1,2,3,4,5,6,9,10,11,12,13,14,15,16);
    % node
    [data.loc.dhn.node.ID, data.loc.dhn.node.type, data.loc.dhn.node.sourceflow, data.loc.dhn.node.loadflow, ...
        data.loc.dhn.node.Ts_initial, data.loc.dhn.node.Tr_initial, ...
        data.loc.dhn.node.Ts_min, data.loc.dhn.node.Ts_max, ...
        data.loc.dhn.node.Tr_min, data.loc.dhn.node.Tr_max] = ...
        deal(1,2,3,4,5,6,7,8,9,10);
    % device
    [data.loc.dhn.device.nodeID, data.loc.dhn.device.type, data.loc.dhn.device.busID, ...
        data.loc.dhn.device.Pmin, data.loc.dhn.device.Pmax, data.loc.dhn.device.Hmin, data.loc.dhn.device.Hmax, ...
        data.loc.dhn.device.eta, data.loc.dhn.device.elecprice, data.loc.dhn.device.fuelprice, ...
        data.loc.dhn.device.om, data.loc.dhn.device.c0] = ...
        deal(1,2,3,4,5,6,7,8,9,10,11,12);
    %% building
    [data.loc.building.ID, data.loc.building.nodeID, ...
        data.loc.building.C, data.loc.building.R, data.loc.building.num, ...
        data.loc.building.Tin_min, data.loc.building.Tin_max, ...
        data.loc.building.Tin_initial, data.loc.building.Tin_opt] = ...
        deal(1,2,3,4,5,6,7,8,9);
        
    

    %%    
    if  exist([cd '\mydata.mat'], 'file')
        delete('mydata.mat');
    end
    save('mydata.mat', 'data', '-v7');
end

%%
t1 = clock;
fprintf('%10.2f%s\n', etime(t1,t0), 's');

end