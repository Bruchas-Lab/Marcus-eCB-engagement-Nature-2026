
clearvars -except mouseDataMatched final mouseDataNew finalNew
%% pick a mouse
% n = final(1:1);
% m = n
m = 10

%%
figure
for c = 1:size(final(m).unitAVG.startTS.caTraces,1)
    time = final(m).time;
    clims = [-1 5];
    % plot the heatmap for each trial
    subplot(121)
    imagesc(final(m).unitXTrials(c).startTS.caTraces,clims)
    xticklabels = (final(m).uv.evtWin(1,1)):5:(final(m).uv.evtWin(1,2));
    xticks = linspace(1, length(final(m).unitAVG.startTS.caTraces), numel(xticklabels));
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
    xline(101,'--w')
    colorbar
    set(gca,'FontSize', 12)
    hold
    % plot mean trace for that neuron across trials
    trace = final(m).unitAVG.startTS.caTraces(c,:);

    traceStd = nanstd(final(m).unitXTrials(c).startTS.caTraces);

    traceSem = traceStd / sqrt(size(final(m).unitXTrials(c).startTS.caTraces,1));

    subplot(122)
    fill([time';flipud(time')],[trace'-traceSem';flipud(trace'+traceSem')],'b','linestyle','-'); % Change values depending on what your cellTraces array is
    hold
    plot(time',trace', 'k')
    xline(0,'--k')
    set(gcf, 'Position',  [200, 200, 1200, 500])
    set(gca,'FontSize', 12)
    box off
    % pause
    hold
end