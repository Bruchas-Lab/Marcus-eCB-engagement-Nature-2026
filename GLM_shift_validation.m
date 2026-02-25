clearvars -except NAcClustersInOrder separated_d1 separated_d5
close all

cue = zeros(700, 1);
cue(101:360) = 1;

d1_behavs = xlsread("d1_normed_behavs.xlsx");
d5_behavs = xlsread("d5_normed_behavs.xlsx");

d5_cluster_traces = NAcClustersInOrder';
d1_cluster_traces = zeros(700, 5);
for i = 1:5
    d1_cluster_traces(:,i) = mean(separated_d1{i});  % mean of all elements in the matrix
end

% Analysis params
num_predictors = size(d5_behavs, 2);
num_responses = size(d5_cluster_traces, 2);

% Variables to store resulst
betas_cell = cell(num_responses, 1);
p_values_cell = cell(num_responses, 1);

% betas = zeros(num_predictors + 1, num_responses);  % +1 for intercept
% p_values = zeros(num_predictors + 1, num_responses);

shift_by = 1:500; %[0, 1:10, 50, 100, 200, 300, 400, 500];
num_shifts = length(shift_by);

for i = 1:num_responses
    betas = zeros(num_predictors + 1, num_shifts);
    p_values = zeros(num_predictors + 1, num_responses);
    
    % fprintf('\nCluster %d:', i);
    for j = 1:num_shifts
        shift = shift_by(j);
        % fprintf('\nShifting by %d:', shift);
        shifted_behav = circshift(d1_behavs, shift);
        [b, dev, stats] = glmfit(shifted_behav, d5_cluster_traces(:,i), 'normal', 'link', 'identity');

        betas(:, j) = real(b);
        p_values(:, j) = stats.p;
    end
    
    betas_cell{i} = betas;
    p_values_cell{i} = p_values;
end

% for i = 1:num_responses
%     [b, dev, stats] = glmfit(behavs, cluster_traces(:,i), 'normal', 'link', 'logit');
%     betas(:,i) = b;  % Store coefficients
%     p_values(:,i) = stats.p;  % Store p-values
% 
%     % fprintf('\nCluster %d:\n', i);
% end
