clearvars -except NAcClustersInOrder separated_d1 separated_d5

% Load relevant behaviors
d1_behavs = xlsread("d1_normed_behavs.xlsx");
d5_behavs = xlsread("d5_normed_behavs.xlsx");

num_clusters = length(separated_d5);

headers = {'Intercept','Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears', 'Grooms', 'Rests'};

%% Create output directory
if ~exist('glm_cluster_data', 'dir')
    mkdir('glm_cluster_data');
end

%% Analyze D5 Neurons
for i = 1:num_clusters
    cluster_traces = separated_d5{i}'; % 700 x n

    num_predictors = size(d5_behavs, 2);
    num_responses = size(cluster_traces, 2);
    betas = zeros(num_predictors + 1, num_responses);  % +1 for intercept
    p_values = zeros(num_predictors + 1, num_responses);

    for j = 1:num_responses
        [b, dev, stats] = glmfit(d5_behavs, cluster_traces(:,j), 'normal', 'link', 'identity');
        betas(:,j) = b;  % Store coefficients
        p_values(:,j) = stats.p;  % Store p-values
    end
    
    % Convert to tables with headers
    betas_table = array2table(betas', 'VariableNames', headers);
    pvals_table = array2table(p_values', 'VariableNames', headers);
    
    % Save with headers
    b_name = sprintf("glm_cluster_data/d5_cluster_%d_betas.xlsx", i);
    p_name = sprintf("glm_cluster_data/d5_cluster_%d_pvalues.xlsx", i);
    writetable(betas_table, b_name);
    writetable(pvals_table, p_name);
end


%% Analyze D1 Neurons
for i = 1:num_clusters
    cluster_traces = separated_d1{i}'; % 700 x n

    num_predictors = size(d1_behavs, 2);
    num_responses = size(cluster_traces, 2);
    betas = zeros(num_predictors + 1, num_responses);  % +1 for intercept
    p_values = zeros(num_predictors + 1, num_responses);

    for j = 1:num_responses
        [b, dev, stats] = glmfit(d1_behavs, cluster_traces(:,j), 'normal', 'link', 'identity');
        betas(:,j) = b;  % Store coefficients
        p_values(:,j) = stats.p;  % Store p-values
    end
    
    % Convert to tables with headers
    betas_table = array2table(betas', 'VariableNames', headers);
    pvals_table = array2table(p_values', 'VariableNames', headers);
    
    % Save with headers
    b_name = sprintf("glm_cluster_data/d1_cluster_%d_betas.xlsx", i);
    p_name = sprintf("glm_cluster_data/d1_cluster_%d_pvalues.xlsx", i);
    writetable(betas_table, b_name);
    writetable(pvals_table, p_name);
end