clearvars -except NAcClustersInOrder separated_d1 separated_d5

% Load relevant behaviors
headers = {'Intercept','Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears', 'Grooms', 'Rests'};
d1_behavs = xlsread("d1_normed_behavs.xlsx");
d5_behavs = xlsread("d5_normed_behavs.xlsx");

% Filter behaviors
filter = [1, 2, 4, 5, 6];
% filtered_labels = headers(:, filter);

filtered_d1_behavs = d1_behavs(:, filter);
filtered_d5_behavs = d5_behavs(:, filter);

num_clusters = length(separated_d5);

cluster_betas = cell(num_clusters, 1);
cluster_pvals = cell(num_clusters, 1);

%% Analyze Neurons
for i = 1:num_clusters
    cluster_traces = separated_d1{i}'; % 700 x n
    behavs = filtered_d1_behavs;

    num_predictors = size(behavs, 2);
    num_responses = size(cluster_traces, 2);
    
    betas_matrix = zeros(num_predictors + 1, num_responses);
    pvals_matrix = zeros(num_predictors + 1, num_responses);
    
    for j = 1:num_responses
        [b, dev, stats] = glmfit(behavs, cluster_traces(:,j), 'normal', 'link', 'identity');
        
        betas_matrix(:,j) = b;
        pvals_matrix(:,j) = stats.p;

    end
    
    cluster_betas{i} = betas_matrix;
    cluster_pvals{i} = pvals_matrix;
end

%% Find Num Encoding
threshold = 0.5;

for i = 1:num_clusters
    fprintf('\nCluster %d:\n', i)

    % disp('Betas')
    betas = cluster_betas{i};   % 8 x N
    filtered_betas = betas(2:end, :);
    
    for j = 1:size(filtered_betas, 1)
        row_betas = filtered_betas(j, :);
        % half_num_encoding = sum(abs(row_betas) >= 0.5, 'all');
        % full_num_encoding = sum(abs(row_betas) >= 1.0, 'all');
        % 
        % fprintf('%d\t%d\n', half_num_encoding, full_num_encoding)

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