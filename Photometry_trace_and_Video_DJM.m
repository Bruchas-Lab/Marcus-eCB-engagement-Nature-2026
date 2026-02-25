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

clip = 1; % 200 % seconds to clip off the front end of the data 
filename = 'E:\Videos and photometry traces\NAcGeCB_M4M2_Pav5-220415-105638';% insert file path here
v1 = strcat(filename,'\Raaj_twomice_experiment-210821-140530_NAcGeCB_M4M2_Pav5-220415-105638_Cam2.avi'); %set path for video file
cd(filename);
filename_split = strsplit(filename, '-');
animalID = 'NAcGRABeCB_M2_PavD5'; %input animal ID
pathname = 'NAcGeCB_M4M2_Pav5-220415-105638' % replace this with the path for the folder containing the block
data=TDTbin2mat(filename); % load tdt file
timestep = 75; % Smaller number = higher resolution data and video
% pletno = [2 4 7]; % these are the event numbers of the trials that want to be viewed
% time of window
% ws = 2730; % window around the event (seconds before) -3
% we = 2760; % seconds after event 10
%%
Sensor = input('Please enter name of sensor used (A,B, C, D, or A_2): \n','s'); %input which sensor the mouse was recorded from 

if Sensor =='A'
    Sensor = 'A';
elseif Sensor =='B'
    Sensor = 'B';
elseif Sensor == 'C'
    Sensor = 'C';
elseif Sensor == 'D'
    Sensor = 'D';
elseif Sensor =='A_2';
    Sensor = 'A_2';
end

% if Sensor == 'A';
%     timeStart=data.epocs.TTL_.onset(1);
% elseif Sensor == 'B';
%     timeStart=data.epocs.TTL_.onset(1);  
% elseif Sensor == 'C';
%     timeStart=data.epocs.TTL_.onset(1);
% elseif Sensor == 'D';
%     timeStart=data.epocs.TL2_.onset(1);
% end


if Sensor == 'A';
    STREAM_STORE1 = 'x405A'
    STREAM_STORE2 = 'x465A'
elseif Sensor =='B';
    STREAM_STORE1 = 'x405C'
    STREAM_STORE2 = 'x465C'
elseif Sensor == 'D';
    STREAM_STORE1 = 'd5sP'
    STREAM_STORE2 = 'd0sP'
elseif Sensor == 'C';
    STREAM_STORE1 = '405C'
    STREAM_STORE2 = '465C'
elseif Sensor == 'A_2'
    STREAM_STORE1 = 'x405A'
    STREAM_STORE2 = 'x465A'
elseif Sensor == 'A_3'
    STREAM_STORE1 = 'x405_'
    STREAM_STORE2 = 'x465_'
end

%% SET VARIABLES

fsg1=floor(data.streams.(STREAM_STORE2).fs); % sampling rate
data.sig = double(data.streams.(STREAM_STORE2).data((fsg1):(end-(fsg1))))'; % 465nm signal vector
data.baq = double(data.streams.(STREAM_STORE1).data((fsg1):(end-(fsg1))))'; % 405nm signal vector
% data.sig = double(data.streams.(STREAM_STORE2).data((clip*fsg1):(end-(clip*fsg1)))'); % 465nm signal vector
% data.baq = double(data.streams.(STREAM_STORE1).data((clip*fsg1):(end-(clip*fsg1)))'); % 405nm signal vector
ws = 1020; % desired window start
we = 1060; % desired window end
% ws = 2917; % desired window start
% we = 2947; % desired window end
% data.entry = ceil(((data.epocs.entry.onset).*fsg1)-(clip*fsg1)); % head entries vector
% data.trainOn = ceil(((data.epocs.Lver.onset).*fsg1)-(clip*fsg1)); % event vector
% pletno = 1:length(data.trainOn)-1;
% v1 = 'RRD53 Risk D1 0.1 mA 05232019 (1).mp4'; %([pathname,filename(end-10:end),'\patrick-181217-095111_RRD34-190411-130404',filename(end-17:end-12),'_',filename(end-10:end),'_Cam1.avi']) % set path of video file
info = aviinfo(v1) % display info for avi

obj1 = VideoReader(v1); % read in avi as object

OGdatalength = length(data.streams.(STREAM_STORE2).data);
OGvidlength = info.NumFrames;
% OGvidlength = obj1.FrameRate(1); %read frames for .mp4s
moddatalength = length(data.sig);
nspf = OGdatalength/OGvidlength;

tg1 = (0:1/fsg1:((numel(data.sig)-1)/fsg1))'; % time vector


%% FILTERING RUINS GRABNE DATA
% Filter 465nm data (if you have your own way to normalize data, use your
% own method

[b,a] = butter(1, 0.000000001 , 'high'); % filter out low freq oscillations
[c,d] = butter(1, 0.9,   'low'); % filter out high freq noise, 0.01 for less filtering, 0.001 for more etc.

%use these settings for unfiltered GRAB signal
% [b,a] = butter(1, 0.000000001 , 'high'); % filter out low freq oscillations
% [c,d] = butter(1, 0.9,   'low'); % filter out high freq noise, 0.01 for less filtering, 0.001 for more etc.

    data.sigfilt = filtfilt(b,a,data.sig);
    data.sigfilt = filtfilt(c,d,data.sigfilt);
    data.baqfilt = filtfilt(b,a,data.baq);
    data.baqfilt = filtfilt(c,d,data.baqfilt);




%% SET WINDOW BOUNDS TO VIEW 

wt = we-ws; % range of window

% pellet window

viewstart = (ceil(ws*fsg1)); %start
viewend = (ceil(we*fsg1)); %end
wlength = viewend - viewstart; %window length
% data window


wdata_470 = zeros(length(data.sigfilt(viewstart(1):viewend(1))), length(wlength));
wdata_405 = zeros(length(data.baqfilt(viewstart(1):viewend(1))), length(wlength));
tw_test = zeros(length(tg1(viewstart(1):viewend(1))), length(wlength));

for a = 1:length(wlength)
    wdata_470(:,a) = data.sigfilt(viewstart(a):viewend(a)); % snip out windows of 465 data
    wdata_405(:,a) = data.baqfilt(viewstart(a):viewend(a)); % snip out windows of 405 data
    tw_test(:,a) = tg1(viewstart(a):viewend(a));
end
frame_sample = size(read(obj1,1)); % video frame size
tw = (0:(frame_sample(2))/(size(wdata_470,1)-1):frame_sample(2))'; % time vector of window
% tw_test1 = (0:(wt)/(size(wdata_470,1)-1):wt)'; %this time vector seems better PTP
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
tracestep = -300;
entrystep = tracestep;
imstep = 0;
tracefactor = 800;
; %scale the signal in frame

%%
wdata_dFF = (wdata_470 - median(wdata_405))/median(wdata_405);

%%
% line 116 changed from viewend to moddatalength
%line 130 changed from viewstart(a):timestep:viewend(a); to
%viewstart(a):timestep:moddatalength(a)
for a = 1:length(wlength) %viewend
    figure(1)
    hold on;
    curve = animatedline('LineWidth',1,'Color','w');
    curve2 = animatedline('LineWidth',1,'Color','c');
    curve3 = animatedline('lineWidth',1,'Color','m'); %sean added df/f trace
    stepup = 0;
%     enttxt1 = text(0,entrystep-75,'Head','color','c','VerticalAlignment','bottom');
%     enttxt2 = text(0,entrystep-75,'Entry','color','c','VerticalAlignment','top');
%     cuetxt1 = text(SP,entrystep-75,'Light','color','r','VerticalAlignment','bottom','HorizontalAlignment','center');
%     cuetxt2 = text(SP,entrystep-75,'Cue','color','r','VerticalAlignment','top','HorizontalAlignment','center');
    line([SP SP],[entrystep-50 imstep-25],'Color',[1 0 0],'LineWidth',3);
    line([tw(end-fsg1) tw(end)],[entrystep-50 entrystep-50],'Color','w','LineWidth',3);
    lejtxt = text((tw(end)-((tw(end)-tw(end-fsg1))/2)),entrystep-50,'1 sec','color','w','VerticalAlignment','top','HorizontalAlignment','center');
    for idx = viewstart(a):timestep:viewend(a);
        figure(1)
        hold on
        set(gca,'XLim',[tw(1) tw(end)],'FontSmoothing', 'off');
        %set(gca,'XLim',[tw(1) tw(end)],'YLim',[tracestep*2 frame_sample(1)],'FontSmoothing', 'off');
        set(gcf,'Position',[30  30  600   800],'color','k'); %680   354   560   624
        frame = ceil((idx+(clip*fsg1)-1)/nspf);
        frame1 = read(obj1,frame);
        J = imtranslate(flipud(frame1), [0 -imstep], 'FillValues',255,'OutputView','full');
        image(J)
        axis off
        idx = idx-viewstart(a)+1;
        % addpoints(curve,tw(idx),(wdata_470(idx,a)*tracefactor)+tracestep);
        % addpoints(curve2,tw(idx),(wdata_405(idx,a)*tracefactor)+tracestep);
        addpoints(curve3,tw(idx),(wdata_dFF(idx,a)*tracefactor)+tracestep); %sean added df/f trace
        
        drawnow
        figure(1)
        F(f_idx) = getframe(gcf);
        stepup = stepup + timestep;
        f_idx = f_idx + 1;
    end
    delete(lejtxt)
%     delete(enttxt1)
%     delete(enttxt2)
%     delete(cuetxt1)
%     delete(cuetxt2)
    % plot(tw,(wdata_470(:,1:wd_idx)*tracefactor)+tracestep, 'Color','w');
    % plot(tw,(wdata_405(:,1:wd_idx)*tracefactor)+tracestep, 'Color','c');
    % plot(tw,(wdata_dFF(:,1:wd_idx)*tracefactor)+tracestep, 'Color','b');
    % clearpoints(curve)
    % clearpoints(curve2)
    % clearpoints(curve3)
    wd_idx = wd_idx + 1;
end
%%
%uncomment if you want to write video
video = VideoWriter([animalID,'_','behav',num2str(ws(1)),'-',num2str(we(1)),'s_', num2str(filename_split{2}),'_','.avi'],'MPEG-4');%datestr(now,'HHMMSS''.avi')%['pletdrop',num2str(pletno(1)),'_', filename(end-9:end),'.avi']
video = VideoWriter([animalID,'.avi'],'MPEG-4');%datestr(now,'HHMMSS''.avi')%['pletdrop',num2str(pletno(1)),'_', filename(end-9:end),'.avi']
video.FrameRate = ceil(fsg1/timestep);
video.Quality = 100;
open(video)
writeVideo(video,F)
close(video)


