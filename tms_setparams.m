function [config] = tms_setparams

disp('setting parameters for tms intracellular data');

if ismac
    error('Platform not supported')
elseif isunix
    rootpath_analysis	= '/network/lustre/iss01/charpier/analyses/tms/';
    rootpath_data       = '/network/lustre/iss01/charpier/analyses/tms/raw/intra/';
elseif ispc
    rootpath_analysis	= '\\lexport\iss01.charpier\analyses\tms\';
    rootpath_data       = '\\lexport\iss01.charpier\analyses\tms\raw\intra\';
else
    error('Platform not supported')
end

datasavedir  = fullfile(rootpath_analysis,'data'); %where to save matlab data
imagesavedir = fullfile(rootpath_analysis,'image'); %where to save images

%% Config common for all rats
%subject infos
configcommon.name                      ={'Vm','spike_freq','spike_amp'};

configcommon.datasavedir               = datasavedir;
configcommon.imagesavedir              = imagesavedir;

configcommon.readCED.chan_Vm                   = 'VmArtRem';
configcommon.readCED.chan_Im                   = 'Im';
configcommon.readCED.im_lpfreq                 = 100;%Hz. remove stim artefacts on Im

configcommon.stim_marker               = 'ARTEFACTS';
configcommon.im_threshold              = 0.1; %nA, threshold to ignore window if abs of current is more than it
configcommon.puff.channel              = 'Puffs'; 
configcommon.puff.remove_duration      = 1; %second

configcommon.vm_over_time.remove_spikes.toi         = [-10 60];%ms, remove before and after spike timing
configcommon.vm_over_time.remove_spikes.spikechan   = 'PA_TOTAL';%channel with AP timings
configcommon.vm_over_time.window.size            = 10;%seconds
configcommon.vm_over_time.window.step            = 10;%seconds
configcommon.vm_over_time.ignore_pulses          = 'yes';
configcommon.vm_over_time.ignore_puffs           = 'yes'; 

%configcommon.spike_overtime.window.step    = 30;%seconds
configcommon.spike_overtime.morpho_toi     = [-3 3];%ms : time of PA morpho

configcommon.has_big_offset = [10 14 20];%
configcommon.instable_baseline = [15 20]; %

configcommon.rat_list_spikefreq =[7 8 12 14 20 21 22];
configcommon.rat_list_spikefreq_ctrl =[];


%% Rat 1
% config{1}                                   = configcommon;
% config{1}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
% config{1}.prefix                            = '803-'; %leave the '-' at the end
% config{1}.readCED.datapath                  = fullfile(rootpath_data,'803.smrx'); %with the extension
% config{1}.vm_over_time.remove_spikes.toi    = [-30 100];%ms, For this rat, remove bug bursts
% config{1}.vm_over_time.baselinewindow       = [-600 0];
% config{1}.spike_overtime.baseline           = [-600 0];%'begining'
% config{1}.spike_overtime.baselinewindow     = [];%needed if baseline = 'begin' : [0 60];
% config{1}.spike_overtime.spikechannels      = {'PA_TOTAL'};%{'PA_TOTAL', 'PA_ISOL'};
% config{1}.spike_overtime.ignore_pulses      = 'yes';
% config{1}.spike_overtime.ignore_puffs       = 'yes';
% config{1}.spike_overtime.window.size        = 10;%seconds
% config{1}.plotstim                          ='patch';

%% Rat 2
config{2}                                   = configcommon;
config{2}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{2}.prefix                            = 'QX50-1065-'; %leave the '-' at the end
config{2}.readCED.datapath                  = fullfile(rootpath_data,'1065.smrx'); %with the extension
config{2}.spike_overtime.baseline           = 'begin';
config{2}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{2}.vm_over_time.baseline             = 'begin';
config{2}.vm_over_time.baselinewindow       = [0 60];
config{2}.spike_overtime.spikechannels      = {'PA_TOTAL','PA_SPONT', 'PA_PULSES', 'PA_STIM', 'PA_ISOL'}; %
config{2}.spike_overtime.ignore_pulses      = 'no';
config{2}.spike_overtime.ignore_puffs       = 'no';
config{2}.spike_overtime.window.size        = 30;%seconds
config{2}.spike_overtime.window.step        = 30;%seconds
config{2}.plotstim                          ='lines';

%% Rat 3
config{3}                                   = configcommon;
config{3}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{3}.prefix                            = 'QX100-1083-'; %leave the '-' at the end
config{3}.readCED.datapath                  = fullfile(rootpath_data,'1083.smrx'); %with the extension
config{3}.spike_overtime.baseline           = 'begin';
config{3}.spike_overtime.baselinewindow     = [0 40]; %needed if baseline = 'begin' : [0 60];
config{3}.vm_over_time.baseline             = 'begin';
config{3}.vm_over_time.baselinewindow       = [0 40];
config{3}.spike_overtime.spikechannels      = {'PA_TOTAL','PA_SPONT', 'PA_PULSES', 'PA_STIM', 'PA_ISOL'}; %
config{3}.spike_overtime.ignore_pulses      = 'no';
config{3}.spike_overtime.ignore_puffs       = 'no';
config{3}.spike_overtime.window.size        = 20;%seconds
config{3}.plotstim                          ='lines';

%% Rat 4
config{4}                                   = configcommon;
config{4}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{4}.prefix                            = 'QX100-1749-'; %leave the '-' at the end
config{4}.readCED.datapath                  = fullfile(rootpath_data,'1749.smrx'); %with the extension
config{4}.spike_overtime.baseline           = 'begin';
config{4}.spike_overtime.baselinewindow     = [22 50]; %needed if baseline = 'begin' : [0 60];
config{4}.vm_over_time.baseline             = 'begin';
config{4}.vm_over_time.baselinewindow       = [105 130];
config{4}.spike_overtime.spikechannels      = {'PA_SPONT', 'PA_PULSES', 'PA_STIM'}; %
config{4}.spike_overtime.ignore_pulses      = 'no';
config{4}.spike_overtime.ignore_puffs       = 'no';
config{4}.spike_overtime.window.size        = 10;%seconds
config{4}.plotstim                          ='lines';

%% Rat 5
config{5}                                   = configcommon;
config{5}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{5}.prefix                            = 'QX100-1941-'; %leave the '-' at the end
config{5}.readCED.datapath                  = fullfile(rootpath_data,'1941.smrx'); %with the extension
config{5}.spike_overtime.baseline           = 'begin';
config{5}.spike_overtime.baselinewindow     = [50 60]; %needed if baseline = 'begin' : [0 60];
config{5}.vm_over_time.baseline             = 'begin';
config{5}.vm_over_time.baselinewindow       = [50 60];
config{5}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_PULSES', 'PA_STIM', 'PA_ISOL'}; %
config{5}.spike_overtime.ignore_pulses      = 'no';
config{5}.spike_overtime.ignore_puffs       = 'no';
config{5}.spike_overtime.window.size        = 50;%seconds
config{5}.plotstim                          ='lines';

%% Rat 6
config{6}                                   = configcommon;
config{6}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{6}.prefix                            = 'QX100-3051-'; %leave the '-' at the end
config{6}.readCED.datapath                  = fullfile(rootpath_data,'3051.smrx'); %with the extension
config{6}.spike_overtime.baseline           = 'begin';
config{6}.spike_overtime.baselinewindow     = [0 10]; %needed if baseline = 'begin' : [0 60];
config{6}.vm_over_time.baseline             = 'begin';
config{6}.vm_over_time.baselinewindow       = [0 10];
config{6}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_PULSES', 'PA_STIM', 'PA_ISOL'}; %
config{6}.spike_overtime.ignore_pulses      = 'no';
config{6}.spike_overtime.ignore_puffs       = 'no';
config{6}.spike_overtime.window.size        = 50;%seconds
config{6}.plotstim                          ='lines';

%% Rat 7
config{7}                                   = configcommon;
config{7}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{7}.prefix                            = '803_rTMS_Ctrl-'; %leave the '-' at the end
config{7}.readCED.datapath                  = fullfile(rootpath_data,'803_rTMS_Ctrl.smrx'); %with the extension
config{7}.vm_over_time.baseline             = 'prestim';%'begining'
config{7}.vm_over_time.baselinewindow       = [-600 0];
config{7}.spike_overtime.baseline           = 'prestim';%'begining'
config{7}.spike_overtime.baselinewindow     = [-600 0];%needed if baseline = 'begin' : [0 60];
config{7}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{7}.spike_overtime.ignore_pulses      = 'yes';
config{7}.spike_overtime.ignore_puffs       = 'yes';
config{7}.spike_overtime.window.size        = 30;%seconds
config{7}.spike_overtime.window.step        = 30;%seconds
config{7}.plotstim                          ='patch';
config{7}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing

%% Rat 8
config{8}                                   = configcommon;
config{8}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{8}.prefix                            = '1095_rTMS-'; %leave the '-' at the end
config{8}.readCED.datapath                  = fullfile(rootpath_data,'1095_rTMS.smrx'); %with the extension
config{8}.vm_over_time.baseline             = 'prestim';%'begining'
config{8}.vm_over_time.baselinewindow       = [-600 0];
config{8}.spike_overtime.baseline           = 'prestim';%'begining'
config{8}.spike_overtime.baselinewindow     = [-600 0];%needed if baseline = 'begin' : [0 60];
config{8}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{8}.spike_overtime.ignore_pulses      = 'yes';
config{8}.spike_overtime.ignore_puffs       = 'yes';
config{8}.spike_overtime.window.size        = 30;%seconds
config{8}.spike_overtime.window.step        = 30;%seconds
config{8}.plotstim                          ='patch';
config{8}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing

%% Rat 9
config{9}                                   = configcommon;
config{9}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{9}.prefix                            = '1284_rTMS_Ctrl-'; %leave the '-' at the end
config{9}.readCED.datapath                  = fullfile(rootpath_data,'1284_rTMS_Ctrl.smrx'); %with the extension
config{9}.vm_over_time.baseline             = 'prestim';%'begining'
config{9}.vm_over_time.baselinewindow       = [-600 0];
config{9}.spike_overtime.baseline           = 'prestim';%'begining'
config{9}.spike_overtime.baselinewindow     = [-600 0];
config{9}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{9}.spike_overtime.ignore_pulses      = 'yes';
config{9}.spike_overtime.ignore_puffs       = 'yes';
config{9}.spike_overtime.window.size        = 30;%seconds
config{9}.spike_overtime.window.step        = 30;%seconds
config{9}.plotstim                          ='patch';

%% Rat 10
config{10}                                   = configcommon;
config{10}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{10}.prefix                            = '1395_rTMS-'; %leave the '-' at the end
config{10}.readCED.datapath                  = fullfile(rootpath_data,'1395_rTMS.smrx'); %with the extension
config{10}.vm_over_time.baseline             = 'prestim';%'begining'
config{10}.vm_over_time.baselinewindow       = [-600 0];
config{10}.spike_overtime.baseline           = 'prestim';%'begining'
config{10}.spike_overtime.baselinewindow     = [-600 0];
config{10}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{10}.spike_overtime.ignore_pulses      = 'yes';
config{10}.spike_overtime.ignore_puffs       = 'yes';
config{10}.spike_overtime.window.size        = 30;%seconds
config{10}.spike_overtime.window.step        = 30;%seconds
config{10}.plotstim                          ='patch';

%% Rat 11
config{11}                                   = configcommon;
config{11}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{11}.prefix                            = '1834_rTMS_Ctrl-'; %leave the '-' at the end
config{11}.readCED.datapath                  = fullfile(rootpath_data,'1834_rTMS_Ctrl.smrx'); %with the extension
config{11}.vm_over_time.baseline             = 'prestim';%'begining'
config{11}.vm_over_time.baselinewindow       = [-600 0];
config{11}.spike_overtime.baseline           = 'prestim';%'begining'
config{11}.spike_overtime.baselinewindow     = [-600 0];
config{11}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{11}.spike_overtime.ignore_pulses      = 'yes';
config{11}.spike_overtime.ignore_puffs       = 'yes';
config{11}.spike_overtime.window.size        = 30;%seconds
config{11}.spike_overtime.window.step        = 30;%seconds
config{11}.plotstim                          ='patch';

%% Rat 12
config{12}                                   = configcommon;
config{12}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{12}.prefix                            = '1841_rTMS_Ctrl-'; %leave the '-' at the end
config{12}.readCED.datapath                  = fullfile(rootpath_data,'1841_rTMS_Ctrl.smrx'); %with the extension
config{12}.vm_over_time.baseline             = 'prestim';%'begining'
config{12}.vm_over_time.baselinewindow       = [-600 0];
config{12}.spike_overtime.baseline           = 'prestim';%'begining'
config{12}.spike_overtime.baselinewindow     = [-600 0];
config{12}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{12}.spike_overtime.ignore_pulses      = 'yes';
config{12}.spike_overtime.ignore_puffs       = 'yes';
config{12}.spike_overtime.window.size        = 30;%seconds
config{12}.spike_overtime.window.step        = 30;%seconds
config{12}.plotstim                          ='patch';

%% Rat 13
config{13}                                   = configcommon;
config{13}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{13}.prefix                            = '2090_rTMS_Ctrl-'; %leave the '-' at the end
config{13}.readCED.datapath                  = fullfile(rootpath_data,'2090_rTMS_Ctrl.smrx'); %with the extension
config{13}.vm_over_time.baseline             = 'prestim';%'begining'
config{13}.vm_over_time.baselinewindow       = [-600 0];
config{13}.spike_overtime.baseline           = 'prestim';%'begining'
config{13}.spike_overtime.baselinewindow     = [-600 0];
config{13}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{13}.spike_overtime.ignore_pulses      = 'yes';
config{13}.spike_overtime.ignore_puffs       = 'yes';
config{13}.spike_overtime.window.size        = 30;%seconds
config{13}.spike_overtime.window.step        = 30;%seconds
config{13}.plotstim                          ='patch';

%% Rat 14
config{14}                                   = configcommon;
config{14}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{14}.prefix                            = '2343_rTMS_Ctrl-'; %leave the '-' at the end
config{14}.readCED.datapath                  = fullfile(rootpath_data,'2343_rTMS_Ctrl.smrx'); %with the extension
config{14}.vm_over_time.baseline             = 'prestim';%'begining'
config{14}.vm_over_time.baselinewindow       = [-600 0];
config{14}.spike_overtime.baseline           = 'prestim';%'begining'
config{14}.spike_overtime.baselinewindow     = [-600 0];
config{14}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{14}.spike_overtime.ignore_pulses      = 'yes';
config{14}.spike_overtime.ignore_puffs       = 'yes';
config{14}.spike_overtime.window.size        = 30;%seconds
config{14}.spike_overtime.window.step        = 30;%seconds
config{14}.plotstim                          ='patch';

%% Rat 15
config{15}                                   = configcommon;
config{15}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{15}.prefix                            = '2409_rTMS_Ctrl-'; %leave the '-' at the end
config{15}.readCED.datapath                  = fullfile(rootpath_data,'2409_rTMS_Ctrl.smrx'); %with the extension
config{15}.vm_over_time.baseline             = 'prestim';%'begining'
config{15}.vm_over_time.baselinewindow       = [-600 0];
config{15}.spike_overtime.baseline           = 'prestim';%'begining'
config{15}.spike_overtime.baselinewindow     = [-600 0];
config{15}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{15}.spike_overtime.ignore_pulses      = 'yes';
config{15}.spike_overtime.ignore_puffs       = 'yes';
config{15}.spike_overtime.window.size        = 30;%seconds
config{15}.spike_overtime.window.step        = 30;%seconds
config{15}.plotstim                          ='patch';

%% Rat 16
config{16}                                   = configcommon;
config{16}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{16}.prefix                            = '2417_rTMS_Ctrl-'; %leave the '-' at the end
config{16}.readCED.datapath                  = fullfile(rootpath_data,'2417_rTMS_Ctrl.smrx'); %with the extension
config{16}.vm_over_time.baseline             = 'prestim';%'begining'
config{16}.vm_over_time.baselinewindow       = [-600 0];
config{16}.spike_overtime.baseline           = 'prestim';%'begining'
config{16}.spike_overtime.baselinewindow     = [-600 0];
config{16}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{16}.spike_overtime.ignore_pulses      = 'yes';
config{16}.spike_overtime.ignore_puffs       = 'yes';
config{16}.spike_overtime.window.size        = 30;%seconds
config{16}.spike_overtime.window.step        = 30;%seconds
config{16}.plotstim                          ='patch';

%% Rat 17
config{17}                                   = configcommon;
config{17}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{17}.prefix                            = '2948_rTMS_Ctrl-'; %leave the '-' at the end
config{17}.readCED.datapath                  = fullfile(rootpath_data,'2948_rTMS_Ctrl.smrx'); %with the extension
config{17}.vm_over_time.baseline             = 'prestim';%'begining'
config{17}.vm_over_time.baselinewindow       = [-600 0];
config{17}.spike_overtime.baseline           = 'prestim';%'begining'
config{17}.spike_overtime.baselinewindow     = [-600 0];
config{17}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{17}.spike_overtime.ignore_pulses      = 'yes';
config{17}.spike_overtime.ignore_puffs       = 'yes';
config{17}.spike_overtime.window.size        = 30;%seconds
config{17}.spike_overtime.window.step        = 30;%seconds
config{17}.plotstim                          ='patch';

%% Rat 18
config{18}                                   = configcommon;
config{18}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{18}.prefix                            = '3267_rTMS-'; %leave the '-' at the end
config{18}.readCED.datapath                  = fullfile(rootpath_data,'3267_rTMS.smrx'); %with the extension
config{18}.vm_over_time.baseline             = 'prestim';%'begining'
config{18}.vm_over_time.baselinewindow       = [-600 0];
config{18}.spike_overtime.baseline           = 'prestim';%'begining'
config{18}.spike_overtime.baselinewindow     = [-600 0];
config{18}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{18}.spike_overtime.ignore_pulses      = 'yes';
config{18}.spike_overtime.ignore_puffs       = 'yes';
config{18}.spike_overtime.window.size        = 30;%seconds
config{18}.spike_overtime.window.step        = 30;%seconds
config{18}.plotstim                          ='patch';
config{18}.vm_over_time.remove_spikes.toi    = [-10 45];%ms, remove before and after spike timing

%% Rat 19
config{19}                                   = configcommon;
config{19}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{19}.prefix                            = '3332_rTMS-'; %leave the '-' at the end
config{19}.readCED.datapath                  = fullfile(rootpath_data,'3332_rTMS.smrx'); %with the extension
config{19}.vm_over_time.baseline             = 'prestim';%'begining'
config{19}.vm_over_time.baselinewindow       = [-600 0];
config{19}.spike_overtime.baseline           = 'prestim';%'begining'
config{19}.spike_overtime.baselinewindow     = [-600 0];
config{19}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{19}.spike_overtime.ignore_pulses      = 'yes';
config{19}.spike_overtime.ignore_puffs       = 'yes';
config{19}.spike_overtime.window.size        = 30;%seconds
config{19}.spike_overtime.window.step        = 30;%seconds
config{19}.plotstim                          ='patch';

%% Rat 20
config{20}                                   = configcommon;
config{20}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{20}.prefix                            = '874_rTMS-'; %leave the '-' at the end
config{20}.readCED.datapath                  = fullfile(rootpath_data,'874_rTMS.smrx'); %with the extension
config{20}.vm_over_time.baseline             = 'prestim';%'begining'
config{20}.vm_over_time.baselinewindow       = [-600 0];
config{20}.spike_overtime.baseline           = 'prestim';%'begining'
config{20}.spike_overtime.baselinewindow     = [-600 0];
config{20}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{20}.spike_overtime.ignore_pulses      = 'yes';
config{20}.spike_overtime.ignore_puffs       = 'yes';
config{20}.spike_overtime.window.size        = 30;%seconds
config{20}.spike_overtime.window.step        = 30;%seconds
config{20}.plotstim                          ='patch';

%% Rat 21
config{21}                                   = configcommon;
config{21}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{21}.prefix                            = '974_rTMS-'; %leave the '-' at the end
config{21}.readCED.datapath                  = fullfile(rootpath_data,'974_rTMS.smrx'); %with the extension
config{21}.vm_over_time.baseline             = 'prestim';%'begining'
config{21}.vm_over_time.baselinewindow       = [-600 0];
config{21}.spike_overtime.baseline           = 'prestim';%'begining'
config{21}.spike_overtime.baselinewindow     = [-600 0];
config{21}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{21}.spike_overtime.ignore_pulses      = 'yes';
config{21}.spike_overtime.ignore_puffs       = 'yes';
config{21}.spike_overtime.window.size        = 30;%seconds
config{21}.spike_overtime.window.step        = 30;%seconds
config{21}.plotstim                          ='patch';

%% Rat 22
config{22}                                   = configcommon;
config{22}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{22}.prefix                            = '2318_rTMS-'; %leave the '-' at the end
config{22}.readCED.datapath                  = fullfile(rootpath_data,'2318_rTMS.smrx'); %with the extension
config{22}.vm_over_time.baseline             = 'prestim';%'begining'
config{22}.vm_over_time.baselinewindow       = [-600 0];
config{22}.spike_overtime.baseline           = 'prestim';%'begining'
config{22}.spike_overtime.baselinewindow     = [-600 0];
config{22}.spike_overtime.spikechannels      = {'PA_TOTAL', 'PA_INDUITS', 'PA_SPONT'}; %, 'PA_ISOL', 'PA_SPONT'
config{22}.spike_overtime.ignore_pulses      = 'yes'; 
config{22}.spike_overtime.ignore_puffs       = 'yes';
config{22}.spike_overtime.window.size        = 30;%seconds
config{22}.spike_overtime.window.step        = 30;%seconds
config{22}.plotstim                          ='patch';

%% Rat 23 only control
config{23}                                   = configcommon;
config{23}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{23}.prefix                            = '1470_Ctrl-'; %leave the '-' at the end
config{23}.readCED.datapath                  = fullfile(rootpath_data,'1470_Ctrl.smrx'); %with the extension
config{23}.vm_over_time.baseline             = 'prestim';%'begining'
config{23}.vm_over_time.baselinewindow       = [-600 0];
config{23}.spike_overtime.baseline           = 'prestim';%'begining'
config{23}.spike_overtime.baselinewindow     = [-600 0];
config{23}.spike_overtime.spikechannels      = {'PA_TOTAL'};
config{23}.spike_overtime.ignore_pulses      = 'yes';
config{23}.spike_overtime.ignore_puffs       = 'yes';
config{23}.spike_overtime.window.size        = 30;%seconds
config{23}.spike_overtime.window.step        = 30;%seconds
config{23}.plotstim                          ='patch';

%% Rat 24 only control
config{24}                                   = configcommon;
config{24}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{24}.prefix                            = '1471_Ctrl-'; %leave the '-' at the end
config{24}.readCED.datapath                  = fullfile(rootpath_data,'1471_Ctrl.smrx'); %with the extension
config{24}.vm_over_time.baseline             = 'prestim';%'begining'
config{24}.vm_over_time.baselinewindow       = [-600 0];
config{24}.spike_overtime.baseline           = 'prestim';%'begining'
config{24}.spike_overtime.baselinewindow     = [-600 0];
config{24}.spike_overtime.spikechannels      = {'PA_TOTAL'};
config{24}.spike_overtime.ignore_pulses      = 'yes';
config{24}.spike_overtime.ignore_puffs       = 'yes';
config{24}.spike_overtime.window.size        = 30;%seconds
config{24}.spike_overtime.window.step        = 30;%seconds
config{24}.plotstim                          ='patch';

%% Rat 25 Only control
config{25}                                   = configcommon;
config{25}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{25}.prefix                            = '2118_Ctrl-'; %leave the '-' at the end
config{25}.readCED.datapath                  = fullfile(rootpath_data,'2118_Ctrl.smrx'); %with the extension
config{25}.vm_over_time.baseline             = 'prestim';%'begining'
config{25}.vm_over_time.baselinewindow       = [-600 0];
config{25}.spike_overtime.baseline           = 'prestim';%'begining'
config{25}.spike_overtime.baselinewindow     = [-600 0];
config{25}.spike_overtime.spikechannels      = {'PA_TOTAL'};
config{25}.spike_overtime.ignore_pulses      = 'yes';
config{25}.spike_overtime.ignore_puffs       = 'yes';
config{25}.spike_overtime.window.size        = 30;%seconds
config{25}.spike_overtime.window.step        = 30;%seconds
config{25}.plotstim                          ='patch';