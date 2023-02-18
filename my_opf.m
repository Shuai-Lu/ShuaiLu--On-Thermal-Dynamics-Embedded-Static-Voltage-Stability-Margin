function my_opf()
% optimal power flow
%
%
% by Shuai Lu
% Southeast University
% shuai.lu.seu@outlook.com
% 2022-08-09

fprintf('%-40s\t\t', '- Optimal power flow');
t0 = clock;
global data model;

%%
num_period = data.settings.num_period;
num_bus = size(data.eps.bus, 1);
num_branch = size(data.eps.branch, 1);
num_gen = size(data.eps.gen, 1);
indexset_load = find(data.eps.bus(:,2) == 1);
indexset_gen = find(data.eps.bus(:,2) > 1);

%%
model.opf.obj = 0;
model.opf.var = [];
model.opf.cons = [];

%%
model.opf.var.P = sdpvar(num_period, num_bus, 'full');
model.opf.var.Q = sdpvar(num_period, num_bus, 'full');
model.opf.var.U = sdpvar(num_period, num_bus, 'full');
model.opf.var.theta = sdpvar(num_period, num_bus, 'full');
model.opf.var.P_gen = sdpvar(num_period, num_gen, 'full');
model.opf.var.Q_gen = sdpvar(num_period, num_gen, 'full');
model.opf.var.cost_gen = sdpvar(num_period, num_gen, 'full');

%%
basekV = data.eps.bus(1,10);
baseMVA = 100;
[Ybus, Yf, Yt] = makeYbus(baseMVA, data.eps.bus, data.eps.branch);
Ybus = full(Ybus);
Gbus = real(Ybus);
Bbus = imag(Ybus);
% Yf = full(Yf);
% Yt = full(Yt);


%% Network
% % power flow
for i = 1 : num_bus
    model.opf.cons = model.opf.cons + (( ...
        model.opf.var.P(:, i) == ...
        model.opf.var.U(:, i) .* ( ...
        model.opf.var.U(:, :) .* ...
        (cos(model.opf.var.theta(:,i) * ones(1, num_bus) - model.opf.var.theta(:,:))) * ...
        Gbus(:, i)  + ...
        model.opf.var.U(:, :) .* ...
        (sin(model.opf.var.theta(:,i) * ones(1, num_bus) - model.opf.var.theta(:,:))) * ...
        Bbus(:, i))) : ...
        'P balance at bus');

    model.opf.cons = model.opf.cons + (( ...
        model.opf.var.Q(:, i) == ...
        model.opf.var.U(:, i) .* ( ...
        model.opf.var.U(:, :) .* ...
        (sin(model.opf.var.theta(:,i) * ones(1, num_bus) - model.opf.var.theta(:,:))) * ...
        Gbus(:, i)  - ...
        model.opf.var.U(:, :) .* ...
        (cos(model.opf.var.theta(:,i) * ones(1, num_bus) - model.opf.var.theta(:,:))) * ...
        Bbus(:, i))) : ...
        'Q balance at bus');
end

% % bus voltage
model.opf.cons = model.opf.cons + (( ...
    0.9 <= model.opf.var.U <= 1.1) : 'Bus voltage');
model.opf.cons = model.opf.cons + (( ...
    model.opf.var.U(:,1) == 1.1) : 'Slack bus voltage');

% % bus phase
model.opf.cons = model.opf.cons + (( ...
    -pi/2 <= model.opf.var.theta <= pi/2) : 'Bus phase');
model.opf.cons = model.opf.cons + (( ...
    model.opf.var.theta(:,1) == 0) : 'Slack bus phase');

% % load bus
model.opf.cons = model.opf.cons + (( ...
    model.opf.var.P(:, indexset_load) * baseMVA == ...
    - data.profile.P_load(1:num_period, indexset_load)) : 'P at load bus');
model.opf.cons = model.opf.cons + (( ...
    model.opf.var.Q(:, indexset_load) * baseMVA == ...
    - data.profile.Q_load(1:num_period, indexset_load)) : 'Q at load bus');


% % gen bus
model.opf.cons = model.opf.cons + (( ...
    model.opf.var.P(:, indexset_gen) * baseMVA == ...
    model.opf.var.P_gen): 'P at gen bus');
model.opf.cons = model.opf.cons + (( ...
    model.opf.var.Q(:, indexset_gen) * baseMVA == ...
    model.opf.var.Q_gen): 'Q at gen bus');



%% Generator
model.opf.cons = model.opf.cons + (( ...
    ones(num_period, 1) * data.eps.gen(:,10)' <= ...
    model.opf.var.P_gen <= ...
    ones(num_period, 1) * data.eps.gen(:,9)') : 'P of gen');
model.opf.cons = model.opf.cons + (( ...
    ones(num_period, 1) * data.eps.gen(:,5)' <= ...
    model.opf.var.Q_gen <= ...
    ones(num_period, 1) * data.eps.gen(:,4)') : 'Q of gen');


%% Obj
model.opf.var.cost_gen(:, :) = ...
    ones(num_period, 1) * data.eps.gencost(:, 5)' .* ...
    model.opf.var.P_gen .^2 + ...
    ones(num_period, 1) * data.eps.gencost(:, 6)' .* ...
    model.opf.var.P_gen + ...
    ones(num_period, 1) * data.eps.gencost(:, 7)';

model.opf.obj = sum(model.opf.var.cost_gen(:));



%% initialize
assign(model.opf.var.U, ones(num_period, num_bus));

%% solve
model.opf.ops = sdpsettings('solver', 'ipopt', 'verbose', 2, 'usex0', 1);
model.opf.sol = optimize(model.opf.cons, model.opf.obj, model.opf.ops);

%% results
if ~ model.opf.sol.problem
    model.opf = myFun_GetValue(model.opf);
    fprintf('%s%.4f\n','Object: ', model.opf.obj);
    fprintf('%s%.4f%s\n','solvertime: ', model.opf.sol.solvertime,' s');
else
    fprintf('%s\n', model.opf.sol.info);
end


%%
t1 = clock;
fprintf('%10.2f%s\n', etime(t1,t0), 's');

end