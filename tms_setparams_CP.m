function [config] = tms_setparams

disp('setting parameters for tms intracellular data');

if ismac
    error('Platform not supported')
elseif isunix
    rootpath_analysis	= '/network/lustre/iss01/charpier/analyses/tms/';
    rootpath_data       = '/network/lustre/iss01/charpier/analyses/tms/raw/CP/';
elseif ispc
    rootpath_analysis	= '\\lexport\iss01.charpier\analyses\tms\';
    rootpath_data       = '\\lexport\iss01.charpier\analyses\tms\raw\CP\';
else
    error('Platform not supported')
end

datasavedir  = fullfile(rootpath_analysis,'data', 'CP'); %where to save matlab data
imagesavedir = fullfile(rootpath_analysis,'image', 'CP'); %where to save images

%% Config common for all rats
%subject infos
configcommon.name                      ={'Vm','spike_freq','spike_amp'};

configcommon.datasavedir               = datasavedir;
configcommon.imagesavedir              = imagesavedir;

configcommon.readCED.chan_Vm                   = 'Vm';
configcommon.readCED.chan_Im                   = 'Im';
configcommon.readCED.im_lpfreq                 = 100;%Hz. remove stim artefacts on Im

configcommon.artrm.triggers = 'ARTEFACTS';
configcommon.artrm.toi      = [-0.005 0.06]; %time to remove before and after each trigger, in seconds
configcommon.artrm.chan     = {'Vm', 'Im'};
configcommon.artrm.replace  = {'nan', 'linear'}; %nan, pchip, linear => one method per channel

configcommon.stim_marker               = 'ARTEFACTS';
configcommon.im_threshold              = 0.1; %nA, threshold to ignore window if abs of current is more than it
configcommon.puff.channel              = 'Puffs'; 
configcommon.puff.remove_duration      = 1; %second

configcommon.vm_over_time.remove_spikes.toi         = [-10 30];%ms, remove before and after spike timing
configcommon.vm_over_time.remove_spikes.spikechan   = 'PA_TOTAL';%channel with AP timings
configcommon.vm_over_time.window.size            = 10;%seconds
configcommon.vm_over_time.window.step            = 10;%seconds
configcommon.vm_over_time.ignore_pulses          = 'yes';
configcommon.vm_over_time.ignore_puffs           = 'yes'; 

configcommon.spike_overtime.window.step    = 10;%seconds
configcommon.spike_overtime.morpho_toi     = [-3 3];%ms : time of PA morpho

configcommon.has_big_offset = [];
configcommon.instable_baseline = [];

configcommon.rat_list_spikefreq =1:7; 
configcommon.rat_list_spikefreq_ctrl = [];


%% Rat 1
config{1}                                   = configcommon;
config{1}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{1}.prefix                            = '3689-'; %leave the '-' at the end
config{1}.readCED.datapath                  = fullfile(rootpath_data,'3689_06082021.smrx'); %with the extension
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

%% Rat 2
config{2}                                   = configcommon;
config{2}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{2}.prefix                            = '1210-'; %leave the '-' at the end
config{2}.readCED.datapath                  = fullfile(rootpath_data,'1210_07082021.smrx'); %with the extension
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

%% Rat 3
config{3}                                   = configcommon;
config{3}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{3}.prefix                            = '2608-'; %leave the '-' at the end
config{3}.readCED.datapath                  = fullfile(rootpath_data,'2608_12082021.smrx'); %with the extension
config{3}.vm_over_time.baseline             = 'prestim';%'begining'
config{3}.vm_over_time.baselinewindow       = [-600 0];
config{3}.spike_overtime.baseline           = 'prestim';%'begining'
config{3}.spike_overtime.baselinewindow     = [-600 0];
config{3}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{3}.spike_overtime.ignore_pulses      = 'yes';
config{3}.spike_overtime.ignore_puffs       = 'yes';
config{3}.spike_overtime.window.size        = 30;%seconds
config{3}.plotstim                          ='patch';
config{3}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing


%% Rat 4
config{4}                                   = configcommon;
config{4}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{4}.prefix                            = '3042-'; %leave the '-' at the end
config{4}.readCED.datapath                  = fullfile(rootpath_data,'3042_12082021.smrx'); %with the extension
config{4}.vm_over_time.baseline             = 'prestim';%'begining'
config{4}.vm_over_time.baselinewindow       = [-600 0];
config{4}.spike_overtime.baseline           = 'prestim';%'begining'
config{4}.spike_overtime.baselinewindow     = [-600 0];
config{4}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{4}.spike_overtime.ignore_pulses      = 'yes';
config{4}.spike_overtime.ignore_puffs       = 'yes';
config{4}.spike_overtime.window.size        = 30;%seconds
config{4}.plotstim                          ='patch';
config{4}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing


%% Rat 5
config{5}                                   = configcommon;
config{5}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{5}.prefix                            = '2015-'; %leave the '-' at the end
config{5}.readCED.datapath                  = fullfile(rootpath_data,'2015_12082021.smrx'); %with the extension
config{5}.vm_over_time.baseline             = 'prestim';%'begining'
config{5}.vm_over_time.baselinewindow       = [-600 0];
config{5}.spike_overtime.baseline           = 'prestim';%'begining'
config{5}.spike_overtime.baselinewindow     = [-600 0];
config{5}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{5}.spike_overtime.ignore_pulses      = 'yes';
config{5}.spike_overtime.ignore_puffs       = 'yes';
config{5}.spike_overtime.window.size        = 50;%seconds
config{5}.plotstim                          ='patch';
config{5}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing

%% Rat 6
config{6}                                   = configcommon;
config{6}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{6}.prefix                            = '2433-'; %leave the '-' at the end
config{6}.readCED.datapath                  = fullfile(rootpath_data,'2433_20082021.smrx'); %with the extension
config{6}.vm_over_time.baseline             = 'prestim';%'begining'
config{6}.vm_over_time.baselinewindow       = [-600 0];
config{6}.spike_overtime.baseline           = 'prestim';%'begining'
config{6}.spike_overtime.baselinewindow     = [-600 0];
config{6}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{6}.spike_overtime.ignore_pulses      = 'yes';
config{6}.spike_overtime.ignore_puffs       = 'yes';
config{6}.spike_overtime.window.size        = 30;%seconds
config{6}.plotstim                          ='patch';
config{6}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing

%% Rat 7
config{7}                                   = configcommon;
config{7}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{7}.prefix                            = '2773-'; %leave the '-' at the end
config{7}.readCED.datapath                  = fullfile(rootpath_data,'2773_25082021.smrx'); %with the extension
config{7}.vm_over_time.baseline             = 'prestim';%'begining'
config{7}.vm_over_time.baselinewindow       = [-600 0];
config{7}.spike_overtime.baseline           = 'prestim';%'begining'
config{7}.spike_overtime.baselinewindow     = [-600 0];
config{7}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_ISOL', 'PA_SPONT'
config{7}.spike_overtime.ignore_pulses      = 'yes';
config{7}.spike_overtime.ignore_puffs       = 'yes';
config{7}.spike_overtime.window.size        = 50;%seconds
config{7}.plotstim                          ='patch';
config{7}.vm_over_time.remove_spikes.toi    = [-10 40];%ms, remove before and after spike timing

