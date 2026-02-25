m = 1;
%%
figure
for c = 1:size(final(m).unitAVG.startTS.caTraces,1)
    subplot(234)
    hold
    for i = 1:length(mouseDataMatched(m).ca.caData)
        fill(mouseDataMatched(m).ca.caData(i).Coor{1,1}(1,:), mouseDataMatched(m).ca.caData(i).Coor{1,1}(end,:),'c');
        %             plot(mouseData(m+1).ca.caData(c).Coor{1,1}(1,:), mouseData(m+1).ca.caData(c).Coor{1,1}(end,:),'b');
        set (gca, 'YDir', 'reverse');
    end
     fill(mouseDataMatched(m).ca.caData(c).Coor{1,1}(1,:), mouseDataMatched(m).ca.caData(c).Coor{1,1}(end,:),'r');
        hold
     clear i
    time = (final(m).uv.evtWin(1,1)):0.1:(final(m).uv.evtWin(1,2) - 0.1);
    clims = [-1 5];
    subplot(235)
    imagesc(final(m).unitXTrials(c).startTS.caTraces,clims)
    xticklabels = (final(m).uv.evtWin(1,1)):5:(final(m).uv.evtWin(1,2));
    xticks = linspace(1, length(final(m).unitAVG.startTS.caTraces), numel(xticklabels));
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
    xline(101,'--w')
    colorbar
    set(gca,'FontSize', 12)
    hold
    clims = [-1 5];
    subplot(231)
    hold
    for i = 1:length(mouseDataMatched(m+1).ca.caData)
        %             plot(mouseData(m).ca.caData(c).Coor{1,1}(1,:), mouseData(m).ca.caData(c).Coor{1,1}(end,:),'r');
        fill(mouseDataMatched(m+1).ca.caData(i).Coor{1,1}(1,:), mouseDataMatched(m+1).ca.caData(i).Coor{1,1}(end,:),'c');
        %     text(mean(cellData(i).contour(1,:)),mean(cellData(i).contour(2,:)), num2str(i), 'Color', 'red', 'FontSize', 7);
        set (gca, 'YDir', 'reverse');
    end
    fill(mouseDataMatched(m+1).ca.caData(c).Coor{1,1}(1,:), mouseDataMatched(m+1).ca.caData(c).Coor{1,1}(end,:),'b');
    hold
    clear i
    subplot(232)
    imagesc(final(m+1).unitXTrials(c).startTS.caTraces,clims)
    xticklabels = (final(m+1).uv.evtWin(1,1)):5:(final(m+1).uv.evtWin(1,2));
    xticks = linspace(1, length(final(m+1).unitAVG.startTS.caTraces), numel(xticklabels));
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
    xline(101,'--w')
    colorbar
    set(gca,'FontSize', 12)
    
    day5Trace = final(m).unitAVG.startTS.caTraces(c,:);
    day5Std = nanstd(final(m).unitXTrials(c).startTS.caTraces);
    day5Sem = day5Std / sqrt(size(final(m).unitXTrials(c).startTS.caTraces,1));
    
    
    day1Trace = final(m+1).unitAVG.startTS.caTraces(c,:);
    day1Std = nanstd(final(m+1).unitXTrials(c).startTS.caTraces);
    day1Sem = day1Std / sqrt(size(final(m+1).unitXTrials(c).startTS.caTraces,1));
    
    
%         stressTrace = final(m).unitAVG.startTS.caTraces(c,1:800);
%     stressStd = nanstd(final(m).unitXTrials(c).startTS.caTraces(:,1:800));
%     stressSem = stressStd / sqrt(size(final(m).unitXTrials(c).startTS.caTraces,1));
%     
%     
%     noStressTrace = final(m+1).unitAVG.startTS.caTraces(c,1:800);
%     noStressStd = nanstd(final(m+1).unitXTrials(c).startTS.caTraces(:,1:800));
%     noStressSem = noStressStd / sqrt(size(final(m+1).unitXTrials(c).startTS.caTraces,1));
    
    subplot(2,3,[3 6])
    fill([time';flipud(time')],[day5Trace'-day5Sem';flipud(day5Trace'+day5Sem')],'r','linestyle','-'); % Change values depending on what your cellTraces array is
    hold
    plot(time',day5Trace', 'k')
    fill([time';flipud(time')],[day1Trace'-day1Sem';flipud(day1Trace'+day1Sem')],'b','linestyle','-'); % Change values depending on what your cellTraces array is
    plot(time',day1Trace', 'k')
    xline(0,'--')
    disp(c)
    set(gcf, 'Position',  [200, 200, 1600, 750])
    set(gca,'FontSize', 12)
    box off
    pause
    hold
end
%% cell 95, 144 for activated