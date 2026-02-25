clearvars -except NAcClustersInOrder separated_d1 separated_d5
close all

% Load relevant behaviors
headers = {'Intercept','Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears', 'Grooms', 'Rests'};
d1_behavs = xlsread("d1_normed_behavs.xlsx");
d5_behavs = xlsread("d5_normed_behavs.xlsx");

% Filter behaviors
filter = [2,3,5,6,7];
filtered_labels = headers(:, filter);

filtered_d1_behavs = d1_behavs(:, filter);
filtered_d5_behavs = d5_behavs(:, filter);

%% Set Up Analysis
cluster_traces = separated_d1;
behavs = filtered_d1_behavs;

num_predictors = size(behavs, 2);
num_responses = length(cluster_traces);
betas = zeros(num_predictors + 1, num_responses);  % +1 for intercept
p_values = zeros(num_predictors + 1, num_responses);

%% Analyze Neurons
for i = 1:num_responses
    traces = mean(cluster_traces{i}, 1)';

    [b, dev, stats] = glmfit(behavs, traces, 'normal', 'link', 'identity');
    betas(:,i) = b;  % Store coefficients
    p_values(:,i) = stats.p;  % Store p-values
end

%% Display results
for i = 1:num_responses
    fprintf('\nCluster %d:\n', i);
    % fprintf('Intercept: %.4f (p = %.4f)\n', betas(1,i), p_values(1,i));
    fprintf('%.4f\n', betas(1,i));
    for j = 2:length(betas)
        % fprintf('%s: %.4f (p = %.4f)\n', filtered_labels{j}, betas(j+1,i), p_values(j+1,i));
        fprintf('%.4f\n', betas(j,i));
    end
end
