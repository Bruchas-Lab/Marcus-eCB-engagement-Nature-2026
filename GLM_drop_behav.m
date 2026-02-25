clearvars -except NAcClustersInOrder separated_d1 separated_d5
close all

% Load relevant behaviors
headers = {'Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears', 'Grooms', 'Rests'};
d1_behavs = xlsread("d1_inferred_lick_normed_behavs_no_rest.xlsx");
d5_behavs = xlsread("d5_inferred_lick_normed_behavs_no_rest.xlsx");

% Filter behaviors
filter = [1, 2, 4, 5, 6];

behav_to_remove = 5;

filtered_behav_labels = headers(filter);
filtered_d1_behavs = d1_behavs(:, filter);
filtered_d5_behavs = d5_behavs(:, filter);

%% Set Up Analysis
cluster_traces = separated_d5;
behavs = filtered_d5_behavs;

behavs(:, behav_to_remove) = [];

num_predictors = size(behavs, 2);
num_responses = length(cluster_traces);
betas = zeros(num_predictors + 1, num_responses);
p_values = zeros(num_predictors + 1, num_responses);

% betas = cell(num_responses, num_predictors + 1);
% p_values = cell(num_responses, num_predictors + 1);

%% Analyze Neurons
for i = 1:num_responses
    traces = mean(cluster_traces{i}, 1)';

    [b, dev, stats] = glmfit(behavs, traces, 'normal', 'link', 'identity');
    betas(:,i) = b;  % Store coefficients
    p_values(:,i) = stats.p;  % Store p-values
end

%% Display results
for i = 1:num_responses
    fprintf('\nCluster %d (n=%d):\n', i, size(cluster_traces{i}, 1));
    fprintf('%.4f\t%.4f\n', betas(1,i), p_values(1,i));

    for j = 2:length(betas)
        fprintf('%.4f\t%.4f\n', betas(j,i), p_values(j,i));
    end
end
