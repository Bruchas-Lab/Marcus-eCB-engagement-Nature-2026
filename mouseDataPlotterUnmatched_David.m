%% code for plotting feeding sessions

%% organize data by session (even rows adlib, odd rows hungry
trialData = final(1:1:end);

for i = 1:size(trialData,2)
    if i == 1
        trialTraces = trialData(i).unitAVG.startTS.caTraces;
      else
        trialTraces = cat(1, trialTraces, trialData(i).unitAVG.startTS.caTraces);
    end
end

%% norm to pre feed period
for c = 1:size(trialTraces,1)
   trace = trialTraces(c,:);
   avg = nanmean(trialTraces(c,1:100));
   std = nanstd(trialTraces(c,1:100));
   normTrace = (trace - avg) / std;
   normalizedTrial(c,:) = normTrace;
end

%% get mean of normalized traces
scale = transpose((final(1).uv.evtWin(1)):.1:(final(1).uv.evtWin(2)-.1));
trialMean = nanmean(normalizedTrial);
trialMean = smooth(trialMean,6);
trialSem = nanstd(normalizedTrial)/sqrt(size(normalizedTrial,1));
trialSem = smooth(trialSem,6);

%% plot adlib and hungry normalized
figure

fill([scale;flipud(scale)],[trialMean-trialSem;flipud(trialMean+trialSem)],'b','linestyle','-'); % Change values depending on what your cellTraces array is
hold
plot(scale,trialMean, 'k')
%set(gca,'FontSize', 16)
xlabel('Time relative to lick onset (s)', 'FontSize', 16)
ylabel('Z-score fluorescence','FontSize', 16)
xline(0,'--')
set(gcf, 'Position',  [100, 100, 600, 600])

%%
uv = final(1).uv;
%% plot heatplots and line graph for each condition
subplot(211)
sortNum = mean(normalizedTrial(:,100:360)');
sortCellTraces = cat(2,sortNum',normalizedTrial);
temp = sortrows(sortCellTraces);
sortCellTraces = temp(:,2:end);
clims = ([-2 5.0]);
imagesc(sortCellTraces,clims)
xline((-uv.evtWin(1,1)*10),'--')
xticklabels = (uv.evtWin(1,1)):10:(uv.evtWin(1,2));
xticks = linspace(1, length(normalizedTrial), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
set(gca,'FontName','Arial','FontSize',16)
xlabel('Time relative to cue onset (s)','FontSize',16)
ylabel('Cell number','FontSize',16)
title('PavD1 Cue Aligned');
colormap('summer')
colorbar;


subplot(212)
fill([scale;flipud(scale)],[trialMean-trialSem;flipud(trialMean+trialSem)],'b','linestyle','-'); % Change values depending on what your cellTraces array is
hold
plot(scale,trialMean, 'k')
%set(gca,'FontSize', 16)
xlabel('Time relative to cue onset (s)', 'FontSize', 16)
ylabel('Z-score fluorescence','FontSize', 16)
axis([-10 60  -1 2.0])
xline(0,'--')
set(gcf, 'Position',  [100, 100, 600, 600])
colorbar
box off
    