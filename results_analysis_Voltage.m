clc; clear all; close all;
%% results analysis
index_lambda_E = [13 16 44 51];
baseMVA = 100;


for dhs_control_mode = 3 : 4
    filename = ['record_24_' num2str(dhs_control_mode) '.mat'];
    data = load(filename);
    record = data.record;
    num_fig = 0;
    close all;

    for index_lambda_H = 2 : size(record, 2) - 1
        for k = 1 : size(record, 2) - 1
            if isempty(record(k).lambda_e) || isempty(record(k).lambda_h)
                lambda(dhs_control_mode).e(k,1) = inf;
                lambda(dhs_control_mode).h(k,1) = inf;
            else
                lambda(dhs_control_mode).e(k,1) = record(k).lambda_e;
                lambda(dhs_control_mode).h(k,1) = record(k).lambda_h;
            end
        end

        Voltage(dhs_control_mode).V(index_lambda_H).data = ...
            record(index_lambda_H).results.ies_vsm.var.eps.U;

        Gen(dhs_control_mode).P(index_lambda_H).data = ...
            record(index_lambda_H).results.ies_vsm.var.eps.P_gen;

        Gen(dhs_control_mode).Q(index_lambda_H).data = ...
            record(index_lambda_H).results.ies_vsm.var.eps.Q_gen;


        num_fig = num_fig + 1;
        %% plot Voltage
        h_fig = figure(1);
        subplot(6, 10, num_fig);
        h_axis = gca;
        left = 0; bottom = 2; width = 50; height = 25;
        set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
        %         set(gca,'LooseInset',get(gca,'TightInset'));
        cmap = brewermap(4, 'RdBu');
        h_fig.Colormap = cmap;
        h_axis.Colormap = cmap;
        colororder(cmap);
        % %

        plot(Voltage(dhs_control_mode).V(index_lambda_H).data, 'LineWidth', 2);
        hold on;
        plot(ones(24,1) * 1.1, 'LineWidth', 1, 'Color', [0 0 0]);
        if num_fig == 1
            legend({'1' '2' '3' '4' '5' '6' '7' '8' '9'});
        end
        axis([0 25 0.9 1.2]);

        grid on;
        title('Voltage');


        %% plot gen P
        h_fig = figure(2);
        subplot(6, 10, num_fig);
        h_axis = gca;
        left = 50; bottom = 2; width = 50; height = 25;
        set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
        %         set(gca,'LooseInset',get(gca,'TightInset'));
        cmap = brewermap(4, 'RdBu');
        h_fig.Colormap = cmap;
        h_axis.Colormap = cmap;
        colororder(cmap);

        % %
        plot(Gen(dhs_control_mode).P(index_lambda_H).data, 'LineWidth', 2);
        hold on;
        plot(ones(24, 1) * [250 298 270], 'LineWidth', 1, 'Color', [0 0 0]);
        if num_fig == 1
            legend({'1' '2' '3'});
        end
        axis([0 25 100 350]);

        grid on;
        title('Active power of generator');
    end
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
for k = 1 : length(lambda)
    plot(lambda(k).h(:,1), lambda(k).e(:,1), 'LineWidth', 3);
    hold on;
end
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

%% plot load E
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 20; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% %
for k = 1 : 4
    plot(myload(k).E, 'LineWidth', 2);
    hold on;
end
grid on;
title('Electrical load');

%% plot load H
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 20; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% %
for k = 1 : 4
    plot(myload(k).H, 'LineWidth', 2);
    hold on;
end
grid on;
title('Heat load');


%% plot Voltage
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 20; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% %
for k = 1 : 4
    plot(Voltage(k).V(:, :), 'LineWidth', 2);
    hold on;
end
grid on;
title('Voltage');

%% plot branch power
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 20; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% %
for k = 1 : 4
    plot(Branch(k).S(:,:), 'LineWidth', 2);
    hold on;
    plot(Branch(k).S_limit, 'LineWidth', 1);
end
grid on;
title('Apparent power of branch');

%% plot gen P
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 20; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% %
for k = 1 : 4
    plot(Gen(k).P(:,:), 'LineWidth', 2);
    hold on;
end
grid on;
title('Active power of generator');

%% plot gen Q
h_fig = figure();
h_axis = gca;
left = 10; bottom = 10; width = 20; height = 8;
set(h_fig, 'Units','centimeters', 'position', [left, bottom, width, height], 'color', 'w');
set(gca,'LooseInset',get(gca,'TightInset'));
cmap = brewermap(4, 'RdBu');
h_fig.Colormap = cmap;
h_axis.Colormap = cmap;
colororder(cmap);

% %
for k = 1 : 4
    plot(Gen(k).Q(:,:), 'LineWidth', 2);
    hold on;
end
grid on;
title('Reactive power of generator');