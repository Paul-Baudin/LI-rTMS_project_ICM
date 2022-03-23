function [config] = tms_setparams

disp('setting parameters for tms intracellular data');

if ismac
    error('Platform not supported')
elseif isunix
    rootpath_analysis	= '/network/lustre/iss01/charpier/analyses/tms/';
    rootpath_data       = '/network/lustre/iss01/charpier/analyses/tms/raw/QX/';
elseif ispc
    rootpath_analysis	= '\\lexport\iss01.charpier\analyses\tms\';
    rootpath_data       = '\\lexport\iss01.charpier\analyses\tms\raw\QX\';
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

configcommon.vm_over_time.remove_spikes.toi         = [-10 30];%ms, remove before and after spike timing
configcommon.vm_over_time.remove_spikes.spikechan   = 'PA_TOTAL';%channel with AP timings
configcommon.vm_over_time.window.size            = 10;%seconds
configcommon.vm_over_time.window.step            = 10;%seconds
configcommon.vm_over_time.ignore_pulses          = 'yes';
configcommon.vm_over_time.ignore_puffs           = 'yes'; 

configcommon.spike_overtime.window.step    = 10;%seconds
configcommon.spike_overtime.morpho_toi     = [-3 3];%ms : time of PA morpho

configcommon.has_big_offset = [];%
configcommon.instable_baseline = []; %

configcommon.rat_list_spikefreq =[1 2 3 4 5 6 7 8];
configcommon.rat_list_spikefreq_ctrl =[]; 

%% Rat 1
config{1}                                   = configcommon;
config{1}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{1}.prefix                            = 'QX-833-'; %leave the '-' at the end
config{1}.readCED.datapath                  = fullfile(rootpath_data,'833_09062020_QX314_2.smrx'); %with the extension
config{1}.spike_overtime.baseline           = 'begin';
config{1}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{1}.vm_over_time.baseline             = 'begin';
config{1}.vm_over_time.baselinewindow       = [0 60];
config{1}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %,'PA_STIM'
config{1}.spike_overtime.ignore_pulses      = 'no';
config{1}.spike_overtime.ignore_puffs       = 'no';
config{1}.spike_overtime.window.size        = 30;%seconds
config{1}.plotstim                          ='lines';

%% Rat 2
config{2}                                   = configcommon;
config{2}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{2}.prefix                            = 'QX-1749-'; %leave the '-' at the end
config{2}.readCED.datapath                  = fullfile(rootpath_data,'1749_11062020.smrx'); %with the extension
config{2}.spike_overtime.baseline           = 'begin';
config{2}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{2}.vm_over_time.baseline             = 'begin';
config{2}.vm_over_time.baselinewindow       = [0 60];
config{2}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %,'PA_STIM'
config{2}.spike_overtime.ignore_pulses      = 'no';
config{2}.spike_overtime.ignore_puffs       = 'no';
config{2}.spike_overtime.window.size        = 30;%seconds
config{2}.plotstim                          ='lines';

%% Rat 3
config{3}                                   = configcommon;
config{3}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{3}.prefix                            = 'QX-3051-'; %leave the '-' at the end
config{3}.readCED.datapath                  = fullfile(rootpath_data,'3051_18062020.smrx'); %with the extension
config{3}.spike_overtime.baseline           = 'begin';
config{3}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{3}.vm_over_time.baseline             = 'begin';
config{3}.vm_over_time.baselinewindow       = [0 60];
config{3}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_STIM'
config{3}.spike_overtime.ignore_pulses      = 'no';
config{3}.spike_overtime.ignore_puffs       = 'no';
config{3}.spike_overtime.window.size        = 30;%seconds
config{3}.plotstim                          ='lines';

%% Rat 4
config{4}                                   = configcommon;
config{4}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{4}.prefix                            = 'QX-1626-'; %leave the '-' at the end
config{4}.readCED.datapath                  = fullfile(rootpath_data,'1626_17112021_QX314.smrx'); %with the extension
config{4}.spike_overtime.baseline           = 'begin';
config{4}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{4}.vm_over_time.baseline             = 'begin';
config{4}.vm_over_time.baselinewindow       = [0 60];
config{4}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %, 'PA_STIM'
config{4}.spike_overtime.ignore_pulses      = 'no';
config{4}.spike_overtime.ignore_puffs       = 'no';
config{4}.spike_overtime.window.size        = 30;%seconds
config{4}.plotstim                          ='lines';

%% Rat 5
config{5}                                   = configcommon;
config{5}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{5}.prefix                            = 'QX-3000-'; %leave the '-' at the end
config{5}.readCED.datapath                  = fullfile(rootpath_data,'3000_17112021_QX314.smrx'); %with the extension
config{5}.spike_overtime.baseline           = 'begin';
config{5}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{5}.vm_over_time.baseline             = 'begin';
config{5}.vm_over_time.baselinewindow       = [0 60];
config{5}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %,'PA_STIM'
config{5}.spike_overtime.ignore_pulses      = 'no';
config{5}.spike_overtime.ignore_puffs       = 'no';
config{5}.spike_overtime.window.size        = 30;%seconds
config{5}.plotstim                          ='lines';

%% Rat 6
config{6}                                   = configcommon;
config{6}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{6}.prefix                            = 'QX-2609-'; %leave the '-' at the end
config{6}.readCED.datapath                  = fullfile(rootpath_data,'2609_17112021_QX314.smrx'); %with the extension
config{6}.spike_overtime.baseline           = 'begin';
config{6}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{6}.vm_over_time.baseline             = 'begin';
config{6}.vm_over_time.baselinewindow       = [0 60];
config{6}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %,'PA_STIM'
config{6}.spike_overtime.ignore_pulses      = 'no';
config{6}.spike_overtime.ignore_puffs       = 'no';
config{6}.spike_overtime.window.size        = 30;%seconds
config{6}.plotstim                          ='lines';

%% Rat 7
config{7}                                   = configcommon;
config{7}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{7}.prefix                            = 'QX-2373-'; %leave the '-' at the end
config{7}.readCED.datapath                  = fullfile(rootpath_data,'2373_17112021_QX314.smrx'); %with the extension
config{7}.spike_overtime.baseline           = 'begin';
config{7}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{7}.vm_over_time.baseline             = 'begin';
config{7}.vm_over_time.baselinewindow       = [0 60];
config{7}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %,'PA_STIM'
config{7}.spike_overtime.ignore_pulses      = 'no';
config{7}.spike_overtime.ignore_puffs       = 'no';
config{7}.spike_overtime.window.size        = 30;%seconds
config{7}.plotstim                          ='lines';

%% Rat 8
config{8}                                   = configcommon;
config{8}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{8}.prefix                            = 'QX-2683-'; %leave the '-' at the end
config{8}.readCED.datapath                  = fullfile(rootpath_data,'2683_17112021_QX314.smrx'); %with the extension
config{8}.spike_overtime.baseline           = 'begin';
config{8}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{8}.vm_over_time.baseline             = 'begin';
config{8}.vm_over_time.baselinewindow       = [0 60];
config{8}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %,'PA_STIM'
config{8}.spike_overtime.ignore_pulses      = 'no';
config{8}.spike_overtime.ignore_puffs       = 'no';
config{8}.spike_overtime.window.size        = 30;%seconds
config{8}.plotstim                          ='lines';

%% Rat 9
config{9}                                   = configcommon;
config{9}.name                              = {'vm_over_time','spikefreq_over_time'};%say which analysis to do for this rat
config{9}.prefix                            = 'QX-3441-'; %leave the '-' at the end
config{9}.readCED.datapath                  = fullfile(rootpath_data,'3441_17112021_QX314.smrx'); %with the extension
config{9}.spike_overtime.baseline           = 'begin';
config{9}.spike_overtime.baselinewindow     = [0 60]; %needed if baseline = 'begin' : [0 60];
config{9}.vm_over_time.baseline             = 'begin';
config{9}.vm_over_time.baselinewindow       = [0 60];
config{9}.spike_overtime.spikechannels      = {'PA_TOTAL'}; %,'PA_STIM'
config{9}.spike_overtime.ignore_pulses      = 'no';
config{9}.spike_overtime.ignore_puffs       = 'no';
config{9}.spike_overtime.window.size        = 30;%seconds
config{9}.plotstim                          ='lines';

