%% PCA + Hirarchical clustering 
%  cluster cells based on Z-scored calcium data
%  Inputs (required): group(n)celltraces
%  Outputs ---- clustering figure
% 'group1celltraces' and 2 (and n) should be event aligned z-scored calcium
% traces for all matched neurons
% 'final' should contain all relevant calcium traces, time windows, and
% behavioral timestamps
%% clear all except
close all
clearvars -except sortCellPavD1Traces sortCellPavD5Traces mouseDataMatched final
%% define parameters
n1 = -3; n2 = 3; % zscore axes
nCluster = 1; 
% baseline = [-10 0]; % baseline window
% EventWind = [0 26]; % stimulation window
Zscore1 = sortCellPavD1Traces; % CS1
Zscore2 = sortCellPavD5Traces; % CS2
% Zscore3 = Data3.DFzscore; % CS3

% define time window for PCA in frames
data1 = Zscore1(:,100:700); % CS1, 10-60 seconds
data2 = Zscore2(:,100:700); % CS2, 10-60 seconds
% data3 = Zsc ore3(:,stimulation(1):stimulation(2)); % CS3
% data = [data1 data2];
%% To run PCA on just day 1 or 5
data = [data2];
%% Run PCA
[eigvect,proj,eigval] = pca(data);
%% To run PCA on multi day change second : to 1:2
proj12 = proj(:,:);
figure,plot(proj12(:,1),proj12(:,2),'o')
total_variance = sum(eigval);
percent_variance = (eigval / total_variance) * 100;
xprime = percent_variance - (percent_variance(1) + (percent_variance(end) - percent_variance(1))/(length(percent_variance)-1)*(0:length(percent_variance)-1));
[~, num_retained_pcs] = min(xprime);
fprintf('Number of PCs to keep = %d/n', num_retained_pcs);
figure;
plot(1:length(percent_variance), percent_variance, '-o');
xlim([0 20]);
title('Scree Plot of PCA');
xlabel('Principal Component Number');
ylabel('Percentage of Variance Explained');
grid on;
% figure,plot(proj12(:,3),proj12(:,4),'o')

%% CLUSTERING: Only run one of the three clustering approaches

%% Hierarchical clustering
figure;
cosD = pdist(proj12,'correlation');
clustTreeCos = linkage(cosD,'complete');
cophenet(clustTreeCos,cosD);
[h,nodes] = dendrogram(clustTreeCos,0);
h_gca = gca;
h_gca.TickDir = 'out';
h_gca.TickLength = [.002 0];
T = cluster(clustTreeCos,'maxclust',nCluster);

figure;
[silh,h] = silhouette(data, T);
avrgScore = mean(silh)

figure;
scatter3(proj12(:, 1), proj12(:, 2), proj12(:, 3), 10, T, 'filled');
title('Hierarchical Clusters');
% 
rng(1)
evlauation=evalclusters(proj12,"linkage","CalinskiHarabasz","KList",1:7)

%% K-means clustering

% figure;
% rng(1)
% [T, centroids] = kmeans(proj12, nCluster);
% scatter3(proj12(:, 1), proj12(:, 2), proj12(:, 3), 10, T, 'filled');
% title('K-means Clusters');
% colormap(gca, jet(nCluster));
% % Plot centroids
% hold on;
% scatter3(centroids(:, 1), centroids(:, 2), centroids(:, 3), 100, 'k', 'x', 'LineWidth', 2);
% hold off;
% 
% figure;
% [silh,h] = silhouette(data, T);
% avrgScore = mean(silh)
% 
% rng(1)
% evlauation=evalclusters(proj12,"kmeans","CalinskiHarabasz","KList",1:6)

% ranking = str2num(get(gca,'XTicklabel'));

%% Spectral clustering
% figure;
% rng(1);
% [T,centroids] = spectralcluster(proj12, nCluster);
% scatter3(proj12(:, 1), proj12(:, 2), proj12(:, 3), 10, T, 'filled');
% title('Spectral Clusters');
% colormap(gca, jet(nCluster));
% 
% figure;
% [silh,h] = silhouette(data, T);
% avrgScore = mean(silh)


%% sort and plot figure
[A B] = sort(T,'descend');
ranking = B;
for i = 1:length(ranking)
% for i = 1:153
   data_ranking(i,:) = data(ranking(i),:);
   proj123_ranking(i,:) = proj12(ranking(i),:);
   Zscore1_ranking(i,:) = Zscore1(ranking(i),:); 
   Zscore2_ranking(i,:) = Zscore2(ranking(i),:);
   % Zscore3_ranking(i,:) = Zscore3(ranking(i),:);
end


% Plot heatmap of ranked auROC
% colorspace
% Parameter.colorR = 28; % for colorspace, do not need to change
% Parameter.colorC = 28; % for colorspace, do not need to change
% colorspace = zeros(64,3);
% colorspace(64-Parameter.colorR+1:64,1) = linspace(0,1,Parameter.colorR); % RGB color space, define R value here
% colorspace(1:Parameter.colorC,2) = linspace(1,0,Parameter.colorC); % G
% colorspace(1:Parameter.colorC,3) = linspace(1,0,Parameter.colorC); % B

red = linspace(0,.4);
green = linspace(0,1);
blue = linspace(0,.4);
DavidCustom= [red',green',blue'];

figure,imagesc(data_ranking,[n1 n2]);
colormap(DavidCustom);
colorbar;
% colormap(colorspace)

figure,imagesc(Zscore1_ranking,[n1 n2]);
colormap(DavidCustom);
colorbar;
figure,imagesc(Zscore2_ranking,[n1 n2]);
colormap(DavidCustom);
colorbar;
% figure,imagesc(Zscore3_ranking,[n1 n2]);
% colormap(colorspace)

%% plot curve of different clusters
for i = 1 : nCluster
    CS1T1 = Zscore1(T==i,:);
    CS2T1 = Zscore2(T==i,:);
    clear std
    CS1T1mean=mean(CS1T1);
    CS2T1mean=mean(CS2T1);
    CS1T1SEM = std(CS1T1)/sqrt(size(CS1T1,1));
    CS2T1SEM = std(CS2T1)/sqrt(size(CS2T1,1));
    % CS3T1 = Zscore3(T==i,:);
    %% This part of code (up through figure,imagsc) is for sorting day 1 heatmap by day 5 (to match neurons)

    
    

    figure;
    x = (1:length(CS2T1));
    fill([x, fliplr(x)], [CS2T1mean - CS2T1SEM, fliplr(CS2T1mean + CS2T1SEM)],'b','linestyle','-'); hold on; % Change values depending on what your cellTraces array is
    plot(mean(CS2T1),'Color',[0 0.4 0]);  hold on;
    set(gca,'FontSize', 16)
    xlabel('Time (s)', 'FontSize', 22)
    ylabel('Z-score fluorescence','FontSize', 22)
    xlim([1 700]);
    yl=ylim;
    ylim(yl);
    xline(0,'--')
    set(gca,'FontName','Arial')
    box off

    figure;
    x = (1:length(CS1T1));
    fill([x, fliplr(x)], [CS1T1mean - CS1T1SEM, fliplr(CS1T1mean + CS1T1SEM)],'r'); hold on;
    plot(mean(CS1T1),'Color',[0 0 0.8]);  hold on;
    set(gca,'FontSize', 16)
    xlabel('Time (s)', 'FontSize', 22)
    ylabel('Z-score fluorescence','FontSize', 22)
    xlim([1 700]);
    % yl=ylim;
    ylim(yl);
    xline(0,'--')
    set(gca,'FontName','Arial')
    box off
    clear std

    sortNum = mean(CS2T1(:,100:700)');
    sortCellTraces = cat(2,sortNum',CS1T1);
    temp = sortrows(sortCellTraces);
    sortCellTraces = temp(:,2:end);
    CS1T1Sort = sortCellTraces;
    figure,imagesc(CS1T1Sort,yl);
    colormap(DavidCustom);
    colorbar;
    %%%%%
    % sortNum = mean(CS1T1(:,100:700)');
    % sortCellTraces = cat(2,sortNum',CS2T1);
    % temp = sortrows(sortCellTraces);
    % sortCellTraces = temp(:,2:end);
    % CS2T1Sort = sortCellTraces;
    figure,imagesc(CS2T1,yl);
    colormap(DavidCustom);
    colorbar;

    



end