function tms_tfr_intra(irat)

%% Set parameters
if ispc
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\external;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;
elseif isunix
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/fieldtrip;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/external;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/ced-functions;
end

ft_defaults

config = tms_setparams;

%load converted data
fprintf('reading %s\n',fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']));
load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']),'data');

%find t0
t_stim_start = data.markers.markers.(config{irat}.stim_marker).synctime(1);%take the first stim artefact as the begining of the stim

%keep timings for the rest of the analysis
%ft_getopt : return empty values if the marker exist but has no events
t_puffs     = ft_getopt(data.markers.markers.(config{irat}.puff.channel),'synctime', []);%store all puff times to remove windows in those periods

%remove AP of data Vm to compute mean and std
data.Vm_cleaned = data.Vm;
t_PA_remove = data.markers.markers.(config{irat}.vm_over_time.remove_spikes.spikechan).synctime;
ft_progress('init','text',sprintf('Rat %d : cleaning PA from Vm',irat));
for i_PA = 1:size(t_PA_remove,2)
    ft_progress(i_PA/size(t_PA_remove,2), 'PA %d from %d', i_PA, size(t_PA_remove,2));
    PA_idx          = round((t_PA_remove(i_PA) - data.Vm.time{1}(1)) * data.Vm.fsample);
    toremove_start  = PA_idx + round(config{irat}.vm_over_time.remove_spikes.toi(1)/1000*data.Vm.fsample);
    if toremove_start<1
        toremove_start = 1;
    end
    toremove_end    = PA_idx + round(config{irat}.vm_over_time.remove_spikes.toi(2)/1000*data.Vm.fsample);
    if toremove_end > size(data.Vm.time{1},2) %au cas où la fenêtre du spike dépasse le dernier point des données
        toremove_end = size(data.Vm.time{1},2);
    end
    data.Vm_cleaned.trial{1}(toremove_start:toremove_end) = nan(size(toremove_start:toremove_end));
end
ft_progress('close');

%interpolate to do not have discontinuous data for timefrequency
%analysis
data.Vm_cleaned.trial{1} = fillmissing(data.Vm_cleaned.trial{1}, 'linear');

%sanity plot to check if AP were well removed
fprintf('plot Vm without spikes\n');
fig = figure;hold on;
plot(data.Vm.time{1},data.Vm.trial{1});
plot(data.Vm_cleaned.time{1},data.Vm_cleaned.trial{1});
fig_name = fullfile(config{irat}.imagesavedir,'TFR','clean_APs',[config{irat}.prefix,'vm_cleaned_PA.png']);
if ~isfolder(fileparts(fig_name))
    fprintf('Creating directory %s', fileparts(fig_name));
    mkdir(fileparts(fig_name));
end
print(fig, '-dpng',fig_name,'-r600');
close all;

%resample data
cfgtemp             = [];
cfgtemp.resamplefs  = 300; 
data.Vm_cleaned     = ft_resampledata(cfgtemp, data.Vm_cleaned);

%hp filter to avoid weird effects due to offset
cfgtemp             = [];
cfgtemp.hpfilter    = 'yes';
cfgtemp.hpfreq      = 1;
cfgtemp.hpinstabilityfix = 'reduce';
%plot(data.Vm_cleaned.time{1}, data.Vm_cleaned.trial{1});

%% freq analysis
cfgtemp            = [];
cfgtemp.method     = 'mtmconvol';
cfgtemp.output     = 'pow';
cfgtemp.taper      = 'dpss';
cfgtemp.tapsmofrq  = 2;
cfgtemp.foi        = 1:0.5:25;
cfgtemp.pad        = 'nextpow2';
%cfgtemp.t_ftimwin  = ones(1,length(cfgtemp.foi)).*15; %15 s : pour avoir le plot sur les 2h d'enregistrement
cfgtemp.t_ftimwin  = ones(1,length(cfgtemp.foi)).*3; %3s : pour avoir les plots sur 10s
cfgtemp.toi        = data.Vm_cleaned.time{1}(1) : 0.5 : data.Vm_cleaned.time{1}(end);
%cfgtemp.toi        = data.Vm_cleaned.time{1}(1) - 2 : 5 : data.Vm_cleaned.time{1}(end);
TFR                = ft_freqanalysis(cfgtemp,data.Vm_cleaned);

%remove cfg as it takes lot of space on disk
TFR = rmfield(TFR, 'cfg');

%remove pulses and puffs
toremove = false(size(TFR.time));
for i_window = 1:size(TFR.time, 2)
    for ifreq = 1:size(TFR.freq, 2)
        %window is centered on each toi
        twin_start = TFR.time(i_window) - cfgtemp.t_ftimwin(ifreq)/2;
        twin_end   = TFR.time(i_window) + cfgtemp.t_ftimwin(ifreq)/2;
        
        %find window samples
        startsample.Im = round(twin_start*data.Im.fsample) + 1;
        if startsample.Im <1
            startsample.Im = 1;
        end
        endsample.Im   = round(twin_end*data.Im.fsample) + 1;
        if endsample.Im > size(data.Im.trial{1}, 2)
            endsample.Im = size(data.Im.trial{1}, 2);
        end
        
        %remove pulses
        % ignorer la fenetre si mean(abs(canal I)) est supérieur à 0.01 
        max_im            = max(abs(data.Im.trial{1}(startsample.Im:endsample.Im)));
        if max_im > config{irat}.im_threshold
            toremove(i_window) = true;
        end
        
        % remove puffs
        % ignorer la fenetre si trigger puff -> trigger puff + 1s est présent dans la fenetre
        haspulse_before  = any(abs(t_puffs - twin_start) < 1);
        haspulse_after   = any(abs(t_puffs - twin_end) < 1);
        haspulse_inside  = any(abs(t_puffs>twin_start & t_puffs < twin_end));
        haspulse         = haspulse_before || haspulse_after || haspulse_inside;
        if haspulse
            toremove(i_window) = true;
        end
    end
end

%clean TFR : replace artefacted windows by nans
TFR.powspctrm(:,:,toremove) = nan( size(TFR.powspctrm,1), size(TFR.powspctrm,2), sum(toremove) );

%set t0 at stim_start
TFR.time = TFR.time - t_stim_start;

% save TFR data
save(fullfile(config{irat}.datasavedir, sprintf('%sTFR_smooth', config{irat}.prefix)), 'TFR', '-v7.3');

%% plot

%plot raw TFR
fig = figure;
subplot(2,1,1);
cfgtemp                 = [];
TFR.tokeep = ~isnan(TFR.powspctrm);
cfgtemp.maskparameter   = 'tokeep';
cfgtemp.maskalpha       = 0.5;
cfgtemp.zlim            = 'maxmin';
cfgtemp.ylim            = [1 50];
cfgtemp.xlim            = [TFR.time(1) + 20, TFR.time(end) - 20];
cfgtemp.figure          = gcf;
cfgtemp.interactive     = 'no';
cfgtemp.colormap        = jet;
ft_singleplotTFR(cfgtemp, TFR);

title('Raw');
ft_pimpplot(gcf, jet, true);

%plot stim
hold on;
y = ylim;
plot([0 0], y, 'r', 'LineWidth', 2);
plot([600 600], y, 'r', 'LineWidth', 2);

%correct baseline
cfgtemp                 = [];
cfgtemp.baseline        = [TFR.time(1), 0]; %all before zero
cfgtemp.baselinetype    = 'relchange'; %-mean /mean
TFR_blcorrected         = ft_freqbaseline(cfgtemp, TFR);

%plot TFR bl corrected
subplot(2,1,2);
cfgtemp                 = [];
cfgtemp.zlim            = [-1 1];
cfgtemp.xlim            = [TFR_blcorrected.time(1) + 20, TFR_blcorrected.time(end) - 20];
cfgtemp.figure          = gcf;
cfgtemp.interactive     = 'no';
TFR_blcorrected.tokeep  = ~isnan(TFR_blcorrected.powspctrm);
cfgtemp.maskparameter   = 'tokeep';
cfgtemp.maskalpha       = 0.5;

cfgtemp.colormap        = jet;
ft_singleplotTFR(cfgtemp, TFR_blcorrected);
ft_pimpplot(gcf, jet, true);

title('Baseline corrected');

%plot stim
hold on;
y = ylim;
plot([0 0], y, 'r', 'LineWidth', 2);
plot([600 600], y, 'r', 'LineWidth', 2);

fname = fullfile(config{irat}.imagesavedir, 'TFR_smooth', sprintf('%sTFR_%s', config{irat}.prefix));

%save plot
if ~isfolder(fileparts(fname))
    fprintf('creating directory %s\n', fileparts(fname))
    mkdir(fileparts(fname));
end

print(fig, '-dpng',[fname, '.png'],'-r600');
close(fig);