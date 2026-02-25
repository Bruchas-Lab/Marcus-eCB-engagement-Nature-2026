%% code for plotting feeding sessions

uv.sortWin = [0 26]; %set window for sorting, units = seconds
clims = ([-3 3]); %set colorlimits here
uv.norm = 1; %0 = no baseline norm, 1 = baseline norm
uv.normWin = [-10, 0]; %only used if uv.norm = 1, units = seconds


%% organize data by session (even rows adlib, odd rows hungry
pavDay5Data = final(2:2:end);
pavDay1Data = final(1:2:end);
pavDay5Traces = [];
pavDay1Traces = [];
for i = 1:size(pavDay5Data,2)
    if i == 1
%         if length(fieldnames(stressData(i).unitAVG)) < 3
%             [];
%         else
            pavDay5Traces = pavDay5Data(i).unitAVG.startTS.caTraces;
%         end
    else
%         if length(fieldnames(stressData(i).unitAVG)) < 3
%             [];
%         else
            pavDay5Traces = cat(1, pavDay5Traces, pavDay5Data(i).unitAVG.startTS.caTraces);
%         end
    end
end

for i = 1:size(pavDay1Data,2)
    if i == 1
%         if length(fieldnames(noStressData(i).unitAVG)) < 3
%             [];
%         else
            pavDay1Traces = pavDay1Data(i).unitAVG.startTS.caTraces;
%         end
    else
%         if length(fieldnames(noStressData(i).unitAVG)) < 3
%             [];
%         else
            pavDay1Traces = cat(1, pavDay1Traces, pavDay1Data(i).unitAVG.startTS.caTraces);
%         end
    end
end

%% use if you dont want to normalize to pre-feeding period
% if uv.norm == 0;
%     scale = transpose((final(1).uv.evtWin(1)):.1:(final(1).uv.evtWin(2)-.1));
%     pavDay5Mean = nanmean(pavDay5Traces);
%     pavDay5Mean = smooth(pavDay5Mean,5);
%     pavDay5Sem = nanstd(pavDay5Traces)/sqrt(size(pavDay5Traces,1));
%     pavDay5Sem = smooth(pavDay5Sem,5);
% 
%     pavDay1Mean = nanmean(pavDay1Traces);
%     pavDay1Mean = smooth(pavDay1Mean,5);
%     pavDay1Sem = nanstd(pavDay1Traces)/sqrt(size(pavDay1Traces,1));
%     pavDay1Sem = smooth(pavDay1Sem,5);
% end

%% norm to pre feed period
if uv.norm == 1;
    scale = transpose((final(1).uv.evtWin(1)):.1:(final(1).uv.evtWin(2)-.1));
    startNorm = find(round(scale,1) == uv.normWin(1,1));
    endNorm = find(round(scale,1) == uv.normWin(1,2));

    for c = 1:size(pavDay5Traces,1)
        trace = pavDay5Traces(c,:);
        avg = nanmean(pavDay5Traces(c,startNorm:endNorm));
        std = nanstd(pavDay5Traces(c,startNorm:endNorm));
        normTrace = (trace - avg) / std;
        pavDay5Traces(c,:) = normTrace;
        clear normTrace
    end

    for c = 1:size(pavDay1Traces,1)
        trace = pavDay1Traces(c,:);
        avg = nanmean(pavDay1Traces(c,startNorm:endNorm));
        std = nanstd(pavDay1Traces(c,startNorm:endNorm));
        normTrace = (trace - avg) / std;
        pavDay1Traces(c,:) = normTrace;
        clear normTrace
    end
end
%% get mean of normalized traces
if uv.norm == 1
    scale = transpose((final(1).uv.evtWin(1)):.1:(final(1).uv.evtWin(2)-.1));
    pavDay5Mean = nanmean(pavDay5Traces);
    pavDay5Mean = smooth(pavDay5Mean,6);
    pavDay5Sem = nanstd(pavDay5Traces)/sqrt(size(pavDay5Traces,1));
    pavDay5Sem = smooth(pavDay5Sem,6);

    pavDay1Mean = nanmean(pavDay1Traces);
    pavDay1Mean = smooth(pavDay1Mean,6);
    pavDay1Sem = nanstd(pavDay1Traces)/sqrt(size(pavDay1Traces,1));
    pavDay1Sem = smooth(pavDay1Sem,6);
end

%% plot adlib and hungry normalized

fill([scale;flipud(scale)],[pavDay5Mean-pavDay5Sem;flipud(pavDay5Mean+pavDay5Sem)],'r','linestyle','-'); % Change values depending on what your cellTraces array is
hold
plot(scale,pavDay5Mean, 'k')
%set(gca,'FontSize', 16)
xlabel('Time relative to behav onset (s)', 'FontSize', 22)
ylabel('Z-score fluorescence','FontSize', 22)
set(gcf, 'Position',  [100, 100, 600, 600])

fill([scale;flipud(scale)],[pavDay1Mean-pavDay1Sem;flipud(pavDay1Mean+pavDay1Sem)],'b','linestyle','-'); % Change values depending on what your cellTraces array is
plot(scale,pavDay1Mean, 'k')
%set(gca,'FontSize', 16)
xlabel('Time relative to behav onset (s)', 'FontSize', 22)
ylabel('Z-score fluorescence','FontSize', 22)
set(gcf, 'Position',  [100, 100, 600, 600])
%% plot heatplots and line graph for each condition
startRow = find(round(scale,1) == uv.sortWin(1,1));
endRow = find(round(scale,1) == uv.sortWin(1,2));
figure
subplot(223)
sortNum = mean(pavDay5Traces(:,startRow:endRow)');
sortCellTraces = cat(2,sortNum',pavDay5Traces);
temp = sortrows(sortCellTraces);
sortCellTraces = temp(:,2:end);
sortCellPavD5Traces = sortCellTraces;
% clims = ([-5 5]);
imagesc(sortCellTraces,clims)
xline((-final(1).uv.evtWin(1,1)*10),'--w')
xticklabels = (final(1).uv.evtWin(1,1)):10:(final(1).uv.evtWin(1,2));
xticks = linspace(1, length(pavDay5Traces), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
set(gca,'FontName','Arial','FontSize',16)
xlabel('Time from tone (s)','FontSize',22)
ylabel('Cell number','FontSize',22)
title('Day 5 traces');
colormap('summer')
colorbar;
% 
subplot(221)
sortNum = mean(pavDay5Traces(:,startRow:endRow)');
sortCellTraces = cat(2,sortNum',pavDay1Traces);
temp = sortrows(sortCellTraces);
sortCellTraces = temp(:,2:end);
sortCellPavD1Traces = sortCellTraces;
% clims = ([-5 5]);
imagesc(sortCellTraces,clims)
xline((-final(1).uv.evtWin(1,1)*10),'--w')
xticklabels = (final(1).uv.evtWin(1,1)):10:(final(1).uv.evtWin(1,2));
xticks = linspace(1, length(pavDay1Traces), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
set(gca,'FontName','Arial','FontSize',16)
xlabel('Time from tone (s)','FontSize',22)
ylabel('Cell number','FontSize',22)
title('Day 1 Traces')
colormap(flipud(brewermap([],'RdPu'))) 
colorbar;

subplot(2,2,[2 4])
fill([scale;flipud(scale)],[pavDay5Mean-pavDay5Sem;flipud(pavDay5Mean+pavDay5Sem)],'r','linestyle','-'); % Change values depending on what your cellTraces array is
hold
plot(scale,pavDay5Mean, 'k')
set(gca,'FontSize', 16)
xlim([-10 60])
xlabel('Time relative to behav onset (s)', 'FontSize', 22)
ylabel('Z-score fluorescence','FontSize', 22)
set(gcf, 'Position',  [100, 100, 600, 600])
set(gca,'FontName','Arial')


% fill([1:700,700:1],[CS2T1mean-CS2T1SEM;flipud(CS2T1mean+CS2T1SEM)],'r','linestyle','-'); % Change values depending on what your cellTraces array is
% plot(mean(CS2T1),'Color',[0 0.4 0])
% set(gca,'FontSize', 16)
% xlabel('Time relative to consumption onset (s)', 'FontSize', 22)
% ylabel('Z-score fluorescence','FontSize', 22)
% xline(0,'--')
% set(gca,'FontName','Arial')
% box off


fill([scale;flipud(scale)],[pavDay1Mean-pavDay1Sem;flipud(pavDay1Mean+pavDay1Sem)],'b','linestyle','-'); % Change values depending on what your cellTraces array is
plot(scale,pavDay1Mean, 'k')
set(gca,'FontSize', 16)
xlabel('Time relative to consumption onset (s)', 'FontSize', 22)
ylabel('Z-score fluorescence','FontSize', 22)
set(gcf, 'Position',  [100, 100, 1500, 800])
xlim([-10 60])
xline(0,'--')
set(gca,'FontName','Arial')
box off

% figure
% imagesc(final(i).unitXTrials(c).startTS.caTraces)