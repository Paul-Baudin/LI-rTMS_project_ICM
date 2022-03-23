function [config] = tms_setparams_verification_artifacts

disp('setting parameters for tms intracellular data');

if ismac
    error('Platform not supported')
elseif isunix
    rootpath_analysis	= '/network/lustre/iss01/charpier/analyses/tms/';
    rootpath_data       = '/network/lustre/iss01/charpier/analyses/tms/raw/Chloe/';
elseif ispc
    rootpath_analysis	= '\\lexport\iss01.charpier\analyses\tms\';
    rootpath_data       = '\\lexport\iss01.charpier\analyses\tms\raw\Chloe\';
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

configcommon.stim_marker               = 'Fake_Artifacts';
configcommon.im_threshold              = 0.1; %nA, threshold to ignore window if abs of current is more than it
configcommon.puff.channel              = 'Puffs'; 
configcommon.puff.remove_duration      = 1; %second

configcommon.vm_over_time.remove_spikes.toi         = [-10 30];%ms, remove before and after spike timing
configcommon.vm_over_time.remove_spikes.spikechan   = 'PA_TOTAL';%channel with AP timings
configcommon.vm_over_time.window.size            = 10;%seconds
configcommon.vm_over_time.window.step            = 1;%seconds
configcommon.vm_over_time.ignore_pulses          = 'yes';
configcommon.vm_over_time.ignore_puffs           = 'yes'; 

configcommon.spike_overtime.window.step    = 1;%seconds
configcommon.spike_overtime.morpho_toi     = [-3 3];%ms : time of PA morpho

configcommon.has_big_offset = [10 14];

configcommon.rat_list_spikefreq = [7 8 12 14 18 22 20 21];
configcommon.rat_list_spikefreq_ctrl = [7 12 14 22 23 24 25];

%% Rat 1
config{1}                                   = configcommon;
config{1}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{1}.prefix                            = '803_real_artifacts-'; %leave the '-' at the end
config{1}.readCED.datapath                  = fullfile(rootpath_data,'803_rTMS_Ctrl.smrx'); %with the extension
config{1}.vm_over_time.baseline             = 'prestim';%'begining'
config{1}.vm_over_time.baselinewindow       = [-600 0];
config{1}.spike_overtime.baseline           = 'prestim';%'begining'
config{1}.spike_overtime.baselinewindow     = [-600 0];%needed if baseline = 'begin' : [0 60];
config{1}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{1}.spike_overtime.ignore_pulses      = 'yes';
config{1}.spike_overtime.ignore_puffs       = 'yes';
config{1}.spike_overtime.window.size        = 30;%seconds
config{1}.plotstim                          ='patch';
config{1}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing


%% Rat 2 Fake Artifacts
config{2}                                   = configcommon;
config{2}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{2}.readCED.datapath                  = fullfile(rootpath_data,'803_rTMS_Ctrl.smrx'); %with the extension
config{2}.vm_over_time.baseline             = 'prestim';%'begining'
config{2}.vm_over_time.baselinewindow       = [-600 0];
config{2}.spike_overtime.baseline           = 'prestim';%'begining'
config{2}.spike_overtime.baselinewindow     = [-600 0];%needed if baseline = 'begin' : [0 60];
config{2}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{2}.spike_overtime.ignore_pulses      = 'yes';
config{2}.spike_overtime.ignore_puffs       = 'yes';
config{2}.spike_overtime.window.size        = 30;%seconds
config{2}.plotstim                          ='patch';
config{2}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing


config{2}.prefix                            = '803_fake_artifacts-';
config{2}.readCED.chan_Vm                   = 'VmFakeRem';

%% Rat 3
config{3}                                   = configcommon;
config{3}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{3}.prefix                            = '1284_real_artifacts-'; %leave the '-' at the end
config{3}.readCED.datapath                  = fullfile(rootpath_data,'1284_rTMS_Ctrl.smrx'); %with the extension
config{3}.vm_over_time.baseline             = 'prestim';%'begining'
config{3}.vm_over_time.baselinewindow       = [-600 0];
config{3}.spike_overtime.baseline           = 'prestim';%'begining'
config{3}.spike_overtime.baselinewindow     = [-600 0];
config{3}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{3}.spike_overtime.ignore_pulses      = 'yes';
config{3}.spike_overtime.ignore_puffs       = 'yes';
config{3}.spike_overtime.window.size        = 50;%seconds
config{3}.plotstim                          ='patch';

%% Rat 4 Fake Artifacts
config{4}                                   = configcommon;
config{4}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{4}.readCED.datapath                  = fullfile(rootpath_data,'1284_rTMS_Ctrl.smrx'); %with the extension
config{4}.vm_over_time.baseline             = 'prestim';%'begining'
config{4}.vm_over_time.baselinewindow       = [-600 0];
config{4}.spike_overtime.baseline           = 'prestim';%'begining'
config{4}.spike_overtime.baselinewindow     = [-600 0];
config{4}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{4}.spike_overtime.ignore_pulses      = 'yes';
config{4}.spike_overtime.ignore_puffs       = 'yes';
config{4}.spike_overtime.window.size        = 50;%seconds
config{4}.plotstim                          ='patch';

config{4}.prefix                            = '1284_fake_artifacts-';
config{4}.readCED.chan_Vm                   = 'VmFakeRem';

%% Rat 5
config{5}                                   = configcommon;
config{5}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{5}.prefix                            = '1834_real_artifacts-'; %leave the '-' at the end
config{5}.readCED.datapath                  = fullfile(rootpath_data,'1834_rTMS_Ctrl.smrx'); %with the extension
config{5}.vm_over_time.baseline             = 'prestim';%'begining'
config{5}.vm_over_time.baselinewindow       = [-600 0];
config{5}.spike_overtime.baseline           = 'prestim';%'begining'
config{5}.spike_overtime.baselinewindow     = [-600 0];
config{5}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{5}.spike_overtime.ignore_pulses      = 'yes';
config{5}.spike_overtime.ignore_puffs       = 'yes';
config{5}.spike_overtime.window.size        = 50;%seconds
config{5}.plotstim                          ='patch';

%% Rat 6 Fake Artifacts
config{6}                                   = configcommon;
config{6}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{6}.readCED.datapath                  = fullfile(rootpath_data,'1834_rTMS_Ctrl.smrx'); %with the extension
config{6}.vm_over_time.baseline             = 'prestim';%'begining'
config{6}.vm_over_time.baselinewindow       = [-600 0];
config{6}.spike_overtime.baseline           = 'prestim';%'begining'
config{6}.spike_overtime.baselinewindow     = [-600 0];
config{6}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{6}.spike_overtime.ignore_pulses      = 'yes';
config{6}.spike_overtime.ignore_puffs       = 'yes';
config{6}.spike_overtime.window.size        = 50;%seconds
config{6}.plotstim                          ='patch';

config{6}.prefix                            = '1834_fake_artifacts-';
config{6}.readCED.chan_Vm                   = 'VmFakeRem';

%% Rat 7
config{7}                                   = configcommon;
config{7}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{7}.prefix                            = '1841_real_artifacts-'; %leave the '-' at the end
config{7}.readCED.datapath                  = fullfile(rootpath_data,'1841_rTMS_Ctrl.smrx'); %with the extension
config{7}.vm_over_time.baseline             = 'prestim';%'begining'
config{7}.vm_over_time.baselinewindow       = [-600 0];
config{7}.spike_overtime.baseline           = 'prestim';%'begining'
config{7}.spike_overtime.baselinewindow     = [-600 0];
config{7}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{7}.spike_overtime.ignore_pulses      = 'yes';
config{7}.spike_overtime.ignore_puffs       = 'yes';
config{7}.spike_overtime.window.size        = 30;%seconds
config{7}.plotstim                          ='patch';

%% Rat 8 Fake Artifacts
config{8}                                   = configcommon;
config{8}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{8}.readCED.datapath                  = fullfile(rootpath_data,'1841_rTMS_Ctrl.smrx'); %with the extension
config{8}.vm_over_time.baseline             = 'prestim';%'begining'
config{8}.vm_over_time.baselinewindow       = [-600 0];
config{8}.spike_overtime.baseline           = 'prestim';%'begining'
config{8}.spike_overtime.baselinewindow     = [-600 0];
config{8}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{8}.spike_overtime.ignore_pulses      = 'yes';
config{8}.spike_overtime.ignore_puffs       = 'yes';
config{8}.spike_overtime.window.size        = 30;%seconds
config{8}.plotstim                          ='patch';


config{8}.prefix                            = '1841_fake_artifacts-';
config{8}.readCED.chan_Vm                   = 'VmFakeRem';

%% Rat 9
config{9}                                   = configcommon;
config{9}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{9}.prefix                            = '2090_real_artifacts-'; %leave the '-' at the end
config{9}.readCED.datapath                  = fullfile(rootpath_data,'2090_rTMS_Ctrl.smrx'); %with the extension
config{9}.vm_over_time.baseline             = 'prestim';%'begining'
config{9}.vm_over_time.baselinewindow       = [-600 0];
config{9}.spike_overtime.baseline           = 'prestim';%'begining'
config{9}.spike_overtime.baselinewindow     = [-600 0];
config{9}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{9}.spike_overtime.ignore_pulses      = 'yes';
config{9}.spike_overtime.ignore_puffs       = 'yes';
config{9}.spike_overtime.window.size        = 50;%seconds
config{9}.plotstim                          ='patch';

%% Rat 10 Fake Artifacts
config{10}                                   = configcommon;
config{10}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{10}.readCED.datapath                  = fullfile(rootpath_data,'2090_rTMS_Ctrl.smrx'); %with the extension
config{10}.vm_over_time.baseline             = 'prestim';%'begining'
config{10}.vm_over_time.baselinewindow       = [-600 0];
config{10}.spike_overtime.baseline           = 'prestim';%'begining'
config{10}.spike_overtime.baselinewindow     = [-600 0];
config{10}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{10}.spike_overtime.ignore_pulses      = 'yes';
config{10}.spike_overtime.ignore_puffs       = 'yes';
config{10}.spike_overtime.window.size        = 50;%seconds
config{10}.plotstim                          ='patch';

config{10}.prefix                            = '2090_fake_artifacts-';
config{10}.readCED.chan_Vm                   = 'VmFakeRem';

%% Rat 11
config{11}                                   = configcommon;
config{11}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{11}.prefix                            = '2343_real_artifacts-'; %leave the '-' at the end
config{11}.readCED.datapath                  = fullfile(rootpath_data,'2343_rTMS_Ctrl.smrx'); %with the extension
config{11}.vm_over_time.baseline             = 'prestim';%'begining'
config{11}.vm_over_time.baselinewindow       = [-600 0];
config{11}.spike_overtime.baseline           = 'prestim';%'begining'
config{11}.spike_overtime.baselinewindow     = [-600 0];
config{11}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{11}.spike_overtime.ignore_pulses      = 'yes';
config{11}.spike_overtime.ignore_puffs       = 'yes';
config{11}.spike_overtime.window.size        = 50;%seconds
config{11}.plotstim                          ='patch';

%% Rat 12 Fake Artifacts
config{12}                                   = configcommon;
config{12}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{12}.readCED.datapath                  = fullfile(rootpath_data,'2343_rTMS_Ctrl.smrx'); %with the extension
config{12}.vm_over_time.baseline             = 'prestim';%'begining'
config{12}.vm_over_time.baselinewindow       = [-600 0];
config{12}.spike_overtime.baseline           = 'prestim';%'begining'
config{12}.spike_overtime.baselinewindow     = [-600 0];
config{12}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{12}.spike_overtime.ignore_pulses      = 'yes';
config{12}.spike_overtime.ignore_puffs       = 'yes';
config{12}.spike_overtime.window.size        = 50;%seconds
config{12}.plotstim                          ='patch';

config{12}.prefix                            = '2343_fake_artifacts-';
config{12}.readCED.chan_Vm                   = 'VmFakeRem';

%% Rat 13
config{13}                                   = configcommon;
config{13}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{13}.prefix                            = '2409_real_artifacts-'; %leave the '-' at the end
config{13}.readCED.datapath                  = fullfile(rootpath_data,'2409_rTMS_Ctrl.smrx'); %with the extension
config{13}.vm_over_time.baseline             = 'prestim';%'begining'
config{13}.vm_over_time.baselinewindow       = [-600 0];
config{13}.spike_overtime.baseline           = 'prestim';%'begining'
config{13}.spike_overtime.baselinewindow     = [-600 0];
config{13}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{13}.spike_overtime.ignore_pulses      = 'yes';
config{13}.spike_overtime.ignore_puffs       = 'yes';
config{13}.spike_overtime.window.size        = 30;%seconds
config{13}.plotstim                          ='patch';

%% Rat 14 Fake Artifacts
config{14}                                   = configcommon;
config{14}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{14}.readCED.datapath                  = fullfile(rootpath_data,'2409_rTMS_Ctrl.smrx'); %with the extension
config{14}.vm_over_time.baseline             = 'prestim';%'begining'
config{14}.vm_over_time.baselinewindow       = [-600 0];
config{14}.spike_overtime.baseline           = 'prestim';%'begining'
config{14}.spike_overtime.baselinewindow     = [-600 0];
config{14}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{14}.spike_overtime.ignore_pulses      = 'yes';
config{14}.spike_overtime.ignore_puffs       = 'yes';
config{14}.spike_overtime.window.size        = 30;%seconds
config{14}.plotstim                          ='patch';

config{14}.prefix                            = '2409_fake_artifacts-';
config{14}.readCED.chan_Vm                   = 'VmFakeRem';

%% Rat 15
config{15}                                   = configcommon;
config{15}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{15}.prefix                            = '2417_real_artifacts-'; %leave the '-' at the end
config{15}.readCED.datapath                  = fullfile(rootpath_data,'2417_rTMS_Ctrl.smrx'); %with the extension
config{15}.vm_over_time.baseline             = 'prestim';%'begining'
config{15}.vm_over_time.baselinewindow       = [-600 0];
config{15}.spike_overtime.baseline           = 'prestim';%'begining'
config{15}.spike_overtime.baselinewindow     = [-600 0];
config{15}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{15}.spike_overtime.ignore_pulses      = 'yes';
config{15}.spike_overtime.ignore_puffs       = 'yes';
config{15}.spike_overtime.window.size        = 30;%seconds
config{15}.plotstim                          ='patch';

%% Rat 16 Fake Artifacts
config{16}                                   = configcommon;
config{16}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{16}.readCED.datapath                  = fullfile(rootpath_data,'2417_rTMS_Ctrl.smrx'); %with the extension
config{16}.vm_over_time.baseline             = 'prestim';%'begining'
config{16}.vm_over_time.baselinewindow       = [-600 0];
config{16}.spike_overtime.baseline           = 'prestim';%'begining'
config{16}.spike_overtime.baselinewindow     = [-600 0];
config{16}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{16}.spike_overtime.ignore_pulses      = 'yes';
config{16}.spike_overtime.ignore_puffs       = 'yes';
config{16}.spike_overtime.window.size        = 30;%seconds
config{16}.plotstim                          ='patch';

config{16}.prefix                            = '2417_fake_artifacts-';
config{16}.readCED.chan_Vm                   = 'VmFakeRem';

%% Rat 17
config{17}                                   = configcommon;
config{17}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{17}.prefix                            = '2948_real_artifacts-'; %leave the '-' at the end
config{17}.readCED.datapath                  = fullfile(rootpath_data,'2948_rTMS_Ctrl.smrx'); %with the extension
config{17}.vm_over_time.baseline             = 'prestim';%'begining'
config{17}.vm_over_time.baselinewindow       = [-600 0];
config{17}.spike_overtime.baseline           = 'prestim';%'begining'
config{17}.spike_overtime.baselinewindow     = [-600 0];
config{17}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{17}.spike_overtime.ignore_pulses      = 'yes';
config{17}.spike_overtime.ignore_puffs       = 'yes';
config{17}.spike_overtime.window.size        = 50;%seconds
config{17}.plotstim                          ='patch';

%% Rat 18 Fake Artifacts
config{18}                                   = configcommon;
config{18}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{18}.readCED.datapath                  = fullfile(rootpath_data,'2948_rTMS_Ctrl.smrx'); %with the extension
config{18}.vm_over_time.baseline             = 'prestim';%'begining'
config{18}.vm_over_time.baselinewindow       = [-600 0];
config{18}.spike_overtime.baseline           = 'prestim';%'begining'
config{18}.spike_overtime.baselinewindow     = [-600 0];
config{18}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{18}.spike_overtime.ignore_pulses      = 'yes';
config{18}.spike_overtime.ignore_puffs       = 'yes';
config{18}.spike_overtime.window.size        = 50;%seconds
config{18}.plotstim                          ='patch';

config{18}.prefix                            = '2948_fake_artifacts-';
config{18}.readCED.chan_Vm                   = 'VmFakeRem';

