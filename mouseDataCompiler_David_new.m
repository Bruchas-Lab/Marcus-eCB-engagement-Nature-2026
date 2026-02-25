%%

%%
%user variables, can be modified
uv.evtWin = [-10 60]; %change size of window around behav (do not change -10, feel free to change max val)
uv.dt = 0.1;
uv.behav = 'trial'; %which behavior do you want to look at?
uv.caTrace = 'rawTrace'; %which type of calcium data?
%% modify at your own risk below
for i = 1:length(mouseData)
    behav = mouseData(i).behav.(uv.behav); %Need to change this to loomS or loomNS
    ca = mouseData(i).ca.caData;
    caTime = mouseData(i).ca.timeTrace;
    
    evts = fieldnames(behav);
    %calculate time windows for each event
    evtWinSpan = max(uv.evtWin) - min(uv.evtWin);
    numMeasurements = evtWinSpan/uv.dt;
    time = uv.evtWin(1,1):uv.dt:uv.evtWin(1,2)-uv.dt;
%     for e = 1:size(evts,1)                                                      %for each event
%         evtWinIdx.(evts{e}) = time >= uv.evtSigWin.(evts{e})(1,1) &...          %calculate logical index for each event period
%             time <= uv.evtSigWin.(evts{e})(1,2);
%     end
    %%
    tic
    for u = 1:length(ca)
        unitTS = ca(u).eventTrace;
        idx = unitTS ~= 0;                                              %logical index events (non-zero time bins)
        unitTS = caTime(idx); 
        unitTrace = ca(u).(uv.caTrace);
        clear idx
        for e = 1:2%size(evts,1)
            eTS = behav.(evts{e});
            %% initialize trial matrices
            caEvtCtTrials = NaN(size(eTS,1),numMeasurements);                   %initialize trial x time calcium event count matrix
            caTraceTrials = NaN(size(eTS,1),numMeasurements);
            %%
            for t = 1:size(eTS,1)
                 %% set each trial's temporal boundaries
                timeWin = [eTS(t)+uv.evtWin(1,1):uv.dt:eTS(t)+uv.evtWin(1,2)];  %calculate time window around each event
                if min(timeWin) > min(caTime) & max(timeWin) < max(caTime)    %if the beginning and end of the time window around the event occurred during the recording period. if not, the time window is out of range
                    %% get unit event counts in trials
                    caEvtCtTrials(t,:) = histcounts(unitTS,timeWin);            %histogram counts of ca event times within each time bin
                    %% get unit ca traces in trials
                    idx = caTime > min(timeWin) & caTime < max(timeWin);      %logical index of time window around each behavioral event time
                    %caTraceTrials(t,1:sum(idx)) = unitTrace(idx);               %store the evoked calcium trace around each event   (see below, comment out if dont want normalized to whole trace)
                    caTraceTrials(t,1:sum(idx)) = unitTrace(idx); 
                                     
                end
            end
            clear t timeWin idx eTS
            %% convert counts to rate
            caEvtRateTrials = caEvtCtTrials/uv.dt;
            %% store trial by trial data
            unitXTrials(u).(evts{e}).caEvtCts = caEvtCtTrials;                  %store evoked calcium event counts over all trials
            unitXTrials(u).(evts{e}).caEvtRate = caEvtRateTrials;               %store evoked calcium event rates over all trials
            unitXTrials(u).(evts{e}).caTraces = caTraceTrials;
           
            %% store unit averaged data
            if size(caTraceTrials,1) == 0
                [];
            elseif size(caTraceTrials,1) == 1 % if only one behavioral event direct transfer do not average
            unitAVG.(evts{e}).caEvtCts(u,:) = caEvtCtTrials;           %store trial averaged event counts
            unitAVG.(evts{e}).caEvtRates(u,:) = caEvtRateTrials;       %store trial averaged event rates
            unitAVG.(evts{e}).caTraces(u,:) = caTraceTrials;           %store trial averaged calcium traces
            else
            unitAVG.(evts{e}).caEvtCts(u,:) = nanmean(caEvtCtTrials);           %store trial averaged event counts
            unitAVG.(evts{e}).caEvtRates(u,:) = nanmean(caEvtRateTrials);       %store trial averaged event rates
            unitAVG.(evts{e}).caTraces(u,:) = nanmean(caTraceTrials); 
            end %store trial averaged calcium traces
           
            clear caEvtCtTrials caTraceTrials caEvtRateTrials
        end
                clear u unitTS unitTrace
    end
    clear e eTS evts numMeasurements
    toc
    final(i).name = mouseData(i).fileName;
    final(i).time = time;
    final(i).unitAVG = unitAVG;
    final(i).unitXTrials = unitXTrials;
    final(i).uv = uv;
    clear evtWinIdx nullDistEvtRate nullDistTrace respClass time unitAVG unitXTrials unitSD unitAverage evtWinSpan ca behav i
end
clear uv

    
    