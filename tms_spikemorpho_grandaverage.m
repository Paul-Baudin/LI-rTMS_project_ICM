% Set parameters
addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
addpath \\lexport\iss01.charpier\analyses\tms\scripts;
% addpath \\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML;
% addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;

ft_defaults

%load config
config = tms_setparams;

color.post = 'g';
color.baseline = 'b';
color.stim_induced = 'r';
color.stim_spont = [1 0.6 0.2]; %orange

%create output directory for images
if ~isfolder(fullfile(config{8}.imagesavedir,'spikemorpho'))
    fprintf('Creating directory %s\n', fullfile(config{8}.imagesavedir,'spikemorpho'));
    mkdir(fullfile(config{8}.imagesavedir,'spikemorpho'));
end

%load precomputed data
ft_progress('init','text');
for irat = 7:size(config,2)
    ft_progress(0, 'loading data of rat %d/%d', irat, size(config,2));
    if isempty(config{irat})
        continue
    end
    temp = load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spikefreq_over_time.mat']), 'spike_overtime');
    spike_overtime{irat} = temp.spike_overtime;
    clear temp
    
    temp = load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spike_morpho.mat']), 'spike_morpho');
    spike_morpho{irat} = temp.spike_morpho;
    clear temp
    
end
ft_progress('close');
    

%% select rats
for irat = 1:size(config,2)
    if isempty(config{irat})
        tokeep(irat) = false;
        continue
    end
    tokeep(irat) = false;
    %only for TMS rats
    if contains(config{irat}.prefix, 'TMS')  %|| irat == 16
        tokeep(irat) = true;
    end
    if ismember(irat, config{irat}.has_big_offset) 
        tokeep(irat) = false;
    end
end

config_cleaned       = config(tokeep);
spike_overtime_cleaned = spike_overtime(tokeep);
spike_morpho_cleaned = spike_morpho(tokeep);

%% overdraw (et mean+/-std) des PA raw => par neurones, une couleur par période (baseline, stim spont, stim induit, post)

for irat = 1:size(spike_morpho_cleaned, 2)
    data = spike_morpho_cleaned{irat}.PA_TOTAL.waveform_interp;
    t_stim_start = spike_morpho_cleaned{irat}.t_stim_orig(1);
    t_stim = spike_morpho_cleaned{irat}.t_stim_orig;
%     isi1 = [diff(spike_morpho_cleaned{irat}.PA_TOTAL.time), 1];
%     isi2 = [1, diff(spike_morpho_cleaned{irat}.PA_TOTAL.time)];
%     spike_isolated_idx = find(isi1 > 0.03 & isi2 > 0.03);
    
    fig = figure; hold on;
    datatemp.time = {};
    datatemp.trial = {};
    period = string.empty;
    for ispike = 1:size(spike_morpho_cleaned{irat}.PA_TOTAL.time, 2)
        data{ispike}.time = data{ispike}.time - t_stim_start; %ajouter - t_stim_start

        t_peak = spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike) - t_stim_start;
        if isnan(t_peak)
            continue
        end
        if max(data{ispike}.waveform) > 100
            continue
        end
        
        if t_peak > 0 && t_peak < 600 %dans la stim
            
            if ispike > 1
                if spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike) - spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike-1) < 0.03
                    continue
                end
            end
            if ispike < size(spike_morpho_cleaned{irat}.PA_TOTAL.time, 2)
                if spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike+1) - spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike) < 0.03
                    continue
                end
            end
            
            if any(abs(t_stim - t_stim_start - t_peak) < 0.003) 
                period(end+1) = "stim_induced";
                toremove = spike_morpho_cleaned{irat}.PA_TOTAL.waveform_interp{ispike}.time - t_stim_start < t_peak - 0.0001;
                data{ispike}.waveform(toremove) = nan;
            else
                period(end+1) = "stim_spont";
            end
            
        else %baseline ou post stim
            
            if ispike > 1
                if spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike) - spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike-1) < 0.1
                    continue
                end
            end
            if ispike < size(spike_morpho_cleaned{irat}.PA_TOTAL.time, 2)
                if spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike+1) - spike_morpho_cleaned{irat}.PA_TOTAL.peak.time(ispike) < 0.1
                    continue
                end
            end
            
            if spike_morpho_cleaned{irat}.PA_TOTAL.thresh.value(ispike) < -65 && irat ~=9
                continue
            end
            
            if t_peak < 0
                period(end+1) = "baseline";
            elseif t_peak > 600
                period(end+1) = "post";
            end
        end
        x = data{ispike}.time - t_peak;
        y = data{ispike}.waveform;
        
        p = plot(x, y, 'color', color.(period(end)));
        p.Color(4) = 0.2;
        
        datatemp.time{end+1} = x;
        datatemp.trial{end+1} = y;
        
    end
    
    set(gca, 'tickdir', 'out', 'fontsize', 15);
    n_PA.baseline       = sum(period == "baseline");
    n_PA.stim_spont     = sum(period == "stim_spont");
    n_PA.stim_induced   = sum(period == "stim_induced");
    n_PA.post           = sum(period == "post");
    
    title(sprintf('%s : %d baseline, %d stim ind, %d stim spont, %d post', config_cleaned{irat}.prefix(1:end-1), ...
        n_PA.baseline, n_PA.stim_induced, n_PA.stim_spont, n_PA.post), 'interpreter', 'none');
    fig_name = fullfile(config_cleaned{irat}.imagesavedir, 'spikemorpho', sprintf('%sPA_morpho_periods_raw', config_cleaned{irat}.prefix));
    print(fig, '-dpng',[fig_name, '.png'],'-r600');
    close all
    
    
    %plot avg +/- std
    datatemp.label = {'spikes'};
    
    fig = figure; hold on;
    
    for iperiod = ["baseline", "stim_spont", "stim_induced", "post"]
        if any(period == iperiod)
            cfgtemp = [];
            cfgtemp.trials = period == iperiod;
            spikeavg.(iperiod){irat} = ft_timelockanalysis(cfgtemp, datatemp);
            patch_std(spikeavg.(iperiod){irat}.time, spikeavg.(iperiod){irat}.avg, sqrt(spikeavg.(iperiod){irat}.var), color.(iperiod));
            p = plot(spikeavg.(iperiod){irat}.time, spikeavg.(iperiod){irat}.avg, 'color', color.(iperiod));
            p.ZData = ones(size(p.YData));
        else
            spikeavg.(iperiod){irat}.time = datatemp.time{1};
            spikeavg.(iperiod){irat}.avg  = nan(size(datatemp.time{1}));
            spikeavg.(iperiod){irat}.var  = nan(size(datatemp.time{1}));
        end
    end
    
    set(gca, 'tickdir', 'out', 'fontsize', 15);
    set(gcf, 'renderer', 'painters');
    title(sprintf('%s : %d baseline, %d stim ind, %d stim spont, %d post', config_cleaned{irat}.prefix(1:end-1), ...
        n_PA.baseline, n_PA.stim_induced, n_PA.stim_spont, n_PA.post), 'interpreter', 'none');
    fig_name = fullfile(config_cleaned{irat}.imagesavedir, 'spikemorpho', sprintf('%sPA_morpho_periods_mean', config_cleaned{irat}.prefix));
    print(fig, '-dpng',[fig_name, '.png'],'-r600');
    print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
    close all
    
end

%% PHASE PLOT : overdraw (ou mean+/-std) es PA avec dérivée (Dérivée en fonction de Vm) => par neurone, une couleur par période

%un plot par neurone

for irat = 1:size(spike_morpho_cleaned, 2)
    for do_norm_x = ["raw", "normalized"]
        fig = figure; hold on;
        
        for iperiod = ["baseline", "stim_spont", "stim_induced", "post"]
            if all(isnan(spikeavg.(iperiod){irat}.avg))
                continue
            end
                        
            spikeavg.(iperiod){irat}.time(isnan(spikeavg.(iperiod){irat}.avg)) = [];
            spikeavg.(iperiod){irat}.avg(isnan(spikeavg.(iperiod){irat}.avg)) = [];
            der = ft_preproc_derivative(spikeavg.(iperiod){irat}.avg, 1);
            
            t_smooth = 0.00015; %valeur par défaut Spike2
            samplefreq = 1/diff(spikeavg.(iperiod){irat}.time(1:2));
            n_samples = round(t_smooth*samplefreq);
            der = movmean(der, n_samples);
            
            %         figure;
            %
            %         yyaxis right
            %         plot(spikeavg.(iperiod){irat}.time, spikeavg.(iperiod){irat}.avg);
            %         yyaxis left
            %         plot(spikeavg.(iperiod){irat}.time, movmean(der, n_samples));
            
            x = spikeavg.(iperiod){irat}.avg;
            if do_norm_x == "normalized"
                x = normalize(x, 'range');
            end
            y = der;
            
            plot(x,y, 'color', color.(iperiod));
            
            %store data, separated on positive and negative to average
            %afterwards
            sel = y > 0;
            der_all_pos.(iperiod).time{irat} = x(sel);
            der_all_pos.(iperiod).trial{irat} = y(sel);
            
            sel = y <= 0;
            der_all_neg.(iperiod).time{irat} = x(sel);
            der_all_neg.(iperiod).trial{irat} = y(sel);
            
            der_all_pos.(iperiod).label = {'spikes'};
            der_all_neg.(iperiod).label = {'spikes'};
            
        end
        set(gca, 'tickdir', 'out', 'fontsize', 15);
        set(gcf, 'renderer', 'painters');
        title(config_cleaned{irat}.prefix(1:end-1), 'interpreter', 'none');
        fig_name = fullfile(config_cleaned{irat}.imagesavedir, 'spikemorpho', sprintf('%sPA_morpho_periods_derivative_%s', config_cleaned{irat}.prefix, do_norm_x));
        print(fig, '-dpng',[fig_name, '.png'],'-r600');
        print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
        close all
    end
end

%% overdraw (et mean+/-std) du neurone 803 pour figure 4

irat = 7;
temp = load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spike_morpho_figure.mat']), 'spike_morpho');
spikedata = temp.spike_morpho;
data = spikedata.PA_TOTAL.waveform_interp;

t_stim_start = spikedata.t_stim_orig(1);
t_stim = spikedata.t_stim_orig;
%     isi1 = [diff(spikedata.PA_TOTAL.time), 1];
%     isi2 = [1, diff(spikedata.PA_TOTAL.time)];
%     spike_isolated_idx = find(isi1 > 0.03 & isi2 > 0.03);

fig = figure; hold on;
datatemp.time = {};
datatemp.trial = {};
period = string.empty;
for ispike = 1:size(spikedata.PA_TOTAL.time, 2)
    data{ispike}.time = data{ispike}.time - t_stim_start; %ajouter - t_stim_start
    
    t_peak = spikedata.PA_TOTAL.peak.time(ispike) - t_stim_start;
    if isnan(t_peak)
        continue
    end
    if max(data{ispike}.waveform) > 100
        continue
    end
    
    if t_peak > 0 && t_peak < 600 %dans la stim
        
        if ispike > 1
            if spikedata.PA_TOTAL.peak.time(ispike) - spikedata.PA_TOTAL.peak.time(ispike-1) < 0.03
                continue
            end
        end
        if ispike < size(spikedata.PA_TOTAL.time, 2)
            if spikedata.PA_TOTAL.peak.time(ispike+1) - spikedata.PA_TOTAL.peak.time(ispike) < 0.03
                continue
            end
        end
        
        if any(abs(t_stim - t_stim_start - t_peak) < 0.003)
            period(end+1) = "stim_induced";
            toremove = spikedata.PA_TOTAL.waveform_interp{ispike}.time - t_stim_start < t_peak;
            data{ispike}.waveform(toremove) = nan;
        else
            period(end+1) = "stim_spont";
        end
        
    else %baseline ou post stim
        
        if ispike > 1
            if spikedata.PA_TOTAL.peak.time(ispike) - spikedata.PA_TOTAL.peak.time(ispike-1) < 0.1
                continue
            end
        end
        if ispike < size(spikedata.PA_TOTAL.time, 2)
            if spikedata.PA_TOTAL.peak.time(ispike+1) - spikedata.PA_TOTAL.peak.time(ispike) < 0.1
                continue
            end
        end
        
        if spikedata.PA_TOTAL.thresh.value(ispike) < -65 && irat ~=9
            continue
        end
        
        if t_peak < 0
            period(end+1) = "baseline";
        elseif t_peak > 600
            period(end+1) = "post";
        end
    end
    x = data{ispike}.time - t_peak;
    y = data{ispike}.waveform;
    
    p = plot(x, y, 'color', color.(period(end)));
    p.Color(4) = 0.2;
    
    datatemp.time{end+1} = x;
    datatemp.trial{end+1} = y;
    
end

set(gca, 'tickdir', 'out', 'fontsize', 15);
title(config{irat}.prefix(1:end-1), 'interpreter', 'none');
xlim([-0.03 0.03]);
fig_name = fullfile(config{irat}.imagesavedir, 'spikemorpho', sprintf('%sPA_morpho_periods_raw_figure_zoom', config{irat}.prefix));
print(fig, '-dpng',[fig_name, '.png'],'-r600');
close all


%plot avg +/- std
datatemp.label = {'spikes'};

fig = figure; hold on;

for iperiod = ["baseline","stim_induced", "post"]
    if any(period == iperiod)
        cfgtemp = [];
        cfgtemp.trials = period == iperiod;
        spikeavg.(iperiod){irat} = ft_timelockanalysis(cfgtemp, datatemp);
        patch_std(spikeavg.(iperiod){irat}.time, spikeavg.(iperiod){irat}.avg, sqrt(spikeavg.(iperiod){irat}.var), color.(iperiod));
        p = plot(spikeavg.(iperiod){irat}.time, spikeavg.(iperiod){irat}.avg, 'color', color.(iperiod));
        p.ZData = ones(size(p.YData));
    else
        spikeavg.(iperiod){irat}.time = datatemp.time{1};
        spikeavg.(iperiod){irat}.avg  = nan(size(datatemp.time{1}));
        spikeavg.(iperiod){irat}.var  = nan(size(datatemp.time{1}));
    end
end

set(gca, 'tickdir', 'out', 'fontsize', 15);
set(gcf, 'renderer', 'painters');
title(config{irat}.prefix(1:end-1), 'interpreter', 'none');
fig_name = fullfile(config{irat}.imagesavedir, 'spikemorpho', sprintf('%sPA_morpho_periods_mean_figure_zoom', config{irat}.prefix));
xlim([-0.03 0.03]);
print(fig, '-dpng',[fig_name, '.png'],'-r600');
print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
close all


%plot avg +/- std une figure par période et qqs exemples bruts
datatemp.label = {'spikes'};


%une figure par période avec mean+std, et une sélection aléatoire de 1 PAs
for iperiod = ["baseline","stim_induced", "post"]
    fig = figure; hold on;
    if any(period == iperiod)
        
        %select 10 random spikes to plot
        trial_list = find(period == iperiod);
        if length(trial_list) > 10
            sel = randperm(length(trial_list), 10);
        else
            sel = trial_list;
        end
        
        for itrial = sel
            plot(datatemp.time{itrial}, datatemp.trial{itrial}, 'k')
        end
        
        cfgtemp = [];
        cfgtemp.trials = period == iperiod;
        spikeavg.(iperiod){irat} = ft_timelockanalysis(cfgtemp, datatemp);
        
        patch_std(spikeavg.(iperiod){irat}.time, spikeavg.(iperiod){irat}.avg, sqrt(spikeavg.(iperiod){irat}.var), color.(iperiod));
        p = plot(spikeavg.(iperiod){irat}.time, spikeavg.(iperiod){irat}.avg, 'color', color.(iperiod), 'linewidth', 1);
        p.ZData = ones(size(p.YData));
        
        
    else
        spikeavg.(iperiod){irat}.time = datatemp.time{1};
        spikeavg.(iperiod){irat}.avg  = nan(size(datatemp.time{1}));
        spikeavg.(iperiod){irat}.var  = nan(size(datatemp.time{1}));
    end
    set(gca, 'tickdir', 'out', 'fontsize', 15);
    set(gcf, 'renderer', 'painters');
    title(config{irat}.prefix(1:end-1), 'interpreter', 'none');
    fig_name = fullfile(config{irat}.imagesavedir, 'spikemorpho', sprintf('%sPA_morpho_periods_mean_figure_zoom_%s', config{irat}.prefix, iperiod));
    xlim([-0.03 0.03]);
    print(fig, '-dpng',[fig_name, '.png'],'-r600');
    print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
    close all
    
end



