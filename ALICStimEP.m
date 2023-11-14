% Author: S. N. Pitts
% Created: 07-14-2022
% Author: S.N. Pitts
% Load subject from chosen file
% find stim artifacts and classify them
%dataset: ALIC Lab DBS Stim EP(EEG)
clear all
close all
%% EDIT: CONDITIONS
%PIN_RING_LEFT
% conditions = {
% "LE03"
% "LE02"
% "LE01"
% "LE00"};

% % PIN_RING_RIGHT
% conditions = {
% "RE11"
% "RE10"
% "RE09"
% "RE08"};


% % %PING_RING_MONOPOLAR
% conditions = {
% "LE03"
% "LE02"
% "LE01"
% "LE00"
% "RE11"
% "RE10"
% "RE09"
% "RE08"};

% 
% % PING_SEG_LEFT
% conditions = {
% "LE2a"
% "LE2b"
% "LE2c"
% "LE1a"
% "LE1b"
% "LE1c"
% };

% %PING_SEG_RIGHT
% conditions = {
% "R10a"
% "R10b"
% "R10c"
% "RE9a"
% "RE9b"
% "RE9c"};

% % DOSE SWEEP 202/209
% conditions = {
% "L3_0"
% "L3_5"
% "L4_0"
% "L4_5"
% "L5_0"
% "L5_5"
% "L6_0"
% "L6_5"
% };


% % %DOSE SWEEP 206 t3
conditions = {
"L3_0"
"L4_0"
"L5_0"
"L3_5"
"L4_5"
"L5_5"
"L6_0"
"L6_5"
};



% %DOSE SWEEP 206 + 207
% conditions = {
% "L3_5"
% "L4_0"
% "L4_5"
% "L5_0"
% "R3_5"
% "R4_0"
% "R4_5"
% "R5_0"
% };

% %DOSE SWEEP 201
% conditions = {
% "R2_5"
% "R3_0"
% "R3_5"
% "R4_0"
% "R4_5"
% "R5_0"
% };

% %DOSE SWEEP L201
% conditions = {
% "L2_5"
% "L3_0"
% "L3_5"
% "L4_0"
% "L4_5"
% "L5_0"
% };

% %DOSE SWEEP 208T0
% conditions = {
% "LE2a"
% "LE2b"
% "LE2c"
% "LE1a"
% "LE03"
% "LE02"
% "LE01"
% "LE00"
% "RE11"
% "RE10"
% "RE09"
% "RE08"};


%% EDIT: PARAMETERS
% Select the channel you want to use for peak detection:
% DEFAULT
% chan_spec = 15;
% Sample_rate = 1000;
% k = 5; %moving mean (pre-processing)
% stim = 2;

chan_spec = 165;
%Sample_rate = 250;
Sample_rate = 1000; %EEGSamplingRate
k_window = 5; %moving mean
stim = 2; %Stim frequency in Hz , CHANGE for Hz 4



% % Peak Detection Parameters
%DEFAULT
% %'MinPeakDistance' 
% mpd = 475 ;  
% %'MinPeakHeight' 
% mph = 1 ;
% %'MinPeakProminence' 
% mpp = 700; ADJ to 300; 600 at 4 Hz

%Algorithm outlier parameters (change as very last resort only)
n=20; %length of stimulation pulse (number of adjacent peaks to reference) n= 20 default; n=80 for 4 Hz
k=5; %strictness of peak distances to reference and compare; k=1 default;

%'MinPeakDistance' 
mpd = 50; %300;  %Sample_rate/stim-1; %50 for 4Hz
%'MinPeakHeight' 
mph = 500 ;
%'MinPeakProminence' 
mpp = 300;  

%Condition Label Threshold
threshold = 800; %depends on stimulation frequnecy of a pulse (beyond 500); spacing between stim region; 125 for 4Hz 250 Sampling Rate; 600


%% Manual dispose --- EDIT FOR ALGO.  %%%%%%%%%%%%%%%%%%%EDIT%%%%%%%%%%%%%%%%%%%
% Get rid of these peaks from visual
% manual_dispose = [2:5];
% dispose = [dispose,manual_dispose];
% Write disposal at peak x location (in sample # )

%% EDIT

%Add this sample number as a peak
add_peak = [];

%Remove this sample number as a peak
manual_dispose = []; 

%Exclude Stimulation Range, as sample number (inclusive?)
exclude_ranges = [];%
%% Load file of interest
[file, path] = uigetfile;
cd(path)
NetstationFile = load(file);

%% Select Upload Folder
%makes file in data retrieval location
filename = file(1:end-4);
folder = ['StimArtifact_', filename];
mkdir(folder)

%retrieve folder for figure and pipeline output upload
newpath = [path,folder,'/'];
cd(newpath)

%% Load Netstation file, rename some variables, extract channel of interest
% select appropriate file for analysis: ex -  'DBS_ALIC202_PING_Segs_LEFT_20220128_HP_ref.mat'
% prompt = "Enter Subject Number";
% Subject_No = input(prompt);
% disp(Subject_No);

no_of_conditions = length(conditions);
%% Select filename after "NetstationFile" to match field of chosen file's Workspace
filename = [filename, 'mff']; %filename = [filename, 'mff1']; <- if multiple matrices present
%filename = ['ALIC210_T0_PING_RING_right_20230501_031341_bcrmff']; %%EDITED IN %%Copied from NetstationFile variable (click on struct)
Selected_Chan_sin = NetstationFile.(filename)(chan_spec,:); %whos NetstationFile
% to see how the data variable has been titled

% sin stands for single - but later we'll make it a double
Selected_Chan = double(Selected_Chan_sin);

Time = length(Selected_Chan_sin/Sample_rate);

%%%%%%%%%%%%%%%%%%%%%%%%%EDIT START TO SAVE THE
%%%%%%%%%%%%%%%%%%%%%%%%%PIPELINE%%%


%% Make a directory and change it %%%%%%%%%%%%%%%%%

%choose a folder (subject)
%make a folder with pathname
%% Save pre-processed data
f0 = figure

plot(Selected_Chan_sin)

savefig("Raw_Stim")

% now select just the section of interest

%Selected_Chan = Selected_Chan_all(chan_spec,1.77*10^5:2.4*10^5);

%Selected_Chan = Selected_Chan_all;

%% IF Large DC offsets exist, so remove overall DC mean with detrend

% or just apply HP filter before exporting to Matlab

%The beginning or end of the file can differ from several orders of

%magnitude/ Detrend function fits a "best fit" line to the data and

% then he moved on

%Selected_Chan = detrend(Selected_Chan(chan_spec,)')'; % works on columns, so transpose to

% % detrend and transpose back

% figure

% plot(Selected_Chan)


close all

%% baselined data overlayed in blue with raw in black
T = timetable(Selected_Chan','SampleRate',Sample_rate,'VariableNames',"Selected_Chan");
T.("Selected_Chan") = T.("Selected_Chan") - movmean(T.("Selected_Chan"),k_window);

f1 = figure 
hold on
plot(T.("Time"),T.("Selected_Chan"),'b')
plot(T.("Time"),Selected_Chan,'k')
xlabel('Time (s)')
ylabel('Voltage (uV)')
legend({'Preprocessed Signal','Raw Signal'})
hold off
savefig("Processed_Stim");
save("Processed_Stim_Table","T",'-mat'); %save environment

% baselined data only
figure
hold on
x = T.("Time");
y = (T.("Selected_Chan"));
plot(x,y)

%% Peak selection algorith

% consider specifing a threshold so that between stims don't get flagged

% can't use 'MinPeakProminence', because zero moves too much - some peaks

% are negative / peaks are relative

% for positive peaks:

%[pks,locs] = findpeaks (Selected_Chan,'MinPeakDistance',475, 'MinPeakHeight',1000);

%[pks,locs] = findpeaks (y,'MinPeakDistance',475, 'MinPeakHeight',5E10); %'MinPeakProminence',

[pks,locs] = findpeaks (y,'MinPeakDistance',mpd, 'MinPeakHeight',mph,'MinPeakProminence',mpp); %400 is original prominence

%% Remove Outliers from R Peaks "locs" -- EDITED 08/09/22

%For Manual peaks
for i = 1:length(manual_dispose)
    idx = find(locs<=manual_dispose(i)+4);
    idx2 = find(locs>=manual_dispose(i)-4);
    idx = intersect(idx,idx2);
    locs(idx) = [];
end

%For range of peaks
range_dispose = 0;
[r,~]=size(exclude_ranges);
index = [];
for i = 1:r %number of ranges to exclude
    
    bound1 = exclude_ranges(i,1);
    bound2 = exclude_ranges(i,2);

    %locate the locations in RPeaks vector and set them to 0
    idx1 = find(locs>=(bound1 -4));
    idx2 = find(locs<=(bound2 +4));
    idx = intersect(idx1,idx2);
    range_dispose = range_dispose + length(idx); 
    
    locs(idx) = []; %empty those bounds
end

%% Add missing peaks
locs = [locs; add_peak];
locs= sort(locs);

pks = y(locs); %edit to reflect removed peaks
%% Calculate outlier stims
%distance to prior peak
before = diff(locs);
before = [0;before];

%distance to peak after
after = abs(diff(flip(locs)));
after = flip(after);
after = [after;0];

%locations table
L = table(locs,before,after);

%% Filter out outlier stims - Test if peak is a part of false pulse
%check nth peak forward and backwards
%Parameter n, assuming there's >= 20 peaks on either side of any given peak
n; %length of stimulation pulse (number of adjacent peaks to reference)
k; %strictness of peak distances to reference and compare
n_dist = (n+1)*Sample_rate/stim; %(n+1)*500; %< 21peaks*500 samples away (1000sf/2Hzstim.), but > 0 %constrains the peak
dispose =[];
tot_peaks = height(L);
for i = 1:tot_peaks
    dist1 = 0;
    dist2 = 0;

    % test if peak is a part of false pulse

          %first layer of checks
          %check peaks after, b/c this could be first peak in condition
          %if c1
              ref = i+(n-k);
    
              %Check next n peaks unless near end of peaks
              if ref>tot_peaks %near end
                  dist1 = sum(L.after(i:end));
              else
                  dist1 = sum(L.after(i:ref)); %check sum of "next 20 peaks values"
              end
         % end
    
          %second layer of checks
          %check peaks before, b/c this could be last peak incondition
         % if  c2
              ref = i-(n-k);
              %Check prior n peaks unless near beg. of peaks
              if ref<1 %near beg.
                  dist2 = sum(L.before(1:i));
              else
                  dist2 = sum(L.before(ref:i)); %check sum of "next 20 peaks values"
              end
  

    c1= dist1 >= n_dist; %check relation to future pulses
    c2= dist2 >= n_dist; %check relation to prior pulses
    c3 = L.("before")(i)==0; %first in section of pulse
    c4 = L.("after")(i)==0; %last in section of pulse
    
     if (c1 && c2)||(c4 && c2)|| (c3 && c1)
        dispose=[dispose, i]; %the order of sample
     end

end

%% Manual dispose execution
% Get rid of these peaks from visual
% manual_dispose = [2:5];
% dispose = [dispose,manual_dispose];

% manual_dispose; %sample number of R peak to remove
% %convert sample 
% 
% for i = 1:length(manual_dispose) %parce through each neg. positive
% 
%     %find the location in R peak vector which corresponds to sample number
%     dispose_sample = find(L.locs==manual_dispose(i));
%     
%     %Test if R peak present in algorithm
%     if length(dispose_sample) > 0
%         %add location to queue for removal
%         dispose = [dispose,dispose_sample]; %location in R peak vector
%     end
% 
% end

%% Plot results

%with peaks in red, de-identified peaks in black
f2 = figure
yyaxis left
plot (Selected_Chan)

hold on

h = plot (locs, Selected_Chan(locs), 'r.', 'markersize', 24)
k = plot (L.locs(dispose),Selected_Chan(L.locs(dispose)), 'k*', 'markersize', 24 )
xlabel('Sample Number')
ylabel('Voltage (uV)')
legend('Raw EEG','Stim Peaks Detected','Deleted Peaks','Condition Marker')
m = (length(manual_dispose)+range_dispose);
str = sprintf("Deleted Peaks, d = %d; Manual deletion, m = %d",length(dispose),m);
title("Stimulation Peaks",str)


%% Plot over processed data
f3 = figure
hold on
yyaxis left
y = (T.("Selected_Chan"));
plot(y)

h = plot (locs, y(locs), 'r.', 'markersize', 24)
k = plot (L.locs(dispose),y(L.locs(dispose)), 'k*', 'markersize', 24 )
xlabel('Sample Number')
ylabel('Voltage (uV)')
legend('Raw EEG','Stim Peaks Detected','Deleted Peaks','Condition Marker')
m = (length(manual_dispose)+range_dispose);
str = sprintf("Deleted Peaks, d = %d; Manual deletion, m = %d",length(dispose),m);
title("Stimulation Peaks",str)
hold off
%% peaks to print modified here
dispose = sort(dispose);
L(dispose,:) = []; %get rid of discounted peaks
% figure 
% plot (Selected_Chan)
% hold on
% j = plot (L.locs, Selected_Chan(L.locs), 'r.', 'markersize', 24)
%% Create Epochs
%%EDIT count start to 0 if we need to omit first run; 
Cond_Nums = zeros(height(L),1);
count = 1;
threshold; %= 600; %depends on stimulation frequnecy of a pulse (beyond 500)
for k = 1:height(L)
    if k~=1 && L.before(k)>threshold %%new edit is k~=1
        count = count+1; 
    end
    Cond_Nums(k) = count;
end
L = addvars(L,Cond_Nums);

%plot epoch 
figure(f2)
hold on
yyaxis right
plot(L.locs,L.Cond_Nums, 'p')
ylabel('Condition No.')
hold off
savefig("Peaks_and_de-identified")
save("Peaks_and_de-identified_table","L","-mat")



%% Plot over processed data

figure(f3)
hold on
yyaxis right
plot(L.locs,L.Cond_Nums, 'p')
ylabel('Condition No.')
hold off
savefig("Processed_Peaks_and_Conditions")

%%

% for negative peaks:

% [pks, locs] = findpeaks (-Selected_Chan,'MinPeakDistance',475, 'MinPeakHeight',20);

% figure

% plot (Selected_Chan)

% hold on

% h =plot (locs, -pks, 'r.', 'markersize', 24)

%% Export logical for entire recording indicating peaks

% Export_Peaks=locs';

%It would be cool to select out the locs that are spurious, based on an

%index from where the conditions begin

%%%%%%% hold off for now
% dlmwrite('Peaks_ALIC202_T0_SEGS_LEFT.txt', locs', 'precision', 9)
%%%%%%%

%Now you've got to go into excel and change to format HH:MM:SS.000

%Ideally you would accomplish that here.

% xlswrite('Peak_Locations.xlsx', locs')

% Peak_samplesNo = [1:length(Selected_Chan)];

% Peak_samples_logical = pks>40;

% sum(Peak_samples_logical)


%% Format Peaks Via NetStation 
Peaks_NS = L.locs;

%%% Time for NS
Peaks_NS; %locations of R peaks;
Peaks_NS = (Peaks_NS - 1); %NS adjusted peaks (for visual purposes);
time_NS = seconds(Peaks_NS/Sample_rate); %into sec per Sample Rate
time_NS_formatted = duration(time_NS,'Format','hh:mm:ss.SSS'); %formatted NS times

%%% Print all peaks
filename = sprintf("NS_%s.txt",folder); 

fileID = fopen(filename,'w');
fprintf(fileID,'%d\n',Peaks_NS);
fclose(fileID);

%%% Print NetStation Times
%%%MAY HAVE TO CHANGE EPOCH NUMBER HERE
epoch_no = 1;
filename = sprintf("NS_String_%s.txt",folder); 

fileID = fopen(filename,'w');
time = string(time_NS_formatted);
for i = 1:length(Peaks_NS)
    fprintf(fileID,'_[%d] %s\n',epoch_no,time(i));
end
fclose(fileID);


%%% Print Labels
filename = sprintf("NS_Label_%s.txt",folder); 

fileID = fopen(filename,'w');
for i = 1:height(L)
    if L.Cond_Nums(i)>0 && L.Cond_Nums(i)<= length(conditions)
        fprintf(fileID,'%s\n',conditions{L.Cond_Nums(i)});
    end
end
fclose(fileID);

%%% Save Parameters in a text file for future reference
filename = sprintf("NS_Parameters_%s.txt",folder); 

fileID = fopen(filename,'w');

fprintf(fileID,'Channel: %d\n Sample Rate: %d\n K Moving Mean Window: %d\n MinPeakDistance: %d\n MinPeakHeight: %d\n MinPeakProminence: %d\n'...
    ,chan_spec, Sample_rate, k, mpd, mph, mpp);
  
fclose(fileID);


%% Check surrounding peaks that are within ___ ms ()
% Issue: There are small peaks that are getting identified inbetween
% experiments: we should take note of peaks/samples that are eliminated???




