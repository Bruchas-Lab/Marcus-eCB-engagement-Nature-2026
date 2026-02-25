clearvars -except sortCellPavD1Traces sortCellPavD5Traces NAcClustersInOrder

%% PCA + Hierarchical clustering 
n1 = -3; n2 = 3;          % SD
nCluster = 5;

Zscore1 = sortCellPavD1Traces;  % CS1
Zscore2 = sortCellPavD5Traces;  % CS2
data1 = Zscore1(:,100:700); % CS1
data2 = Zscore2(:,100:700); % CS2

% Sort D1 based on D5
sortNum = mean(data2');
sortCellTraces = cat(2, sortNum', data1);
temp = sortrows(sortCellTraces);
data1 = temp(:, 2:end);

% Ensure data1 and data2 have the same number of rows (cells)
assert(size(data1, 1) == size(data2, 1), 'Number of cells in D1 and D5 do not match');

%% Dimensionality Reduction
% PCA on D5
[coeff, score, latent, tsquared, explained, mu] = pca(data2);

% Project D5Traces (data2) into PC space
proj_D5 = score;

% Project D1Traces (data1) into the same PC space
proj_D1 = (data1 - mu) * coeff;

%% Clustering (using D5 projections)
% Hierarchical clustering
cosD = pdist(proj_D5, 'correlation');
clustTreeCos = linkage(cosD, 'complete');
T = cluster(clustTreeCos, 'maxclust', nCluster);

% Cluster labels
cluster_labels = T;  % Each element corresponds to a D5 trace's cluster assignment

% Verify that the number of samples matches across all relevant variables
assert(size(data2,1) == size(proj_D5,1) && size(data2,1) == length(cluster_labels), ...
    'Mismatch in number of samples across data, PC coordinates, and cluster labels');

% Display some information
fprintf('Number of D5 samples: %d\n', size(proj_D5, 1));
fprintf('Number of D1 samples: %d\n', size(proj_D1, 1));
fprintf('Number of features (PCs): %d\n', size(proj_D5, 2));
fprintf('Number of clusters: %d\n', nCluster);

%% Prepare data for export
N = 5;  % Number of PCs to export
% X_D5 = proj_D5(:, 1:N);
% X_D1 = proj_D1(:, 1:N);
y = cluster_labels;

counts = histcounts(y, 'BinMethod', 'integers', 'BinLimits', [1, 5]);

% Get unique labels
unique_labels = unique(y);

% if ~exist('cluster_data', 'dir')
%     mkdir('cluster_data');
% end

% for i = 1:length(unique_labels)
%     current_label = unique_labels(i);
%     mask = (cluster_labels == current_label);
% 
%     % Get activities for current cluster for both D1 and D5
%     cluster_activity_d1 = sortCellPavD1Traces(mask, :);
%     cluster_activity_d5 = sortCellPavD5Traces(mask, :);
% 
%     % figure;
%     % plot(mean(cluster_activity_d5));
%     % title(current_label);
%     % 
%     % figure;
%     % plot(mean(cluster_activity_d1));
%     % title(current_label);
% 
%     % Create tables for both D1 and D5 data
%     % Convert to tables and add cell numbers as row names
%     cell_numbers = find(mask);
%     varNames = arrayfun(@(x) sprintf('Time_%d', x), 1:size(cluster_activity_d1,2), 'UniformOutput', false);
% 
%     % Create tables
%     T_d1 = array2table(cluster_activity_d1, 'VariableNames', varNames, 'RowNames', cellstr(num2str(cell_numbers)));
%     T_d5 = array2table(cluster_activity_d5, 'VariableNames', varNames, 'RowNames', cellstr(num2str(cell_numbers)));
% 
%     % Save to Excel files
%     filename_d1 = fullfile('cluster_data', sprintf('cluster_%d_d1.xlsx', current_label));
%     filename_d5 = fullfile('cluster_data', sprintf('cluster_%d_d5.xlsx', current_label));
% 
%     writetable(T_d1, filename_d1, 'WriteRowNames', true);
%     writetable(T_d5, filename_d5, 'WriteRowNames', true);
% 
%     % Print information about saved cluster
%     fprintf('Cluster %d: Saved %d cells for both D1 and D5\n', current_label, sum(mask));
% end

% Create cell arrays to store separated data
separated_d5 = cell(length(unique_labels), 1);
separated_d1 = cell(length(unique_labels), 1);

% Separate data based on labels
for i = 1:length(unique_labels)
    current_label = unique_labels(i);
    mask = (y == current_label);

    separated_d5{i} = sortCellPavD5Traces(mask, :);
    separated_d1{i} = sortCellPavD1Traces(mask, :);
end


% Split cluster neurons into 80-20
% d5_train = zeros(5, 700);
% d5_test = zeros(5, 700);
% d1_train = zeros(5, 700);
% d1_test = zeros(5, 700);
% 
% rng(42);
% for i = 1:length(unique_labels)
%     cluster_data = separated_d5{i};
%     n_rows = size(cluster_data, 1);
% 
%     n_train = round(0.8 * n_rows);
% 
%     idx = randperm(n_rows);
%     train_data = cluster_data(idx(1:n_train), :);
%     test_data = cluster_data(idx(n_train+1:end), :);
% 
%     d5_train(i, :) = mean(train_data);
%     d5_test(i, :) = mean(test_data);
% end
% 
% rng(42);
% for i = 1:length(unique_labels)
%     cluster_data = separated_d1{i};
%     n_rows = size(cluster_data, 1);
% 
%     n_train = round(0.8 * n_rows);
% 
%     idx = randperm(n_rows);
%     train_data = cluster_data(idx(1:n_train), :);
%     test_data = cluster_data(idx(n_train+1:end), :);
% 
%     d1_train(i, :) = mean(train_data)';
%     d1_test(i, :) = mean(test_data)';
% end

% writematrix(d5_train, 'd5_train_data.xlsx');
% writematrix(d5_test, 'd5_test_data.xlsx');
% writematrix(d1_train, 'd1_train_data.xlsx');
% writematrix(d1_test, 'd1_test_data.xlsx');