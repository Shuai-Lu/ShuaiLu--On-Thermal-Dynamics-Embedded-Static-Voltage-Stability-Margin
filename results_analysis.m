clc; clear all; close all;
%% results analysis
index_lambda_E = [13 16 44 51];
index_lambda_H = 32;
baseMVA = 100;

for dhs_control_mode = 1 : 4
    filename = ['record_24_' num2str(dhs_control_mode) '.mat'];
    data = load(filename);
    record = data.record;

    for k = 1 : size(record, 2) - 1
        if isempty(record(k).lambda_e) || isempty(record(k).lambda_h)
            lambda(dhs_control_mode).e(k,1) = inf;
            lambda(dhs_control_mode).h(k,1) = inf;
        else
            lambda(dhs_control_mode).e(k,1) = record(k).lambda_e;
            lambda(dhs_control_mode).h(k,1) = record(k).lambda_h;
        end
    end

    
    Voltage(dhs_control_mode).V = ...
        record(index_lambda_H).results.ies_vsm.var.eps.U;

    Branch(dhs_control_mode).P  = ...
        baseMVA * record(index_lambda_H).results.ies_vsm.var.eps.P_branch;

    Branch(dhs_control_mode).Q  = ...
        baseMVA * record(index_lambda_H).results.ies_vsm.var.eps.Q_branch;

    Branch(dhs_control_mode).S  = ...
        3 * sqrt(Branch(dhs_control_mode).P .^2 /9 + ...
        Branch(dhs_control_mode).Q .^2 /9);

    Branch(dhs_control_mode).S_limit = ...
        baseMVA * ...
        3 * sqrt(record(index_lambda_H).results.ies_vsm.var.eps.S_branch_limit_square/3);

     Gen(dhs_control_mode).P  = ...
        record(index_lambda_H).results.ies_vsm.var.eps.P_gen;
     Gen(dhs_control_mode).Q  = ...
        record(index_lambda_H).results.ies_vsm.var.eps.Q_gen;
     Gen(dhs_control_mode).H  = ...
        record(index_lambda_H).results.ies_vsm.var.eps.H_gen;

    myload(dhs_control_mode).E = - baseMVA * ...
        sum(record(index_lambda_H).results.ies_vsm.var.eps.P(:, [5 7 9]), 2);

    myload(dhs_control_mode).H = sum(record(index_lambda_H).results.ies_vsm.var.dhn.h_source(11:end, :), 2);

    myload(dhs_control_mode).E_COP = - baseMVA * ...
        sum(record(index_lambda_H).results.oef.var.eps.P(:, [5 7 9]), 2);

    myload(dhs_control_mode).H_COP = sum(record(index_lambda_H).results.oef.var.dhn.h_source(11:end, :), 2);

end

%% plot Pareto 
h_fig = figure();
h_axis = gca;
% % set position & color
% position, color,
left = 10; bottom = 10; width = 20; height = 8;
% units:inches|centimeters|normalized|points|{pixels}|characters
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
% % Remove the blank edge
set(gca,'LooseInset',get(gca,'TightInset'));

% % Setting color
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% %
linestyle = {'-' '--' '-.' ':'};
for k = 1 : length(lambda)
    plot(lambda(k).h(:,1), lambda(k).e(:,1), 'LineWidth', 3, 'LineStyle', linestyle{k});
    hold on;
end

for k = 1: length(lambda)
    plot(lambda(k).h(index_lambda_H,1), lambda(k).e(index_lambda_H,1), '.', ...
        'Color', [0 0 0], 'MarkerSize', 15);
    hold on;
end

plot([1.5 1.5], [0 1.48], 'LineWidth', 0.5, 'Color', [0 0 0], 'LineStyle', '--');
hold on;

% Create textbox
annotation(h_fig,'textbox',...
    [0.433 0.307 0.077 0.111],...
    'String','$\it{A}_{\rm 1}$',...
    'Interpreter','latex',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(h_fig,'textbox',...
    [0.489 0.423 0.077 0.111],...
    'String','$\it{A}_{\rm 2}$',...
    'Interpreter','latex',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(h_fig,'textbox',...
    [0.431 0.507 0.077 0.111],...
    'String','$\it{A}_{\rm 3}$',...
    'Interpreter','latex',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(h_fig,'textbox',...
    [0.490 0.627 0.0772 0.111],...
    'String','$\it{A}_{\rm 4}$',...
    'Interpreter','latex',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

grid on;
axis([0 3.5 1.25 1.6]);
xlabel('\lambda_H');
ylabel('\lambda_E');
legend({'S1: Without thermal inertia', ...
    'S2: With thermal inertia of DHN', ...
    'S3: With thermal inertia of buildings', ...
    'S4: With both thermal inertia'}, ...
    'Orientation', 'Horizontal', ...
    'NumColumns',2, ...
    'FontSize', 14, 'FontName', 'Times New Roman');
legend boxoff;
% title('Pareto frontier');

set(h_axis, 'FontName', 'Times New Roman', 'FontSize', 18);

%% plot feasible region of CHP 
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 10; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));

% % Setting color
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

markerstyle = ['o' 'd' 's' '^'];
markersize = 5 * [1 1 1 1];
for k = 1: length(lambda)
    plot(Gen(k).H(:,3), Gen(k).P(:,3), markerstyle(k), 'MarkerSize', markersize(k), 'LineWidth', 1);
    hold on;
end

plot([0 160 80 0 0], [270 180 60 100 270], 'LineWidth', 1, 'Color', [0 0 0], 'LineStyle', '-');
hold on;

grid on;
axis([0 180 50 310]);
xlabel('$ \it H \rm (MW)$', 'Interpreter','latex');
ylabel('$\it P \rm (MW)$', 'Interpreter','latex');
legend({'$\it A_{\rm 1}$', ...
    '$\it A_{\rm 2}$', ...
    '$\it A_{\rm 3}$', ...
    '$\it A_{\rm 4}$'}, ...
    'Orientation', 'Horizontal', ...
    'NumColumns',4, ...
    'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter','latex');
legend boxoff;
% title('Pareto frontier');

set(h_axis, 'FontName', 'Times New Roman', 'FontSize', 16);






%% plot load E
% h_fig = figure();
% h_axis = gca;
% left = 10; bottom = 10; width = 20; height = 8;
% set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
% set(gca,'LooseInset',get(gca,'TightInset'));
% cmap = brewermap(4, 'RdBu');
% h_fig.Colormap = cmap;
% h_axis.Colormap = cmap;
% colororder(cmap);
% 
% % % 
% for k = 1 : 4
%     plot(myload(k).E, 'LineWidth', 2);
%     hold on;
% end
% grid on;
% title('Electrical load');
% 
%% plot load H
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 10; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% % 
linestyle = {'-' '--' '-.' ':'};
for k = 1 : 4
    plot(myload(k).H, 'LineWidth', 2, 'LineStyle', linestyle{k});
    hold on;
end
grid on;
axis([0 25 100 220]);
xticks([0 6 12 18 24])
xticklabels({'00:00' '06:00' '12:00' '18:00' '24:00'});
yticks(100:25:200);
xlabel('Time', 'Interpreter','latex');
ylabel('Heat load \rm (MW)', 'Interpreter','latex');
legend({'S1', 'S2', 'S3', 'S4'}, ...
    'Orientation', 'Horizontal', ...
    'NumColumns', 4, ...
    'FontSize', 13, 'FontName', 'Times New Roman', 'Location', 'best');
legend boxoff;
% title('Pareto frontier');

set(h_axis, 'FontName', 'Times New Roman', 'FontSize', 16);

%% plot Voltage
% h_fig = figure();
% h_axis = gca;
% left = 10; bottom = 10; width = 20; height = 8;
% set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
% set(gca,'LooseInset',get(gca,'TightInset'));
% cmap = brewermap(4, 'RdBu');
% h_fig.Colormap = cmap;
% h_axis.Colormap = cmap;
% colororder(cmap);

% % 
% for k = 1 : 4
%     plot(Voltage(k).V(:, :), 'LineWidth', 2);
%     hold on;
% end
% grid on;
% title('Voltage');

%% plot branch power
% h_fig = figure();
% h_axis = gca;
% left = 10; bottom = 10; width = 20; height = 8;
% set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
% set(gca,'LooseInset',get(gca,'TightInset'));
% cmap = brewermap(4, 'RdBu');
% h_fig.Colormap = cmap;
% h_axis.Colormap = cmap;
% colororder(cmap);
% 
% % % 
% for k = 1 : 4
%     plot(Branch(k).S(:,:), 'LineWidth', 2);
%     hold on;
%     plot(Branch(k).S_limit, 'LineWidth', 1);
% end
% grid on;
% title('Apparent power of branch');

%% plot gen P
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 10; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));
cmap = brewermap(4, 'RdBu');
% camp(3,:) = [0.47,0.67,0.19];
temp = cmap([1 3 4], :);
cmap(1:3, :) = temp;
cmap(4:6, :) = temp;
cmap(7:9, :) = temp;
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% % 
linestyle = {'-' '--' '-.' ':'};
num_line = 0;
for k = 1 : 4
    for kg = 1 : 3
        num_line = num_line + 1;
        h_line(num_line, 1) = plot(Gen(k).P(:,kg), 'LineWidth', 1, 'LineStyle', linestyle{k});
        hold on;
    end
end
h_line(num_line+1, 1) = plot(1:24, zeros(1,24), 'LineWidth', 1, 'LineStyle', linestyle{1});

plot([1 24], [250 250], 'LineWidth', 0.5, 'Color', [0 0 0], 'LineStyle', '--');
hold on;
plot([1 24], [298 298], 'LineWidth', 0.5, 'Color', [0 0 0], 'LineStyle', '--');
hold on;
% plot([1 24], [270 270], 'LineWidth', 0.5, 'Color', [0 0 0], 'LineStyle', '--');
% hold on;
grid on;

axis([0 25 100 349]);
xticks([0 6 12 18 24])
xticklabels({'00:00' '06:00' '12:00' '18:00' '24:00'});
yticks(100:50:300);
xlabel('Time', 'Interpreter','latex');
ylabel('$\it P $ of units \rm (MW)', 'Interpreter','latex');
legend([h_line(1:3:11); h_line(13); h_line(2:3)], {'S1', 'S2', 'S3', 'S4', 'G1', 'G2', 'G3'}, ...
    'Orientation', 'Horizontal', ...
    'NumColumns', 4, ...
    'FontSize', 13, 'FontName', 'Times New Roman', 'Location', 'best');
legend boxoff;

% Create textbox
annotation(h_fig,'textbox',...
    [0.2 0.59 0.25 0.08],...
    'String','Limit of G1',...
    'FontSize',12,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(h_fig,'textbox',...
    [0.2 0.74 0.25 0.08],...
    'String','Limit of G2',...
    'FontSize',12,...
    'FontName','Times New Roman',...
    'FitBoxToText','off',...
    'EdgeColor','none');

set(h_axis, 'FontName', 'Times New Roman', 'FontSize', 16);


% %% plot gen Q
% h_fig = figure();
% h_axis = gca;
% left = 10; bottom = 10; width = 20; height = 8;
% set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
% set(gca,'LooseInset',get(gca,'TightInset'));
% cmap = brewermap(4, 'RdBu');
% h_fig.Colormap = cmap;
% h_axis.Colormap = cmap;
% colororder(cmap);
% 
% % % 
% for k = 1 : 4
%     plot(Gen(k).Q(:,:), 'LineWidth', 2);
%     hold on;
% end
% grid on;
% title('Reactive power of generator');