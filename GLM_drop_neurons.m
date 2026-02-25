clearvars -except separated_d1 separated_d5

% Load relevant behaviors
d1_behavs = xlsread("d1_normed_behavs.xlsx");
d5_behavs = xlsread("d5_normed_behavs.xlsx");

num_clusters = length(separated_d5);

headers = {'Intercept','Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears', 'Grooms', 'Rests'};

to_drop = [0, 0.25, 0.50, 0.75];
to_drop_count = length(to_drop);

cluster_betas = cell(num_clusters, 1);
cluster_pvals = cell(num_clusters, 1);

%% Analyze Neurons

% Set random seed for reproducibility
rng(42);

for i = 1:num_clusters
    cluster_traces = separated_d5{i}'; % 700 x n
    behavs = d5_behavs; % 700 x 7
    
    num_predictors = size(behavs, 2);
    num_responses = size(cluster_traces, 2);

    betas_matrix = zeros(num_predictors + 1, to_drop_count);
    pvals_matrix = zeros(num_predictors + 1, to_drop_count);

    for j = 1:to_drop_count
        % Calculate number of traces to remove
        num_samples_to_remove = round(num_responses * to_drop(j));
        
        % Pick random indices to remove
        indices_to_remove = randperm(num_responses, num_samples_to_remove);
        
        % Remove the indices
        traces_reduced = cluster_traces;
        traces_reduced(:, indices_to_remove) = [];
        
        reduced_trace = mean(traces_reduced, 2);    % 700 x 1

        [b, dev, stats] = glmfit(behavs, cluster_traces(:,j), 'normal', 'link', 'identity');

        % Store results
        betas_matrix(:,j) = b;
        pvals_matrix(:,j) = stats.p;
    end
    
    cluster_betas{i} = betas_matrix;
    cluster_pvals{i} = pvals_matrix;
end

%% Find Num Encoding
filter = [2,3,5,6,7];
threshold = 0.5;

filtered_labels = headers(:, filter);
for i = 1:num_clusters
    fprintf('\nCluster %d:\n', i)

    % disp('Betas')
    betas = cluster_betas{i};   % 8 x N
    filtered_betas = betas(filter, :);
    
    for j = 1:size(filtered_betas, 1)
        row_betas = filtered_betas(j, :);
        num_pos_encoding = sum(row_betas >= threshold, 'all');
        num_neg_encoding = sum(row_betas <= -threshold, 'all');
        
        fprintf('%d\t%d\n', num_pos_encoding, num_neg_encoding)
    end
    
    % disp('P-Values')
    % pvals = cluster_betas{i};   % 8 x N
    % filtered_pvals = betas(filter, :);
    % 
    % for j = 1:size(filtered_pvals, 1)
    %     row_pvals = filtered_pvals(j, :);
    %     num_encoding = sum(row_pvals < 0.05, 'all');
    %     fprintf('%d\n', num_encoding)
    % end
end