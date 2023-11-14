%% DBS Art Event Marker
% S. Pitts 06.07.2022

% Based on A. Waters 01.17.2018

% This code identifies DBS artifact peaks and returns index in a form that

% Netstation can read, for ALIC targeted subjects - Medtronic Pecerpt


%% Predefine Some Variables

% The channel you want to use for peak detection:

chan_spec = 165;

Sample_rate= 1000;

% The name of the file exported from Netstation without file type suffix

% I'll come back to this but hard given name of EEG data in data structure

% Would be cool to have some index, based on file length? to be when

% conditions begin and end.

% nexport_name = ''

%MinPeakHeight - probably different for everyone, so it should be noted?

%% Load Netstation file, rename some variables, extract channel of interest
% select appropriate file for analysis: ex -  'DBS_ALIC202_PING_Segs_LEFT_20220128_HP_ref.mat'

[file, path] = uigetfile;
cd(path)
NetstationFile = load(file);

prompt = "Enter Subject Number";
Subject_No = input(prompt);
disp(Subject_No);

%% EDIT
% %PIN_RING_LEFT
% conditions = {
% "LE03"
% "LE02"
% "LE01"
% "LE00"};

% %PIN_RING_RIGHT
% conditions = {
% "RE11"
% "RE10"
% "RE09"
% "RE08"};

% %PING_RING_MONOPOLAR
% conditions = {
% "LE03"
% "LE02"
% "LE01"
% "LE00"
% "RE11"
% "RE10"
% "RE09"
% "RE08"};

%PING_SEG_LEFT
conditions = {
"LE2a"
"LE2b"
"LE2c"
"LE1a"
"LE1b"
"LE1c"
};

% %PING_SEG_RIGHT
% conditions = {"R10a"
% "R10b"
% "R10c"
% "RE9a"
% "RE9b"
% "RE9c"};



no_of_conditions = length(conditions);
%% Select a channel out of that file to analyze

%whos NetstationFile to see how the data variable has been titled
%% EDIT
%Selected_Chan_sin = NetstationFile.DBS_ALIC202_PING_Segs_RIGHT_20220128_032731mff(chan_spec,:);
%Selected_Chan_sin = NetstationFile.DBS_ALIC202_PING_Segs_LEFT_20220128_025130mff(chan_spec,:);
%Selected_Chan_sin = NetstationFile.ALIC203_T0_PING_Segs_LEFT_20220311_015944mff(chan_spec,:); %assume first field is EEG
%Selected_Chan_sin = NetstationFile.ALIC203_T0_PING_Segs_Right_20220311_023607mff(chan_spec,:);
Selected_Chan_sin = NetstationFile.ALIC204_TO_PING_Segs_LEFT_20220502_015720mff(chan_spec,:);
%Selected_Chan_sin = NetstationFile.ALIC203_T0_PING_Segs_LEFT_20220311_015944mff(chan_spec,:);
%Selected_Chan_sin = NetstationFile.ALIC204_TO_PING_RING_20220502_030844mff(chan_spec,:);




% sin stands for single - but later we'll make it a double

Selected_Chan = double (Selected_Chan_sin);

Time = length(Selected_Chan_sin/Sample_rate);

figure

plot(Selected_Chan_sin)

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
k = 5;
T = timetable(Selected_Chan','SampleRate',1000,'VariableNames',"Selected_Chan");
T.("Selected_Chan") = T.("Selected_Chan") - movmean(T.("Selected_Chan"),k);
figure 
hold on
plot(T.("Time"),T.("Selected_Chan"),'b')
plot(T.("Time"),Selected_Chan,'k')
xlabel('Time (s)')
ylabel('Voltage (uV)')
legend({'Preprocessed Signal','Raw Signal'})
hold off

%% baselined data only
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

[pks,locs] = findpeaks (y,'MinPeakDistance',475, 'MinPeakHeight',1,'MinPeakProminence',700); %400 is original prominence

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
n=20;
n_dist = (n+1)*500; %< 21peaks*500 samples away (1000sf/2Hzstim.), but > 0 %constrains the peak
dispose =[];
tot_peaks = height(L);
for i = 1:tot_peaks
    dist1 = 0;
    dist2 = 0;

    % test if peak is a part of false pulse

          %first layer of checks
          %check peaks after, b/c this could be first peak in condition
          %if c1
              ref = i+(n-1);
    
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
              ref = i-(n-1);
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
        dispose=[dispose, i];
     end

end

%% Manual dispose --- EDIT FOR ALGO.
% Get rid of these peaks from visual
% manual_dispose = [2:5];
% dispose = [dispose,manual_dispose];
%%

%% Plot results

%with peaks in red, de-identified peaks in black
f1 = figure
yyaxis left
plot (Selected_Chan)

hold on

h = plot (locs, Selected_Chan(locs), 'r.', 'markersize', 24)
k = plot (L.locs(dispose),Selected_Chan(L.locs(dispose)), 'k*', 'markersize', 24 )
xlabel('Sample Number')
ylabel('Voltage (uV)')
legend('Raw EEG','Stim Peaks Detected','Deleted Peaks','Condition Marker')
str = sprintf("Deleted Peaks, d = %d",length(dispose));
title("Stimulation Peaks",str)
%save(f1)


%peaks to print here
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
threshold = 600; %depends on stimulation frequnecy of a pulse (beyond 500)
for k = 1:height(L)
    if k~=1 && L.before(k)>threshold %%new edit is k~=1
        count = count+1; 
    end
    Cond_Nums(k) = count;
end
L = addvars(L,Cond_Nums);

%plot epoch 
figure(f1)
hold on
yyaxis right
plot(L.locs,L.Cond_Nums, 'p')
ylabel('Condition No.')
hold off
%save(f1)

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



%% Format Peak Via NetStation
Peaks_NS = L.locs;

%% ADDENDUM: Time for NS
Peaks_NS; %locations of R peaks;
Peaks_NS = (Peaks_NS - 1); %NS adjusted peaks (for visual purposes);
time_NS = seconds(Peaks_NS/1000); %into sec per Sample Rate = 1000Hz
time_NS_formatted = duration(time_NS,'Format','hh:mm:ss.SSS'); %formatted NS times

%% Print all peaks
filename = sprintf("ALIC%d_NS_StimEP.txt",Subject_No); 

fileID = fopen(filename,'w');
fprintf(fileID,'%d\n',Peaks_NS);
fclose(fileID);

%% Print NetStation Times
%%%MAY HAVE TO CHANGE EPOCH NUMBER HERE
epoch_no = 1;
filename = sprintf("ALIC%d_NS_StimEP_String.txt",Subject_No); 

fileID = fopen(filename,'w');
time = string(time_NS_formatted);
for i = 1:length(Peaks_NS)
    fprintf(fileID,'_[%d] %s\n',epoch_no,time(i));
end
fclose(fileID);


%% Print Labels
filename = sprintf("ALIC%d_NS_StimEP_Label.txt",Subject_No); 

fileID = fopen(filename,'w');
for i = 1:height(L)
    if L.Cond_Nums(i)>0 && L.Cond_Nums(i)<= length(conditions)
        fprintf(fileID,'%s\n',conditions{L.Cond_Nums(i)});
    end
end
fclose(fileID);






%% Check surrounding peaks that are within ___ ms ()
% Issue: There are small peaks that are getting identified inbetween
% experiments: we should take note of peaks/samples that are eliminated???



