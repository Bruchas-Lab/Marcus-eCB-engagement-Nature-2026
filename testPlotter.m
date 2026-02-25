m = 1;

%%
for m = 1:length(mouseData)
    cellTraces = mouseData(m).ca.allNormTraces;
    timeTrace = mouseData(m).ca.timeTrace;
    behavTrace = mouseData(m).behav.trial.trace;
    for c = 1:length(cellTraces)
        cellTrace = cellTraces(c,:);
        plot(timeTrace, behavTrace)
        hold
        plot(timeTrace,cellTrace)
        pause
        hold 
    end
end
        
        