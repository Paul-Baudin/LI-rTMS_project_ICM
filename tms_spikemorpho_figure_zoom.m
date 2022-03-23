%recalculer les morphos de PA pour illustrer le nueurone 803 dans la figure 4.


% Set parameters
if ispc
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\external;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;
elseif isunix
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/fieldtrip;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/external;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/CEDMATLAB/CEDS64ML;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/ced-functions;
end

ft_defaults

%load config
config = tms_setparams;

%output for images
if ~isfolder(fullfile(config{8}.imagesavedir, 'spike_over_time'))
    fprintf('Creating directory %s\n', fullfile(config{8}.imagesavedir, 'spike_over_time'));
    mkdir(fullfile(config{8}.imagesavedir, 'spike_over_time'));
end


irat = 7;
zoom_PA = [-40 40]; %ms

%load converted data
fprintf('reading %s\n',fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']));
load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']), 'data');

%find t0
t_stim_start = data.markers.markers.(config{irat}.stim_marker).synctime(1);%take the first stim artefact as the begining of the stim
t_stim_end   = data.markers.markers.(config{irat}.stim_marker).synctime(end);%take the first stim artefact as the begining of the stim
t_stim       = data.markers.markers.(config{irat}.stim_marker).synctime;
t_stim       = t_stim -  t_stim_start; %zero is the first stim artefact

%keep timings for the rest of the analysis
%ft_getopt : return empty values if the marker exist but has no events
t_puffs     = ft_getopt(data.markers.markers.(config{irat}.puff.channel),'synctime', []);%store all puff times to remove windows in those periods

%keep spike timings
for spikechan_name = string(config{irat}.spike_overtime.spikechannels)
    t_PA.(spikechan_name)  = data.markers.markers.(spikechan_name).synctime;%store all puff times
end

%store t_stim for output
spike_morpho.t_stim_orig = data.markers.markers.(config{irat}.stim_marker).synctime;
spike_morpho.t_stim      = data.markers.markers.(config{irat}.stim_marker).synctime - t_stim_start;

%compute derivative of Vm
cfgtemp = [];
cfgtemp.derivative = 'yes';
data.Vm_derivative = ft_preprocessing(cfgtemp, data.Vm);


%% compute spike morpho for each spike
for spikechan_name = string(config{irat}.spike_overtime.spikechannels)
    ft_progress('init','text',sprintf('Rat %d, %s : go trough each spike', irat, spikechan_name));
    for i_PA = 1:size(t_PA.(spikechan_name), 2)
        ft_progress(i_PA/size(t_PA.(spikechan_name), 2), 'Spike %d from %d', i_PA, size(t_PA.(spikechan_name), 2));
        
        %store PA timing
        spike_morpho.(spikechan_name).time_orig(i_PA)       = t_PA.(spikechan_name)(i_PA);
        spike_morpho.(spikechan_name).time(i_PA)            = t_PA.(spikechan_name)(i_PA) - t_stim_start;
        
        %find PA idx
        PA_idx          = round((t_PA.(spikechan_name)(i_PA) - data.Vm.time{1}(1)) * data.Vm.fsample);
        PA_start  = PA_idx + round(zoom_PA(1)/1000*data.Vm.fsample);
        PA_end  = PA_idx + round(zoom_PA(2)/1000*data.Vm.fsample);
        
        %interpolate PA
        t_indx = PA_start:PA_end;
        t_sel = data.Vm.time{1}(t_indx);
        data_sel = data.Vm.trial{1}(t_indx);
        data_sel_derivative = data.Vm_derivative.trial{1}(t_indx);
        t_interp = linspace(t_sel(1),t_sel(end),1000);
        data_interp = pchip(t_sel,data_sel,t_interp);
        data_interp_derivative = pchip(t_sel,data_sel_derivative,t_interp);
        
        %compute and store values
        spike_morpho.(spikechan_name).waveform_interp{i_PA}.time = t_interp;
        spike_morpho.(spikechan_name).waveform_interp{i_PA}.waveform = data_interp;
        %compute peak amplitude
        [v, t] = findpeaks(data_interp,t_interp,'NPeaks',1,'SortStr','descend');
        if isempty(v)
            spike_morpho.(spikechan_name).peak.value(i_PA)  =  nan;
            spike_morpho.(spikechan_name).peak.time(i_PA)   =  nan;
        else
            spike_morpho.(spikechan_name).peak.value(i_PA)  =  v;
            spike_morpho.(spikechan_name).peak.time(i_PA)   =  t;
        end
        
        %             spike_morpho.(spikechan_name).peak.value(i_PA)      =  v;
        %             spike_morpho.(spikechan_name).peak.time(i_PA)       =  t;
        threshidx = find(data_interp_derivative>10,1,'first');
        if isempty(threshidx)
            spike_morpho.(spikechan_name).thresh.value(i_PA) = nan;
            spike_.morpho.(spikechan_name).thresh.time(i_PA) = nan;
            spike_morpho.(spikechan_name).amplitude(i_PA) = nan;
        else
            spike_morpho.(spikechan_name).thresh.value(i_PA) = data_interp(threshidx);
            spike_morpho.(spikechan_name).thresh.time(i_PA) = t_interp(threshidx);
            spike_morpho.(spikechan_name).amplitude(i_PA) = v - data_interp(threshidx);
        end
%         figure;hold;
%         plot(t_interp, data_interp);
%         plot(t_sel, data_sel,'r');
%         plot(t_interp, data_interp_derivative,'b');
%         scatter(t,v,'x');
%         scatter(t_interp(threshidx),data_interp(threshidx),'x');
    end
    ft_progress('close');
end
fprintf('write spike morpho data to %s\n', fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spike_morpho.mat']));
save(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spike_morpho_figure.mat']), 'spike_morpho', '-v7.3');
