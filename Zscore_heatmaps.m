function [data] = Zscore_heatmaps(neuron_sorting,dir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Zscore 
% Inputs ----  neuron_sorting
% Inputs ----  dir
% Outputs ---- heatmap
% Outputs ---- pval
% Outputs ---- ind
%% clear all except
clearvars -except neuron_sorting
%% put the directory you want to save the data and figures
cd(dir)
%% combine neurons from different mice together
C = neuron_sorting7.C;
%----------------------------------------------------------------------------------------------------------------------
InputData.C = C;
%----------------------------------------------------------------------------------------------------------------------
AUC.InputData = InputData;
%% define parameters here
Parameter.ZscoreType = 2; % 1: normalized by baseline before stimuli; 2: normalized by all 
Parameter.TestType = 3; % 1 for permutation test; 2 for rank sum test; 3 for t student test; 4 for zscore (2*SD)
Parameter.TestWay = 1; % 1 by trials; 2 by averaged traces; 
Parameter.nTrials = 60; % how many trials do you have
Parameter.FrameLength = 200; % how many frames do you have for each trial
Parameter.TrialTypes = 2; % 0: avoidance cue; 1: reward cue; 2: neutral cue
switch Parameter.TrialTypes
    case 0 % avoidance cue
        Parameter.Event_Trial1 = [1 20]; % trial number
    case 1 % reward cue
        Parameter.Event_Trial1 = [21 40]; % trial number
    case 2 % neutral cue
        Parameter.Event_Trial1 = [41 60]; % trial number
end
parameter.CSUS_flag = 2; % 1: CS; 2: CS-US interval (decision window) 3: US
switch parameter.CSUS_flag
    case 1 % CS
        Parameter.baseline = [41 100]; % Frames of baseline window
        Parameter.stimulus = [101 110]; % Frames of stimulus window
    case 2 % CS-US interval (decision window)
        Parameter.baseline = [41 100]; % Frames of baseline window
        Parameter.stimulus = [111 130]; % Frames of stimulus window
    case 3 % US
        Parameter.baseline = [41 100]; % Frames of baseline window
        Parameter.stimulus = [131 140]; % Frames of stimulus window
end
if Parameter.TestType == 1
    Parameter.NUM_ITER = 5000; % iterations for permutation test
end
Parameter.colorR = 28; % for colorspace, do not need to change
Parameter.colorC = 28; % for colorspace, do not need to change
switch Parameter.ZscoreType
    case 1 % 1: normalized by baseline before stimuli; 
        Parameter.brightness = [-8 8]; % trial number
    case 2 % 2: normalized by all 
        Parameter.brightness = [-3 3]; % trial number
end
% Parameter.MeanType = 0; % 0:mean; 1:median
%----------------------------------------------------------------------------------------------------------------------
Data.Parameter = Parameter;
%% average DF by trial and normalize by zscore
for i = 1:size(C,1)  % cell number
    % Run auROC
    temp1 = C(i,:); % all traces per neuron
    temp2 = reshape(temp1,Parameter.FrameLength,Parameter.nTrials); % reshape it
    temp3 = temp2(:,Parameter.Event_Trial1(1):Parameter.Event_Trial1(2)); % data from those trials you selected
    
    temp3p5 = mean(temp3,2);
    switch Parameter.ZscoreType 
        case 1 % 1: normalized by baseline before stimuli; 
         Z = (temp3p5 - mean(temp3p5(Parameter.baseline(1):Parameter.baseline(2))))/std(temp3p5(Parameter.baseline(1):Parameter.baseline(2)));
        case 2 % 2: normalized by all 
         Z = zscore(temp3p5);
    end
    
    DF_zscore(:,i) = Z;
    
  if Parameter.TestWay == 1
       % baseline data as reference
       temp4 = temp3(Parameter.baseline(1):Parameter.baseline(2),:);
       x = temp4(:);
       x = mean(temp4);
       meanpre = mean(x);
       % stimulation data
       temp5 = temp3(Parameter.stimulus(1):Parameter.stimulus(2),:);
       y = temp5(:); 
       y = mean(temp5);
       meanpost = mean(y);
       if meanpre > meanpost % inhibited
           ind(i) = -1;
       elseif meanpre == meanpost % equal
           ind(i) = 0;
       elseif meanpre < meanpost % excited
           ind(i) = 1;
       end
    
        % do statistical testing
        switch Parameter.TestType
            case 1 % run permutation test
                diff = x - y; %difference between conditions
                [p, t_orig, crit_t, est_alpha, seed_state] = mult_comp_perm_t1(diff(:),Parameter.NUM_ITER);
                pval(i) = p;
            case 2 % rank sum test
                p = ranksum(x,y);
                pval(i) = p;
            case 3 % t student test
                [h p] = ttest2(x,y);
                pval(i) = p;
            case 4 % zscore
                if max(Z(Parameter.stimulus(1):Parameter.stimulus(2))) > 2 || max(Z(Parameter.stimulus(1):Parameter.stimulus(2))) < -2
                    pval(i) = 0.01;
                else
                    pval(i) = 1;
                end
        end
  elseif Parameter.TestWay == 2
      % baseline data as reference
       temp4 = temp3p5(Parameter.baseline(1):Parameter.baseline(2),:);
       x = temp4(:);
%        x = mean(temp4);
       meanpre = mean(x);
       % stimulation data
       temp5 = temp3p5(Parameter.stimulus(1):Parameter.stimulus(2),:);
       y = temp5(:); 
%        y = mean(temp5);
       meanpost = mean(y);
       if meanpre > meanpost % inhibited
           ind(i) = -1;
       elseif meanpre == meanpost % equal
           ind(i) = 0;
       elseif meanpre < meanpost % excited
           ind(i) = 1;
       end
    
        % do statistical testing
        switch Parameter.TestType
            case 1 % run permutation test
                diff = x - y; %difference between conditions
                [p, t_orig, crit_t, est_alpha, seed_state] = mult_comp_perm_t1(diff(:),Parameter.NUM_ITER);
                pval(i) = p;
            case 2 % rank sum test
                p = ranksum(x,y);
                pval(i) = p;
            case 3 % t student test
                [h p] = ttest2(x,y);
                pval(i) = p;
            case 4 % zscore
                if max(Z(Parameter.stimulus(1):Parameter.stimulus(2))) > 2 || max(Z(Parameter.stimulus(1):Parameter.stimulus(2))) < -2
                    pval(i) = 0.01;
                else
                    pval(i) = 1;
                end
        end
      
  end
end
%----------------------------------------------------------------------------------------------------------------------
DF_zscore = DF_zscore';
Data.DFzscore = DF_zscore;
Data.pval = pval;
Data.ind = ind;
%% Histogram 
DF_meanzscore = mean(DF_zscore(:,Parameter.stimulus(1):Parameter.stimulus(2)),2);
pv = 0.05;
figure;
h1 = histogram(DF_meanzscore(pval<pv));
hold on
id = find(pval>pv|pval==pv);
h2 = histogram(DF_meanzscore(id));
% h1.Normalization = 'probability';
h1.BinWidth = 0.1;
% h2.Normalization = 'probability';
h2.BinWidth = 0.1;
xlim([-3 3])
ax = gca;
% ax.XTick = [0 0.5 1.0];
% ax.XTickLabel = {'0.0','0.5','1.0'};
xlabel('Zscore')
ylabel('Neuron number')
box off
set(gcf,'color','[1 1 1]')
h_gca = gca;
h_gca.TickDir = 'out';
%% colorspace
colorspace = zeros(64,3); % RGB color space
colorspace(64-Parameter.colorR+1:64,1) = linspace(0,1,Parameter.colorR); % R
colorspace(1:Parameter.colorC,2) = linspace(1,0,Parameter.colorC); % G
colorspace(1:Parameter.colorC,3) = linspace(1,0,Parameter.colorC); % B
%% Sort all cells according to the maximum responses in stimulus window
[B I] = max(DF_zscore(:,Parameter.stimulus(1):Parameter.stimulus(2)),[],2);
[B2 I2] = sort(B);
ranking_data = DF_zscore(flipud(I2),:);
h3 = figure; imagesc(ranking_data,[Parameter.brightness(1) Parameter.brightness(2)]);
colormap(colorspace)
ax = gca;   
ax.XTick = [100 110 130];
ax.XTickLabel = {'0','1','3'};
xlabel('Time (s)')
ylabel('Unit')
box off
set(gcf,'color','[1 1 1]')
set(gca, 'YTick', []);
set(gca,'TickDir','out');
set(gca, 'YTick', []);
% xlim([1 130])
%% Sort all cells according to the mean responses in stimulus window
[B I]= sortrows(mean(DF_zscore(:,Parameter.stimulus(1):Parameter.stimulus(2)),2));
ranking_data = DF_zscore(I,:);
h4 = figure; imagesc(flipud(ranking_data),[Parameter.brightness(1) Parameter.brightness(2)]);
colormap(colorspace)
ax = gca;   
ax.XTick = [100 110 130];
ax.XTickLabel = {'0','1','3'};
xlabel('Time (s)')
ylabel('Unit')
box off
set(gcf,'color','[1 1 1]')
set(gca, 'YTick', []);
set(gca,'TickDir','out');
set(gca, 'YTick', []);
%% Sort all cells according to the time of maximum responses
[B I] = max(DF_zscore(:,41:160),[],2);
[B2 I2] = sort(I,'descend');
ranking_data = DF_zscore(flipud(I2),:);
h5 = figure; imagesc(ranking_data,[Parameter.brightness(1) Parameter.brightness(2)]);
colormap(colorspace)
ax = gca;   
ax.XTick = [100 110 130];
ax.XTickLabel = {'0','1','3'};
xlabel('Time (s)')
ylabel('Unit')
box off
set(gcf,'color','[1 1 1]')
set(gca, 'YTick', []);
set(gca,'TickDir','out');
set(gca, 'YTick', []);
xlim([41 160])
%% save data and figure
clear DF_zscore
switch Parameter.TrialTypes
    case 0 % active avoidance
        mkdir('active avoidance');
        cd([dir,'\active avoidance'])
    case 1 % reward approaching
        mkdir('reward approaching');
        cd([dir,'\reward approaching'])
    case 2 % neutral cue
        mkdir('neutral cue');
        cd([dir,'\neutral cue'])
end
        filename = ['Histograms'];
        saveas(h1,filename)
        filename = ['Heatmap_max'];
        saveas(h3,filename)
        filename = ['Heatmap_mean'];
        saveas(h4,filename)
        filename = ['Heatmap_time'];
        saveas(h5,filename)
        
        save Data Data


end

