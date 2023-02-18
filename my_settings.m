function my_settings()
fprintf('%-40s\t\t', '- Set Options');
t0 = clock;
global data;

%% 
data.settings.num_period = 24;
data.settings.time_interval = 1;
data.settings.time_interval_heat = 1;
data.settings.num_initialtime_dhn = 10;
data.settings.big_M = 1e4;
data.settings.baseMVA = 100;
data.settings.T_source_set = 90;


%%
t1 = clock;
fprintf('%10.2f%s\n', etime(t1,t0), 's');

end