clearvars -except NAcClustersInOrder separated_d1 separated_d5
close all

% Load relevant behaviors
behav_labels = {'Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears', 'Grooms', 'Rests'};
d1_behavs = xlsread("d1_inferred_lick_normed_behavs_no_rest.xlsx");
d5_behavs = xlsread("d5_inferred_lick_normed_behavs_no_rest.xlsx");
num_clusters = length(separated_d1);

% Filter behaviors
filter = [1, 2, 4, 5, 6];
% filtered_labels = headers(:, 1:6);
filtered_d1_behavs = d1_behavs(:, filter);
filtered_d5_behavs = d5_behavs(:, filter);

%% Set Up Analyses
cluster_traces = separated_d1;
behavs = filtered_d1_behavs;

num_predictors = size(behavs, 2);

cluster_tstats = cell(num_clusters, 1);

%% Analyze Neurons
for i = 1:num_clusters
    traces = cluster_traces{i}'; % 700 x n

    num_responses = size(traces, 2);
    tstats_matrix = zeros(num_predictors + 1, num_responses);  % +1 for intercept
    
    for j = 1:num_responses
        [b, dev, stats] = glmfit(behavs, traces(:,j), 'normal', 'link', 'identity');
        tstats_matrix(:,j) = stats.t;
    end

    cluster_tstats{i} = tstats_matrix;
end

%% Analyze T-stats
for i = 1:num_clusters
    ts = cluster_tstats{i}; % 8 x n
    mean_ts = mean(ts, 2);

    fprintf('\nCluster %d:\n', i);

    fprintf('%.4f\n', mean_ts(1));
    for j = 2:length(mean_ts)
        fprintf('%.4f\n', mean_ts(j));
    end
end

%% Visualize parameter significance across clusters
labels = {'Intercept','Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears', 'Grooms', 'Rests'};
t_fig = figure('Position', [100 100 1200 400]);
for i = 1:num_clusters
    subplot(1,5,i)
    imagesc(cluster_tstats{i})  % Binary significance map
    title(sprintf('Cluster %d', i))
    xlabel('Neuron')
    ylabel('Behavior')
    yticks(1:length(labels))
    yticklabels(labels)
    xticks([1 floor(size(cluster_tstats{i},2)/2) size(cluster_tstats{i},2)])
    colorbar
    colormap(brewermap(64,'RdBu'))  % Using a diverging colormap
    clim_val = max(abs(cluster_tstats{i}(:)));
    clim([-clim_val clim_val])
end
sgtitle('Behavior Effect Size Across Clusters (T)')

saveas(t_fig, 'no_rest_lick_t_value_heat_plot_d1', 'svg');

% %% Filtered
% labels = {'Intercept','Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears', 'Grooms', 'Rests'};
% filtered_labels = {'Engagements', 'Disengagements', 'Walks', 'Rears', 'Grooms'};
% t_fig = figure('Position', [100 100 1200 400]);
% for i = 1:num_clusters
%     filtered_ts = cluster_tstats{i}([2,3,5,6,7],:);
% 
%     subplot(1,5,i)
%     imagesc(filtered_ts)  % Binary significance map
%     title(sprintf('Cluster %d', i))
%     xlabel('Neuron')
%     ylabel('Behavior')
%     yticks(1:length(filtered_labels))
%     yticklabels(filtered_labels)
%     xticks([1 floor(size(filtered_ts,2)/2) size(filtered_ts,2)])
%     colorbar
%     colormap(brewermap(64,'RdBu'))  % Using a diverging colormap
%     clim_val = max(abs(filtered_ts(:)));
%     clim([-clim_val clim_val])
%     % clim([-30 30])
% end
% sgtitle('Behavior Effect Size Across Clusters (T)')
% saveas(t_fig, 'symmetric_t_value_heat_plot_d1', 'svg');
