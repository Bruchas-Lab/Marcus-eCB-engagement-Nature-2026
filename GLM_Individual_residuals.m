clearvars -except NAcClustersInOrder separated_d1 separated_d5

% Load relevant behaviors
d1_behavs = xlsread("d1_inferred_lick_normed_behavs_no_rest.xlsx");
d5_behavs = xlsread("d5_inferred_lick_normed_behavs_no_rest.xlsx");

num_clusters = length(separated_d1);

headers = {'Intercept','Engagements', 'Disengagements', 'Licks', 'Walks', 'Rears'};

cluster_residuals = cell(num_clusters, 1);
cluster_stdresiduals = cell(num_clusters, 1);

cluster_tstats = cell(num_clusters, 1);
cluster_pvals = cell(num_clusters, 1);

%% Analyze Neurons
for i = 1:num_clusters
    cluster_traces = separated_d5{i}'; % 700 x n
    behavs = d5_behavs(:, [1, 2, 4, 5, 6]);

    num_predictors = size(behavs, 2);
    num_responses = size(cluster_traces, 2);
    
    residuals_matrix = zeros(size(cluster_traces));
    stdresiduals_matrix = zeros(size(cluster_traces));

    tstats_matrix = zeros(num_predictors + 1, num_responses);  % +1 for intercept
    pvals_matrix = zeros(num_predictors + 1, num_responses);
    
    % fprintf('\nCluster %d:\n', i)
    for j = 1:num_responses
        [b, dev, stats] = glmfit(behavs, cluster_traces(:,j), 'normal', 'link', 'identity');
        
        residuals_matrix(:,j) = stats.resid;
        stdresiduals_matrix(:,j) = stats.resid / stats.s;
        
        tstats_matrix(:,j) = stats.t;
        pvals_matrix(:,j) = stats.p;
        
        % fprintf('Neuron %d:\n', j)
        % fprintf('Residual mean: %.4f\n', mean(stats.resid));
        % fprintf('Residual std: %.4f\n', std(stats.resid));
    end
    
    cluster_residuals{i} = residuals_matrix;
    cluster_stdresiduals{i} = stdresiduals_matrix;

    cluster_tstats{i} = tstats_matrix;
    cluster_pvals{i} = pvals_matrix;
end

%% Approach 2: Residual distributions
colors = [
    0.8500 0.3250 0.0980;  % Orange
    0.0000 0.4470 0.7410;  % Blue
    0.4660 0.6740 0.1880;  % Green
    0.4940 0.1840 0.5560;  % Purple
    0.9290 0.6940 0.1250   % Yellow
];

fig = figure('Position', [100 100 1200 800]);  % Make figure larger

% Create subplots in a layout that makes sense for 5 clusters
% Could do 2x3, 3x2, or 5x1 depending on your preference
for i = 1:num_clusters
    subplot(2,3,i)  % 2x3 layout (gives room for 6 subplots but we'll use 5)
    
    stdresids = cluster_stdresiduals{i}; % 700 x n
    hold on
    
    % Plot individual neuron distributions
    for j = 1:size(stdresids, 2)
        [f,xi] = ksdensity(stdresids(:, j));
        plot(xi, f, 'Color', [colors(i,:) 0.2], 'LineWidth', 1)  % Use transparency
    end
    
    % Optionally, add the overall cluster distribution with a thicker line
    [f,xi] = ksdensity(stdresids(:));
    plot(xi, f, 'Color', colors(i,:), 'LineWidth', 2, 'DisplayName', 'Cluster Mean')
    
    title(sprintf('Cluster %d (n=%d neurons)', i, size(stdresids, 2)))
    xlabel('Standardized Residuals')
    ylabel('Density')
    
    % Add a vertical line at x=0 for reference
    line([0 0], ylim, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1)
    
    % Optional: standardize axes across subplots for easier comparison
    xlim([-4 4])  % Adjust based on your data range
    hold off
end

% Add an overall title
sgtitle('Residual Distributions by Cluster and Neuron')
saveas(fig, 'no_rest_lick_std_resid_distribution_d5', 'svg');


% %% Analyze D1 Neurons
% for i = 1:num_clusters
%     cluster_traces = separated_d1{i}'; % 700 x n
% 
%     num_predictors = size(d1_behavs, 2);
%     num_responses = size(cluster_traces, 2);
%     betas = zeros(num_predictors + 1, num_responses);  % +1 for intercept
%     p_values = zeros(num_predictors + 1, num_responses);
% 
%     for j = 1:num_responses
%         [b, dev, stats] = glmfit(d1_behavs, cluster_traces(:,j), 'normal', 'link', 'identity');
%         betas(:,j) = b;  % Store coefficients
%         p_values(:,j) = stats.p;  % Store p-values
%     end
% 
%     % Convert to tables with headers
%     betas_table = array2table(betas', 'VariableNames', headers);
%     pvals_table = array2table(p_values', 'VariableNames', headers);
% 
%     % Save with headers
%     b_name = sprintf("glm_cluster_data/d1_cluster_%d_betas.xlsx", i);
%     p_name = sprintf("glm_cluster_data/d1_cluster_%d_pvalues.xlsx", i);
%     writetable(betas_table, b_name);
%     writetable(pvals_table, p_name);
% end