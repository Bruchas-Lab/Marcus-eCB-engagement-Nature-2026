%% Created and modified by Vaibhav Konanur
%   Roitman Lab
%   1007 W Harrison St.
%   Room 1066
%   Chicago, IL 60607
%   Phone: 312-996-8658
%   email: vkonan2@uic.edu
%   Edits by Patrick Piantadosi (Holmes lab)
%% LOAD DATA
tic
clear all
reset(gca)
reset(gcf)
close all
clc

clip = 0; % 200 % seconds to clip off the front end of the data
filename = 'E:\Videos and photometry traces\C1_M1M2_PAV5-200623-100148';% insert file path here
v1 = strcat(filename,'Daniel_2mice-190722-131320_C1_M1M2_PAV5-200623-100148_Cam1.avi'); %set path for video file
cd(filename);
% filename_split = strsplit(filename, '-');
animalID = 'C1_M1_PavD5'; %input animal ID
% pathname = filename(1:(end-11)) % replace this with the path for the folder containing the block

%load data
trialdata=load('E:\Videos and photometry traces\C1_M1M2_PAV5-200623-100148\REALDATA.mat');


timestep = 20; % Smaller number = higher resolution data and video
% pletno = [2 4 7]; % these are the event numbers of the trials that want to be viewed
% time of window
ws = -10; % window around the event (seconds before) -3
we = 10; % seconds after event 10
%% SET VARIABLES

fsg1=531; % sampling rate
data.sig = trialdata.trialdata.trialdata.data1; % 465nm signal vector
% data.sig = double(data.streams.(STREAM_STORE2).data((clip*fsg1):(end-(clip*fsg1)))'); % 465nm signal vector
% data.baq = double(data.streams.(STREAM_STORE1).data((clip*fsg1):(end-(clip*fsg1)))'); % 405nm signal vector
wsall =  trialdata.trialdata.trialdata.startframes; % desired window start
weall =  trialdata.trialdata.trialdata.stopframes; % desired window end
% data.entry = ceil(((data.epocs.entry.onset).*fsg1)-(clip*fsg1)); % head entries vector
% data.trainOn = ceil(((data.epocs.Lver.onset).*fsg1)-(clip*fsg1)); % event vector
% pletno = 1:length(data.trainOn)-1;
% v1 = 'RRD53 Risk D1 0.1 mA 05232019 (1).mp4'; %([pathname,filename(end-10:end),'\patrick-181217-095111_RRD34-190411-130404',filename(end-17:end-12),'_',filename(end-10:end),'_Cam1.avi']) % set path of video file
%info = aviinfo(v1) % display info for avi
%%
for w=1:length(wsall)
obj1 = VideoReader(v1); % read in avi as object

OGdatalength = length(data.sig);
%OGvidlength = info.NumFrames;
OGvidlength = obj1.FrameRate(1)*obj1.Duration; %read frames for .mp4s
moddatalength = length(data.sig);
nspf = OGdatalength/OGvidlength;

tg1 = (0:1/fsg1:((numel(data.sig)-1)/fsg1))'; % time vector

%% SET WINDOW BOUNDS TO VIEW

    ws = wsall(w);
    we = weall(w);
    wt = we-ws; % range of window
    
    % pellet window
    
    %viewstart = (ceil(ws*fsg1)); %start
    viewstart = ws; %start
    %viewend = (ceil(we*fsg1)); %end
    viewend = we; %end
    wlength = viewend - viewstart; %window length
    % data window
    
    wdata_470 = zeros(length(data.sig(viewstart(1):viewend(1))), length(wlength));
    tw_test = zeros(length(tg1(viewstart(1):viewend(1))), length(wlength));
    
    wdata_470 = data.sig(viewstart:viewend) - min(data.sig(viewstart:viewend)); % snip out windows of 465 data
    tw_test = tg1(viewstart:viewend);
    
    frame_sample = size(read(obj1,1)); % video frame size
    tw = (0:(frame_sample(2))/(size(wdata_470,2)-1):frame_sample(2))'; % time vector of window
    %tw_test1 = (0:(wt)/(size(wdata_470,1)-1):wt)'; %this time vector seems better PTP
    % % entry
    % entry_log = zeros(length(data.sigfilt),1);
    % % entry_log(data.entry) = 1;
    
    % eap = zeros(length(data.sigfilt(viewstart(1):viewend(1))), length(tw));
    % for a = 1:length(tw)
    %     eap(:,a) = entry_log(viewstart(a):viewend(a));
    % end
    % eap_shft = (min(data.sigfilt)-1);
    % eap = (eap.*(2))+eap_shft;
    % eap(eap==+eap_shft) = NaN;
    % if isempty(eap(~isnan(eap)))==1
    % else
    %     eap1=eap(~isnan(eap));
    %     eap1=eap1(1);
    %     asdf=find(~isnan(eap)==1);
    %     eap2=eap;
    %     for abc = 1:numel(asdf)-1
    %         eap2(asdf(abc):asdf(abc)+111)=eap1;
    %     end
    %     eap=eap2;
    % end
    
    
    f_idx = 1;
    wd_idx = 1;
    SP = ((wt-we)/wt)*frame_sample(2);
    tracestep = -500;
    entrystep = tracestep;
    imstep = 0;
    tracefactor = 50; %scale the signal in frame
    
    %%
    % wdata_dFF = (wdata_470 - median(wdata_405))/median(wdata_405);
    
    %%
    % line 116 changed from viewend to moddatalength
    %line 130 changed from viewstart(a):timestep:viewend(a); to
    %viewstart(a):timestep:moddatalength(a)
    %for a = 1:wlength %viewend
    figure(w)
    hold on;
    curve = animatedline('LineWidth',1,'Color','w');
    curve2 = animatedline('LineWidth',1,'Color','c');
    %     curve3 = animatedline('lineWidth',1,'Color','m'); %sean added df/f trace
    stepup = 0;
    %     enttxt1 = text(0,entrystep-75,'Head','color','c','VerticalAlignment','bottom');
    %     enttxt2 = text(0,entrystep-75,'Entry','color','c','VerticalAlignment','top');
    %     cuetxt1 = text(SP,entrystep-75,'Light','color','r','VerticalAlignment','bottom','HorizontalAlignment','center');
    %     cuetxt2 = text(SP,entrystep-75,'Cue','color','r','VerticalAlignment','top','HorizontalAlignment','center');
    line([SP SP],[entrystep-50 imstep-25],'Color',[1 0 0],'LineWidth',3);
    line([tw(end-fsg1) tw(end)],[entrystep-50 entrystep-50],'Color','w','LineWidth',3);
    lejtxt = text((tw(end)-((tw(end)-tw(end-fsg1))/2)),entrystep-50,'1 sec','color','w','VerticalAlignment','top','HorizontalAlignment','center');
    for idx = viewstart:timestep:viewend;
        figure(w)
        hold on
        set(gca,'XLim',[tw(1) tw(end)],'FontSmoothing', 'off');
        %set(gca,'XLim',[tw(1) tw(end)],'YLim',[tracestep*2 frame_sample(1)],'FontSmoothing', 'off');
        set(gcf,'Position',[30  30  600   800],'color','k'); %680   354   560   624
        frame = ceil((idx+(clip*fsg1)-1)/nspf);
        disp(frame)
        frame1 = read(obj1,frame);
        J = imtranslate(flipud(frame1), [0 -imstep], 'FillValues',255,'OutputView','full');
        image(J)
        axis off
        idx = idx-viewstart+1;
        addpoints(curve,tw(idx),(wdata_470(1,idx)*tracefactor)+tracestep);
        %         addpoints(curve3,tw(idx),(wdata_dFF(idx,a)*tracefactor)+tracestep); %sean added df/f trace
        
        drawnow
        figure(w)
        F(f_idx) = getframe(gcf);
        stepup = stepup + timestep;
        f_idx = f_idx + 1;
    end
    delete(lejtxt)
    %     delete(enttxt1)
    %     delete(enttxt2)
    %     delete(cuetxt1)
    %     delete(cuetxt2)
    plot(tw,(wdata_470*tracefactor)+tracestep, 'Color','w');
    clearpoints(curve)
    clearpoints(curve2)
    wd_idx = wd_idx + 1;
    %end
    %%
    %uncomment if you want to write video
    % video = VideoWriter([animalID,'_','behav',num2str(ws(1)),'-',num2str(we(1)),'s_', num2str(filename_split{2}),'_','.avi'],'MPEG-4');%datestr(now,'HHMMSS''.avi')%['pletdrop',num2str(pletno(1)),'_', filename(end-9:end),'.avi']
    video = VideoWriter([animalID,'_','behav',num2str(wsall(w)),'-',num2str(weall(w)),'frames_', '.avi'],'MPEG-4');%datestr(now,'HHMMSS''.avi')%['pletdrop',num2str(pletno(1)),'_', filename(end-9:end),'.avi']
    video.FrameRate = 100/timestep;
    video.Quality = 100;
    open(video)
    writeVideo(video,F)
    close(video)
    clear F
    
end
