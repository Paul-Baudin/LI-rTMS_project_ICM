function tms_tfr_intra_plot_example(irat)

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

%load config
% config = tms_setparams_verification_artifacts;
config = tms_setparams;

%% parameters
%POUR RAT 7 ET 19
winsize = 10; %seconds
%     toilist{7}  = [-854.4, 626, 3290]; %les 3 exemples illustrés dans l'article
toilist{7}  = [-854.4, 626, 3290, -900:winsize:-800, 600:winsize:700, 3250:winsize:3350]; 
%     toilist{19} = [-866, 611, 3125.5]; %les 3 exemples illustrés dans l'article
toilist{19} = [-866, 611, 3125.5, -900:winsize:-800, 600:winsize:700, 3100:winsize:3200]; 

%% load Vm, remove APs, load TFR
%load converted data
fprintf('reading %s\n',fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']));
load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']),'data');

%load TFR
load(fullfile(config{irat}.datasavedir, sprintf('%sTFR_smooth', config{irat}.prefix)), 'TFR');

%correct baseline
cfgtemp = [];
cfgtemp.baseline = [-600, 0];
cfgtemp.baselinetype = 'relchange';
TFR_blcorrected = ft_freqbaseline(cfgtemp, TFR);

%find t0
t_stim_start = data.markers.markers.(config{irat}.stim_marker).synctime(1);%take the first stim artefact as the begining of the stim
% t_stim_end   = data.markers.markers.(config{irat}.stim_marker).synctime(end);%take the first stim artefact as the begining of the stim

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

data.Vm_cleaned.trial{1} = fillmissing(data.Vm_cleaned.trial{1}, 'linear');

data.Vm_cleaned.time{1} = data.Vm_cleaned.time{1} - t_stim_start;
data.Vm.time{1}         = data.Vm.time{1} - t_stim_start;

%% plot

for toi = toilist{irat}
    for ibl = ["raw", "blcorrected"]
        
        cfgtemp         = [];
        cfgtemp.latency = [toi toi+winsize];
        vm_toi          = ft_selectdata(cfgtemp, data.Vm);
        vm_cleaned_toi  = ft_selectdata(cfgtemp, data.Vm_cleaned);
        tfr_toi.raw        = ft_selectdata(cfgtemp, TFR);
        tfr_toi.blcorrected  = ft_selectdata(cfgtemp, TFR_blcorrected);
        
        if any(any((isnan(tfr_toi.(ibl).powspctrm))))
            fprintf('toi %d is ignored because it has nan\n', toi);
            continue
        end
        
        fig = figure;
        
        %plot TFR
        subplot(3,1,3); hold on;
        cfgtemp = [];
                
        % smooth 1 window 3s
        if ibl == "raw"
            cfgtemp.zlim = [0 0.4];
        elseif ibl == "blcorrected"
            cfgtemp.zlim = [-1.5 1.5];
        end
       
        cfgtemp.figure          = fig;
        cfgtemp.interactive     = 'no';
        cfgtemp.colormap        = jet;
        ft_singleplotTFR(cfgtemp, tfr_toi.(ibl));
        xlim([toi toi+winsize]);
        
        ft_pimpplot(fig, jet, true);
        set(gca, 'fontsize', 15, 'tickdir', 'out');
        
        %plot raw Vm
        subplot(3,1,1);
        plot(vm_toi.time{1}, vm_toi.trial{1}, 'k');
        ylim([-110 25]);
        xlim([toi toi+winsize]);
        set(gca, 'fontsize', 15, 'tickdir', 'out');
        
        %plot cleaned Vm
        subplot(3,1,2);
        plot(vm_cleaned_toi.time{1}, vm_cleaned_toi.trial{1}, 'k');
        ylim([-110 25]);
        xlim([toi toi+winsize]);
        set(gca, 'fontsize', 15, 'tickdir', 'out');
        
		figname = fullfile(config{irat}.imagesavedir, 'TFR_example_smooth_for_selection_3', sprintf('%sTFR_example_%d_%s', config{irat}.prefix, round(toi), ibl));
        
        if ~isfolder(fileparts(figname))
            fprintf('Creating directory : %s\n', fileparts(figname));
            mkdir(fileparts(figname));
        end
        
        fprintf('Print image to : %s\n', [figname, '.png']);
        print(fig, '-dpng',[figname, '.png'],'-r600');
        
        fprintf('Print image to : %s\n', [figname, '.pdf']);
        print(fig, '-dpdf',[figname, '.pdf'],'-r600');
        
        close all
    end
end