% Set parameters
if ispc
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;
elseif isunix
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/fieldtrip;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/ced-functions;
end

ft_defaults

%load config
%config = tms_setparams_verification_artifacts;
config = tms_setparams;
%config = tms_setparams_CP;
%config = tms_setparams_i10Hz
%config = tms_setparams_QX;

%output for images
if ~isfolder(fullfile(config{2}.imagesavedir,'vm_over_time'))
	fprintf('Creating directory %s\n', fullfile(config{2}.imagesavedir,'vm_over_time'));
	mkdir(fullfile(config{2}.imagesavedir,'vm_over_time'));
end

for irat = 1:size(config,2)
    
    if isempty(config{irat})
        continue
    end
    
    clear vm_over_time
    
    if ~any(strcmp(config{irat}.name, 'vm_over_time'))
        continue
    end
    
    %load converted data
    fprintf('reading %s\n',fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']));
    load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']),'data');
    
    %find t0
    t_stim_start = data.markers.markers.(config{irat}.stim_marker).synctime(1);%take the first stim artefact as the begining of the stim
    t_stim_end   = data.markers.markers.(config{irat}.stim_marker).synctime(end);%take the first stim artefact as the begining of the stim
           
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
        if toremove_start < 0
            toremove_start = 1;
        end
        toremove_end    = PA_idx + round(config{irat}.vm_over_time.remove_spikes.toi(2)/1000*data.Vm.fsample);
        if toremove_end > size(data.Vm.time{1},2) %au cas où la fenêtre du spike dépasse le dernier point des données
            toremove_end = size(data.Vm.time{1},2);
        end
        data.Vm_cleaned.trial{1}(toremove_start:toremove_end) = nan(size(toremove_start:toremove_end));
    end
    ft_progress('close');
    
    %remove stim artefacts of data Vm to compute mean and std
    t_stim = data.markers.markers.(config{irat}.stim_marker).synctime;
    ft_progress('init','text',sprintf('Rat %d : cleaning stim artifacts from Vm',irat));
    for i_stim_artifact = 1:size(t_stim,2)
        ft_progress(i_stim_artifact/size(t_stim,2), 'stim %d from %d', i_stim_artifact, size(t_stim,2));
        artifact_idx    = round((t_stim(i_stim_artifact) - data.Vm.time{1}(1)) * data.Vm.fsample);
        toremove_start  = artifact_idx + round(-0.01*data.Vm.fsample);
        toremove_end    = artifact_idx + round(0.01*data.Vm.fsample);
        if toremove_end > size(data.Vm.time{1},2) %au cas où la fenêtre du spike dépasse le dernier point des données
            toremove_end = size(data.Vm.time{1},2);
        end
        data.Vm_cleaned.trial{1}(toremove_start:toremove_end) = nan(size(toremove_start:toremove_end));
    end
    ft_progress('close');
    
    %sanity plot to check if AP were well removed
    fprintf('plot Vm without spikes\n');
    fig = figure('visible','off');hold on;
    plot(data.Vm.time{1},data.Vm.trial{1});
    plot(data.Vm_cleaned.time{1},data.Vm_cleaned.trial{1});
    fig_name = fullfile(config{irat}.imagesavedir,'vm_over_time',[config{irat}.prefix,'vm_cleaned_PA.png']);
    print(fig, '-dpng',fig_name,'-r600');
    close all;
    
    %aligner la fenetre sur le début de la stim : il faut un nombre entier
    %de fenetres avant la stim.
    nb_windows_pre = floor(t_stim_start/config{irat}.vm_over_time.window.size);
    twin_start = t_stim_start - nb_windows_pre * config{irat}.vm_over_time.window.size; 
    twin_end   = twin_start + config{irat}.vm_over_time.window.size;
  
    i_window   = 0;
    nb_windows = round(data.Vm.time{1}(end)/config{irat}.vm_over_time.window.step - config{irat}.vm_over_time.window.size + config{irat}.vm_over_time.window.step)+1;
    
    ft_progress('init','text',sprintf('Rat %d : Go trough each window',irat));
	
    %go trough each window
    while twin_end < data.Vm.time{1}(end)
        
        keep_window = true; %will become false if the window cross puff or pulse
        i_window   = i_window+1;
        ft_progress(i_window/nb_windows, 'Window %d from %d', i_window, nb_windows);
        
        %store time relative to t_stim
        vm_over_time.starttime_orig(i_window) = twin_start;
        vm_over_time.endtime_orig(i_window)   = twin_end;
        vm_over_time.starttime(i_window)      = twin_start - t_stim_start;
        vm_over_time.endtime(i_window)        = twin_end - t_stim_start;
        
        %find window samples
        startsample.Vm = round(twin_start*data.Vm.fsample) + 1;
        endsample.Vm   = round(twin_end*data.Vm.fsample) + 1;
        startsample.Im = round(twin_start*data.Im.fsample) + 1;
        endsample.Im   = round(twin_end*data.Im.fsample) + 1;
        
        %remove pulses
        if istrue(config{irat}.vm_over_time.ignore_pulses)
            % ignorer la fenetre si mean(abs(canal I)) est supérieur à 0.01 (seuil à tester)
            max_im            = max(abs(data.Im.trial{1}(startsample.Im:endsample.Im)));
            if max_im > config{irat}.im_threshold
                keep_window   = false;
            end
        end
        
        % remove puffs
        % ignorer la fenetre si trigger puff -> trigger puff + 1s est présent dans la fenetre
        if istrue(config{irat}.vm_over_time.ignore_puffs)
            haspulse_before  = any(abs(t_puffs - twin_start) < 1);
            haspulse_after   = any(abs(t_puffs - twin_end) < 1);
            haspulse_inside  = any(abs(t_puffs>twin_start & t_puffs < twin_end));
            haspulse         = haspulse_before || haspulse_after || haspulse_inside;
            if haspulse
                keep_window = false;
            end
        end
        
        %calculer les stats, différentes pour chaque i_analysis
        if keep_window && any(~isnan(data.Vm_cleaned.trial{1}(startsample.Vm:endsample.Vm)))
            %compute mean Vm
            vm_over_time.mean(i_window) = nanmean(data.Vm_cleaned.trial{1}(startsample.Vm:endsample.Vm));
            %compute std
            vm_over_time.std(i_window) = nanstd(data.Vm_cleaned.trial{1}(startsample.Vm:endsample.Vm));
            if vm_over_time.std(i_window)==0
                error('stop here to debug');
            end
        else
            vm_over_time.mean(i_window) = NaN;
            vm_over_time.std(i_window) = NaN;
            data.Vm_cleaned.trial{1}(startsample.Vm:endsample.Vm) = nan(size(startsample.Vm:endsample.Vm));
        end
        
        %go to the next window
        twin_start = twin_start + config{irat}.vm_over_time.window.step;
        twin_end   = twin_end   + config{irat}.vm_over_time.window.step;
    end %while
    ft_progress('close');
    
    %plot cleaned data
    fprintf('plot Vm cleaned\n');
    fig = figure('visible','off');hold on;
    plot(data.Vm.time{1},data.Vm.trial{1});
    plot(data.Vm_cleaned.time{1},data.Vm_cleaned.trial{1});
    fig_name = fullfile(config{irat}.imagesavedir, 'vm_over_time', [config{irat}.prefix,'vm_cleaned_PA_pulses_puffs.png']);
    print(fig, '-dpng',fig_name,'-r600');
    close all;

    %compute baseline and normalize
    %prestim : baselinewindow relative to the begining of the stim
    %begin : baselinewindow relative to the begining of the file
    switch config{irat}.vm_over_time.baseline
        case 'prestim'
            vm_over_time.baseline_vm    = nanmean(vm_over_time.mean(vm_over_time.endtime>config{irat}.vm_over_time.baselinewindow(1) & vm_over_time.endtime<config{irat}.vm_over_time.baselinewindow(2)));
            vm_over_time.baseline_std_vm = nanmean(vm_over_time.std(vm_over_time.endtime>config{irat}.vm_over_time.baselinewindow(1) & vm_over_time.endtime<config{irat}.vm_over_time.baselinewindow(2)));
        case 'begin'
            vm_over_time.baseline_vm    = nanmean(vm_over_time.mean(vm_over_time.endtime_orig>config{irat}.vm_over_time.baselinewindow(1) & vm_over_time.endtime_orig<config{irat}.vm_over_time.baselinewindow(2)));
            vm_over_time.baseline_std_vm = nanmean(vm_over_time.std(vm_over_time.endtime_orig>config{irat}.vm_over_time.baselinewindow(1) & vm_over_time.endtime_orig<config{irat}.vm_over_time.baselinewindow(2)));
    end
    
    vm_over_time.mean_relative  = (vm_over_time.mean./abs(vm_over_time.baseline_vm) + 2) .*100;
    vm_over_time.mean_diff      = vm_over_time.mean - vm_over_time.baseline_vm;
    vm_over_time.std_relative   = (vm_over_time.std./vm_over_time.baseline_std_vm) .*100;
    vm_over_time.std_diff       = vm_over_time.std - vm_over_time.baseline_std_vm; 
 
    %remove firsts windows if they are nans
    sel = find(isnan(vm_over_time.mean));
    if ~isempty(sel)
        if sel(1) == 1
            sel2=diff(sel);
            toremove(1) = 1;
            toremove(2) = find(sel2>1,1,'first');
            datasize = size(vm_over_time.starttime,2);
            for ifield = string(fieldnames(vm_over_time))'
                if size(vm_over_time.(ifield),2) == datasize
                    vm_over_time.(ifield)(toremove(1):toremove(2)) = [];
                end
            end
        end
    end
   
    %keep stim timings
    vm_over_time.t_stim_orig = [t_stim_start t_stim_end];
    vm_over_time.t_stim      = [0 t_stim_end - t_stim_start];
    vm_over_time.stim_artefacts      = data.markers.markers.(config{irat}.stim_marker).synctime - t_stim_start;
    vm_over_time.stim_artefacts_orig = data.markers.markers.(config{irat}.stim_marker).synctime;
    
    vm_over_time = orderfields(vm_over_time); %re-order fields to be better readable

    %save data to disk
    fprintf('save spike stats over time to : %s\n', fullfile(config{irat}.datasavedir,[config{irat}.prefix,'vm_over_time.mat']));
    save(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'vm_over_time.mat']), 'vm_over_time', '-v7.3');

 
    %% plot for each rat
    fprintf('%s : plot Vm over time\n', config{irat}.prefix(1:end-1));
    
    fig=figure('visible','on');
    
    %raw Vm
    subplot(4,1,1);hold on
    scatter(vm_over_time.endtime,vm_over_time.mean,'.k');
    axis tight
    %xlim([-600 1800]);
    ax = axis;
    plot([ax(1) ax(2)], [vm_over_time.baseline_vm vm_over_time.baseline_vm], '--k');
    
    title(sprintf('%s : raw Vm', config{irat}.prefix(1:end-1)), 'Interpreter','none');
    ylabel('mV');
    axis tight
    set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
    xticks([]);
    ax = axis;
    %xlim([-600 1800]);
    %plot stim :
    if strcmp(config{irat}.plotstim, 'patch')
        x = [vm_over_time.t_stim(1) vm_over_time.t_stim(2) vm_over_time.t_stim(2) vm_over_time.t_stim(1)];%600 because the stimulation is always 10 minuts
        y = [ax(3) ax(3) ax(4) ax(4)];
        p = patch('XData',x,'YData',y,'facecolor',[0 0 0],'edgecolor','none','facealpha',0.1);
        p.ZData = [-1 -1 -1 -1];%move patch to background
    elseif strcmp(config{irat}.plotstim, 'lines')
        for istim = 1:size(vm_over_time.stim_artefacts,2)
            p = plot([vm_over_time.stim_artefacts(istim) vm_over_time.stim_artefacts(istim)], [ax(3) ax(4)], 'color',[0.6 0.6 0.6]);
            p.Color(4) = 0.1;%set line as transparent
            p.ZData = [-1 -1];%move line to background
        end
    end

    
    %normalized Vm
    subplot(4,1,2);hold on
    scatter(vm_over_time.endtime,vm_over_time.mean_diff,'.k');
    axis tight
    ax = axis;
    %xlim([-600 1800]);
    plot([ax(1) ax(2)], [0 0], '--k');
    
    title(sprintf('%s : normalized Vm', config{irat}.prefix(1:end-1)), 'Interpreter', 'none');
    ylabel(sprintf('difference \nfrom baseline \n(mV)'));
    set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
    xticks([]);
    ax = axis;
    %xlim([-600 1800]);
    %plot stim :
    if strcmp(config{irat}.plotstim, 'patch')
        x = [vm_over_time.t_stim(1) vm_over_time.t_stim(2) vm_over_time.t_stim(2) vm_over_time.t_stim(1)];%600 because the stimulation is always 10 minuts
        y = [ax(3) ax(3) ax(4) ax(4)];
        p = patch('XData',x,'YData',y,'facecolor',[0 0 0],'edgecolor','none','facealpha',0.1);
        p.ZData = [-1 -1 -1 -1];%move patch to background
    elseif strcmp(config{irat}.plotstim, 'lines')
        for istim = 1:size(vm_over_time.stim_artefacts,2)
            p = plot([vm_over_time.stim_artefacts(istim) vm_over_time.stim_artefacts(istim)], [ax(3) ax(4)], 'color',[0.6 0.6 0.6]);
            p.Color(4) = 0.1;%set line as transparent
            p.ZData = [-1 -1];%move line to background
        end
    end

    
    %raw SD
    subplot(4,1,3);hold on
    scatter(vm_over_time.endtime,vm_over_time.std,'.k');
    axis tight
    ax = axis;
    %xlim([-600 1800]);
    plot([ax(1) ax(2)], [vm_over_time.baseline_std_vm vm_over_time.baseline_std_vm], '--k');

    title(sprintf('%s : raw SD', config{irat}.prefix(1:end-1)), 'Interpreter', 'none');
    ylabel('mV');
    axis tight
    xticks([]);
    set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
    ax = axis;
    %xlim([-600 1800]);
    %plot stim :
    if strcmp(config{irat}.plotstim, 'patch')
        x = [vm_over_time.t_stim(1) vm_over_time.t_stim(2) vm_over_time.t_stim(2) vm_over_time.t_stim(1)];%600 because the stimulation is always 10 minuts
        y = [ax(3) ax(3) ax(4) ax(4)];
        p = patch('XData',x,'YData',y,'facecolor',[0 0 0],'edgecolor','none','facealpha',0.1);
        p.ZData = [-1 -1 -1 -1];%move patch to background
   elseif strcmp(config{irat}.plotstim, 'lines')
        for istim = 1:size(vm_over_time.stim_artefacts,2)
            p = plot([vm_over_time.stim_artefacts(istim) vm_over_time.stim_artefacts(istim)], [ax(3) ax(4)], 'color',[0.6 0.6 0.6]);
            p.Color(4) = 0.1;%set line as transparent
            p.ZData = [-1 -1];%move line to background
        end
    end


    %normalized SD
    subplot(4,1,4);hold on
    scatter(vm_over_time.endtime,vm_over_time.std_relative,'.k');
    axis tight
    ax = axis;
    %xlim([-600 1800]);
    plot([ax(1) ax(2)], [100 100], '--k');

    title(sprintf('%s : normalized SD', config{irat}.prefix(1:end-1)), 'Interpreter', 'none');
    ylabel('% of baseline');
    axis tight
    xlabel('Time from stim begin (s)');
    set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
    ax = axis;
    %xlim([-600 1800]);
    %plot stim :
    if strcmp(config{irat}.plotstim, 'patch')
        x = [vm_over_time.t_stim(1) vm_over_time.t_stim(2) vm_over_time.t_stim(2) vm_over_time.t_stim(1)];%600 because the stimulation is always 10 minuts
        y = [ax(3) ax(3) ax(4) ax(4)];
        p = patch('XData',x,'YData',y,'facecolor',[0 0 0],'edgecolor','none','facealpha',0.1);
        p.ZData = [-1 -1 -1 -1];%move patch to background
    elseif strcmp(config{irat}.plotstim, 'lines')
        for istim = 1:size(vm_over_time.stim_artefacts,2)
            p = plot([vm_over_time.stim_artefacts(istim) vm_over_time.stim_artefacts(istim)], [ax(3) ax(4)], 'color',[0.6 0.6 0.6]);
            p.Color(4) = 0.1;%set line as transparent
            p.ZData = [-1 -1];%move line to background
        end
    end


    %save figure
    set(fig,'PaperOrientation','landscape');
    set(fig,'PaperUnits','normalized');
    set(fig,'PaperPosition', [0 0 1 1]);
    fig_name = fullfile(config{irat}.imagesavedir, 'vm_over_time',[config{irat}.prefix,'vm_over_time.png']);
    print(fig, '-dpng',fig_name,'-r600');
    %close all;
end