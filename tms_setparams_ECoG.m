function [config] = tms_setparams

disp('setting parameters for tms intracellular data');

if ismac
    error('Platform not supported')
elseif isunix
    rootpath_analysis	= '/network/lustre/iss01/charpier/analyses/tms/';
    rootpath_data       = '/network/lustre/iss01/charpier/analyses/tms/raw/ECoG/';
elseif ispc
    rootpath_analysis	= '\\lexport\iss01.charpier\analyses\tms\';
    rootpath_data       = '\\lexport\iss01.charpier\analyses\tms\raw\ECoG\';
else
    error('Platform not supported')
end

datasavedir  = fullfile(rootpath_analysis,'data'); %where to save matlab data
imagesavedir = fullfile(rootpath_analysis,'image'); %where to save images

%% Config common for all rats
%subject infos
configcommon.name                      ={};

configcommon.datasavedir               = datasavedir;
configcommon.imagesavedir              = imagesavedir;

configcommon.readCED.chan_EEG_R                   = 'EEG-S1-R';
configcommon.readCED.chan_EEG_L                   = 'EEG-S1-L';
configcommon.readCED.im_lpfreq                 = 100;%Hz. remove stim artefacts on Im

configcommon.stim_marker               = 'ARTEFACTS';
configcommon.im_threshold              = 0.1; %nA, threshold to ignore window if abs of current is more than it
configcommon.puff.channel              = 'Puffs'; 
configcommon.puff.remove_duration      = 1; %second


%% Rat 1 only ECoG
config{1}                                   = configcommon;
%config{1}.name                              = {''};%say which analysis to do for this rat
config{1}.prefix                            = '02092019-'; %leave the '-' at the end
config{1}.readCED.datapath                  = fullfile(rootpath_data,'02092019.smrx'); %with the extension

%% Rat 2 only ECoG
config{2}                                   = configcommon;
config{2}.prefix                            = '03102019-'; %leave the '-' at the end
config{2}.readCED.datapath                  = fullfile(rootpath_data,'03102019.smrx'); %with the extension

%% Rat 3 only ECoG
config{3}                                   = configcommon;
config{3}.prefix                            = '07032019-'; %leave the '-' at the end
config{3}.readCED.datapath                  = fullfile(rootpath_data,'07032019.smrx'); %with the extension

%% Rat 4 only ECoG
config{4}                                   = configcommon;
config{4}.prefix                            = '08102019-'; %leave the '-' at the end
config{4}.readCED.datapath                  = fullfile(rootpath_data,'08102019.smrx'); %with the extension

%% Rat 5 only ECoG
config{5}                                   = configcommon;
config{5}.prefix                            = '10102019-'; %leave the '-' at the end
config{5}.readCED.datapath                  = fullfile(rootpath_data,'10102019.smrx'); %with the extension

%% Rat 6 only ECoG
config{6}                                   = configcommon;
config{6}.prefix                            = '11092020-'; %leave the '-' at the end
config{6}.readCED.datapath                  = fullfile(rootpath_data,'11092020.smrx'); %with the extension

%% Rat 7 only ECoG
config{7}                                   = configcommon;
config{7}.prefix                            = '14102019-'; %leave the '-' at the end
config{7}.readCED.datapath                  = fullfile(rootpath_data,'14102019.smrx'); %with the extension

%% Rat 8 only ECoG
config{8}                                   = configcommon;
config{8}.prefix                            = '15032019-'; %leave the '-' at the end
config{8}.readCED.datapath                  = fullfile(rootpath_data,'15032019.smrx'); %with the extension

%% Rat 9 only ECoG
config{9}                                   = configcommon;
config{9}.prefix                            = '16102019-'; %leave the '-' at the end
config{9}.readCED.datapath                  = fullfile(rootpath_data,'16102019.smrx'); %with the extension

%% Rat 10 only ECoG
config{10}                                   = configcommon;
config{10}.prefix                            = '17092019-'; %leave the '-' at the end
config{10}.readCED.datapath                  = fullfile(rootpath_data,'17092019.smrx'); %with the extension

%% Rat 11 only ECoG
config{11}                                   = configcommon;
config{11}.prefix                            = '18022019-'; %leave the '-' at the end
config{11}.readCED.datapath                  = fullfile(rootpath_data,'18022019.smrx'); %with the extension

%% Rat 12 only ECoG
config{12}                                   = configcommon;
config{12}.prefix                            = '19032019-'; %leave the '-' at the end
config{12}.readCED.datapath                  = fullfile(rootpath_data,'19032019.smrx'); %with the extension

%% Rat 13 only ECoG
config{13}                                   = configcommon;
config{13}.prefix                            = '19092019-'; %leave the '-' at the end
config{13}.readCED.datapath                  = fullfile(rootpath_data,'19092019.smrx'); %with the extension

%% Rat 14 only ECoG
config{14}                                   = configcommon;
config{14}.prefix                            = '20022019-'; %leave the '-' at the end
config{14}.readCED.datapath                  = fullfile(rootpath_data,'20022019.smrx'); %with the extension

%% Rat 15 only ECoG
config{15}                                   = configcommon;
config{15}.prefix                            = '20032019-'; %leave the '-' at the end
config{15}.readCED.datapath                  = fullfile(rootpath_data,'20032019.smrx'); %with the extension

%% Rat 16 only ECoG
config{16}                                   = configcommon;
config{16}.prefix                            = '20052020-'; %leave the '-' at the end
config{16}.readCED.datapath                  = fullfile(rootpath_data,'20052020.smrx'); %with the extension

%% Rat 17 only ECoG
config{17}                                   = configcommon;
config{17}.prefix                            = '20052020-'; %leave the '-' at the end
config{17}.readCED.datapath                  = fullfile(rootpath_data,'20052020.smrx'); %with the extension

%% Rat 18 only ECoG
config{18}                                   = configcommon;
config{18}.prefix                            = '21032019-'; %leave the '-' at the end
config{18}.readCED.datapath                  = fullfile(rootpath_data,'21032019.smrx'); %with the extension

%% Rat 19 only ECoG
config{19}                                   = configcommon;
config{19}.prefix                            = '21082020-'; %leave the '-' at the end
config{19}.readCED.datapath                  = fullfile(rootpath_data,'21082020.smrx'); %with the extension

%% Rat 20 only ECoG
config{20}                                   = configcommon;
config{20}.prefix                            = '22022019-'; %leave the '-' at the end
config{20}.readCED.datapath                  = fullfile(rootpath_data,'22022019.smrx'); %with the extension

%% Rat 21 only ECoG
config{21}                                   = configcommon;
config{21}.prefix                            = '23052020-'; %leave the '-' at the end
config{21}.readCED.datapath                  = fullfile(rootpath_data,'23052020.smrx'); %with the extension

%% Rat 22 only ECoG
config{22}                                   = configcommon;
config{22}.prefix                            = '24092019-'; %leave the '-' at the end
config{22}.readCED.datapath                  = fullfile(rootpath_data,'24092019.smrx'); %with the extension

%% Rat 23 only ECoG
config{23}                                   = configcommon;
config{23}.prefix                            = '25022019-'; %leave the '-' at the end
config{23}.readCED.datapath                  = fullfile(rootpath_data,'25022019.smrx'); %with the extension

%% Rat 24 only ECoG
config{24}                                   = configcommon;
config{24}.prefix                            = '25082020-'; %leave the '-' at the end
config{24}.readCED.datapath                  = fullfile(rootpath_data,'25082020.smrx'); %with the extension

%% Rat 25 only ECoG
config{25}                                   = configcommon;
config{25}.prefix                            = '26092019-'; %leave the '-' at the end
config{25}.readCED.datapath                  = fullfile(rootpath_data,'26092019.smrx'); %with the extension

%% Rat 26 only ECoG
config{26}                                   = configcommon;
config{26}.prefix                            = '27022020-'; %leave the '-' at the end
config{26}.readCED.datapath                  = fullfile(rootpath_data,'27022020.smrx'); %with the extension

%% Rat 27 only ECoG
config{27}                                   = configcommon;
config{27}.prefix                            = '31072020-'; %leave the '-' at the end
config{27}.readCED.datapath                  = fullfile(rootpath_data,'31072020.smrx'); %with the extension
