%Manual Change Sample_Net Station_Read_Out
%% Format Peaks Via NetStation 

%% Load text file of peaks (StimArtifact Prefix)
[file, path] = uigetfile('*.txt');
cd(path)
NetstationFile = readtable(file); 
NetstationFile = table2array(NetstationFile)
%% Select Upload Folder
%makes file in data retrieval location
filename = ['[Corrected]-',file];
folder = [filename,'RingRight']; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%EDIT HERE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir(folder)

%retrieve folder for figure and pipeline output upload
newpath = [path,folder,'/'];
cd(newpath)
%% Old Script
Peaks_NS = NetstationFile;
Sample_rate = 250;

%%% Time for NS
Peaks_NS; %locations of R peaks;
Peaks_NS = (Peaks_NS - 1); %NS adjusted peaks (for visual purposes);
time_NS = seconds(Peaks_NS/Sample_rate); %into sec per Sample Rate = 1000Hz
time_NS_formatted = duration(time_NS,'Format','hh:mm:ss.SSS'); %formatted NS times

% %%% Print all peaks
% filename = sprintf("NS_%s.txt",folder); 
% 
% fileID = fopen(filename,'w');
% fprintf(fileID,'%d\n',Peaks_NS);
% fclose(fileID);

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


% %%% Print Labels
% filename = sprintf("NS_Label_%s.txt",folder); 
% 
% fileID = fopen(filename,'w');
% for i = 1:length(NetstationFile)
%     if L.Cond_Nums(i)>0 && L.Cond_Nums(i)<= length(conditions)
%         fprintf(fileID,'%s\n',conditions{L.Cond_Nums(i)});
%     end
% end
% fclose(fileID);

% %%% Save Parameters in a text file for future reference
% filename = sprintf("NS_Parameters_%s.txt",folder); 
% 
% fileID = fopen(filename,'w');
% 
% fprintf(fileID,'Channel: %d\n Sample Rate: %d\n K Moving Mean Window: %d\n MinPeakDistance: %d\n MinPeakHeight: %d\n MinPeakProminence: %d\n'...
%     ,chan_spec, Sample_rate, k, mpd, mph, mpp);
%   
% fclose(fileID);
