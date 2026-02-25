function [neuron_sorting,ROIs] = TrialType_Sorting(neuron_data,behavior_data,dir_nm)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%   TrialType_Sorting(neuron_data,behavior_data)
%   TrialType_Sorting allows to sort imaging data based on the behavior
%   trial types, e.g., % 0: Active avoidance; 1: Reward approaching; 2: White noise reference
% 
%  Inputs (required):
%   - neuron_data:  data were extracted by using 'demo_large_data_1p' or
%                   were saved by 'Plot1Pdata'
%   - behavior_data: data from Bpod
%   - dir_nm: the directory to save data
%
%  Outputs:
%   - neuron_sorting data: all neurons were sorted based on the trial types
%   - neuron_sorting figure
%   - ROIs: ROI matrix of each detected neuron
%   - ROIs figure

neuron = neuron_data;
SessionData = behavior_data.SessionData;
TrialTypes = SessionData.TrialTypes;

 %% do trial sorting and save data
  C = neuron.C;
  [B I] = sort(TrialTypes);
  nTrials = length(TrialTypes);
  for ROI_num = 1: size(C,1)
      temp = reshape(C(ROI_num,:),length(C(ROI_num,:))/nTrials,nTrials); % sort C
      temp_sort = temp(:,I);
      temp_trace = reshape(temp_sort,1,size(temp_sort,1)*size(temp_sort,2));
      C2(ROI_num,:) = temp_trace;
  end
  neuron_sorting = neuron;
  neuron_sorting.C = C2;
  cd(dir_nm)
  save neuron_sorting neuron_sorting
  
 %% plot and save heatmap of each sorted neuron 
 
 mkdir('neuron_sorting');
 cd([dir_nm,'\neuron_sorting'])
   for i = 1: size(C2,1)
       temp = reshape(C2(i,:),length(C2(i,:))/nTrials,nTrials);
       h = figure; imagesc(temp');
       set(gca,'FontSize',8)
       xlabel('Frame #','fontsize',8)
       ylabel('Trial #','fontsize',8)
       colorbar
       filename = ['neuron',num2str(i)];
       saveas(h,filename)
       close gcf
   end
   %%  plot and save ROI map
%    cd(dir_nm)
   A = full(neuron_sorting.A);
   for i = 1:size(A,2) % ROIs is your 3D data, containing all ROIs, with 1st D width, 2nd D length, 3rd D is your ROIs number
       ROI = reshape(A(:,i),size(neuron_sorting.Cn,1),size(neuron_sorting.Cn,2));
       temp = zeros(size(ROI));
       temp(ROI > mean2(ROI) + 15*std2(ROI)) = 1;
       ROIs(i,:,:) = temp;
   end
   ROI_all = sum(ROIs,1);
   ROI_all = reshape(ROI_all,size(ROI_all,2),size(ROI_all,3));
   ROI_all(ROI_all>1) = 1;
   h1 = figure; imshow(ROI_all,[0 1.5])
   filename = ['ROIs'];
   saveas(h1,filename)
   save ROIs ROIs

end

