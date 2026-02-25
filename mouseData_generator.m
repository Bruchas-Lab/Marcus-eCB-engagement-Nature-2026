%% This script takes sorted matlab final files and the GPIO file for OG-LED times
% requires both the final sorted MAT file and the GPIO CSV file to have the
% exact same name, other than the extension (e.g. 154233.mat and
% 154233.csv)
%%
curFolder = uigetdir; %navigate to the folder with all your files
list = dir(curFolder); %grab a directory of the foldercontents
folderMask = ~[list.isdir]; %find all of the folders in the directory and remove them from the list
files = list(folderMask);  %now we have only files to work with
cd(curFolder)
clear folderMask list

%now we can sort the files into subtype
idx = ~cellfun('isempty',strfind({files.name},'.mat')); %find the instances of .mat in the file list.
%This command converts the name field into a cell array and searches
%the cell array with strfind
matFiles = files(idx); %build a mat file index
clear idx

idx = ~cellfun('isempty',strfind({files.name},'.xlsx')); %find the instances of .xlsx in the file list.
%This command converts the name field into a cell array and searches
%the cell array with strfind
xlsxFiles = files(idx); %build a mat file index
clear idx

cd(curFolder)
%% SANITY CHECK - do the numbers of mat files and behavior entries add up?  Is there a behavior entry for every mat file
if isequal(length(matFiles), length(xlsxFiles)) == false
    error('Unequal number of mat and csv files.  You are missing a file in your data folder.');
end
%%
for i = 1:length(matFiles)
    currentMatFile = matFiles(i).name;
    currentXlsxFile = xlsxFiles(i).name;
    calciumData = load(currentMatFile);
    %     behavData = importdata(currentXlsxFile,',',1);
    cd
    clear filename
    
    %% get feed time stamp, need to use this strategy due to uneven column lengths
    behav.trial.startTS = xlsread(currentXlsxFile,'A:A'); %trial onset
    behav.trial.stopTS = xlsread(currentXlsxFile,'B:B'); %trial offset
    %     behav.bout.startTS = xlsread(currentXlsxFile,'C:C'); %bout onset
    %     behav.bout.stopTS = xlsread(currentXlsxFile,'D:D'); %bout offset
    %     behav.groom.startTS = xlsread(currentXlsxFile,'E:E');
    %     behav.groom.stopTS = xlsread(currentXlsxFile,'F:F');
    %     behav.sniff.startTS = xlsread(currentXlsxFile,'G:G');
    %     behav.sniff.stopTS = xlsread(currentXlsxFile,'H:H');
    %     behav.rear.startTS = xlsread(currentXlsxFile,'I:I');
    %     behav.rear.stopTS = xlsread(currentXlsxFile,'J:J');
    
    %% Getting calcium time vector and calcium dataa
    for b = 1:size(calciumData.neuron.C,2)
        timeVector(b) = b*(1/(calciumData.neuron.Fs));
    end
    caTime = timeVector;
    clear b
    %%
    behaviorTrace = zeros(1,length(caTime));
    %now we can add in the 1s
    startTimeStamp = behav.trial.startTS;
    stopTimeStamp = behav.trial.stopTS;
    
    for p = 1:length(startTimeStamp)
        
        [idxStart idxStart] = min(abs(caTime-startTimeStamp(p))); %grab the index for when the current grooming bout starts
        [idxStop idxStop] = min(abs(caTime-stopTimeStamp(p))); %index for when the bout stops
        
        for q = 1:idxStop-idxStart+1
            behaviorTrace(q-1+idxStart) = 1;
        end
        clear q idxStart idxStop
    end
    behav.trial.trace = behaviorTrace;

    %% Normalize all calcium traces to themselves to 0 everyhing
    for z = 1:size(calciumData.neuron.C_raw,1)
        calcium.caData(z).rawTrace = calciumData.neuron.C_raw(z,:);
        calcium.caData(z).deconTrace = calciumData.neuron.C(z,:);
        calcium.caData(z).eventTrace = full(calciumData.neuron.S(z,:)); %full to change sparse double to double
        calcium.caData(z).normalizedTraceZ = normalize(calciumData.neuron.C_raw(z,:),2);
        calcium.caData(z).normalizedTrace =  (calciumData.neuron.C_raw(z,:) - (mean(calciumData.neuron.C_raw(z,:))/std(calciumData.neuron.C_raw(z,:))));
        calcium.allNormTraces(z,:) = calcium.caData(z).normalizedTrace;
        calcium.timeTrace = caTime;
        calcium.Fs = calciumData.neuron.Fs;
        calcium.PNR = calciumData.PNR;
        calcium.neuron = calciumData.neuron;
        calcium.caData(z).Coor = calciumData.Coor(z);
    end
    clear z
    %% making data file
    
    mouseData(i).fileName = currentMatFile;
    mouseData(i).behav = behav;
    mouseData(i).ca = calcium;
    clear  m
    
    clearvars -except mouseData csvFiles matFiles files xlsxFiles sortCellPavD1Traces sortCellPavD5Traces
end
mkdir('processedData');
cd('processedData');
save('mouseData.mat', 'mouseData', '-v7.3');  %save the mat file

clear csvFiles xlsx files matFiles xlsxFiles