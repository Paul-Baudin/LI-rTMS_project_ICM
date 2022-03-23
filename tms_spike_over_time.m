%spike_morpho    :  structure with morphologies of each spike, for each spike
%                   channel indicated in config{irat}.spike_overtime.spikechannels
%spike_over_time :  average for each window of those values + mean frequency

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
%config = tms_setparams_verification_artifacts;
config = tms_setparams;
%config = tms_setparams_CP;
%config = tms_setparams_i10Hz
%config = tms_setparams_QX;

do_compute_morpho = false;

%output for images
if ~isfolder(fullfile(config{2}.imagesavedir, 'spike_over_time'))
	fprintf('Creating directory %s\n', fullfile(config{2}.imagesavedir, 'spike_over_time'));
	mkdir(fullfile(config{2}.imagesavedir, 'spike_over_time'));
end


for irat = 1:size(config,2) 

	if isempty(config{irat})
		continue
	end
		
    if ~any(strcmp(config{irat}.name, 'spikefreq_over_time'))
        continue
    end
	
	clear spike_morpho spike_overtime
    
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
    if do_compute_morpho
        for spikechan_name = string(config{irat}.spike_overtime.spikechannels)
            ft_progress('init','text',sprintf('Rat %d, %s : go trough each spike', irat, spikechan_name));
            for i_PA = 1:size(t_PA.(spikechan_name), 2)
                ft_progress(i_PA/size(t_PA.(spikechan_name), 2), 'Spike %d from %d', i_PA, size(t_PA.(spikechan_name), 2));
                
                %store PA timing
                spike_morpho.(spikechan_name).time_orig(i_PA)       = t_PA.(spikechan_name)(i_PA);
                spike_morpho.(spikechan_name).time(i_PA)            = t_PA.(spikechan_name)(i_PA) - t_stim_start;
                
                %find PA idx
                PA_idx          = round((t_PA.(spikechan_name)(i_PA) - data.Vm.time{1}(1)) * data.Vm.fsample);
                PA_start  = PA_idx + round(config{irat}.spike_overtime.morpho_toi(1)/1000*data.Vm.fsample);
                PA_end  = PA_idx + round(config{irat}.spike_overtime.morpho_toi(2)/1000*data.Vm.fsample);
                
                %interpolate PA
                t_indx = PA_start:PA_end;
                t_sel = data.Vm.time{1}(t_indx);
                data_sel = data.Vm.trial{1}(t_indx);
                data_sel_derivative = data.Vm_derivative.trial{1}(t_indx);
                t_interp = linspace(t_sel(1),t_sel(end),1000);
                if(any(isnan(data_sel)))
                    data_interp = nan(size(t_interp));
                    data_interp_derivative = nan(size(t_interp));
                else
                    data_interp = pchip(t_sel,data_sel,t_interp);
                    data_interp_derivative = pchip(t_sel,data_sel_derivative,t_interp);
                end
                
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
            end
            ft_progress('close');
        end
        fprintf('write spike morpho data to %s\n', fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spike_morpho.mat']));
        save(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spike_morpho.mat']), 'spike_morpho', '-v7.3');
    end
	
    %% compute stats on slding time window
    nb_windows_pre = floor(t_stim_start/config{irat}.spike_overtime.window.size);
    twin_start = t_stim_start - nb_windows_pre * config{irat}.spike_overtime.window.size; 
    twin_end   = twin_start + config{irat}.spike_overtime.window.size;
    
    i_window   = 0;
    nb_windows = round(data.Vm.time{1}(end)/config{irat}.spike_overtime.window.step)-1;
    
    ft_progress('init','text',sprintf('Rat %d : Go trough each window',irat));
    
    %go trough each window
    while twin_end < data.Vm.time{1}(end)
        
        keep_window = true; %will become false if the window cross puff or pulse
        i_window   = i_window+1;
        ft_progress(i_window/nb_windows, 'Window %d from %d', i_window, nb_windows);
        
        %store time relative to t_stim
        spike_overtime.starttime_orig(i_window) = twin_start;
        spike_overtime.endtime_orig(i_window)   = twin_end;
        spike_overtime.starttime(i_window)      = twin_start - t_stim_start;
        spike_overtime.endtime(i_window)        = twin_end - t_stim_start;
        
        %find window samples
        startsample.Vm = round(twin_start*data.Vm.fsample) + 1;
        endsample.Vm   = round(twin_end*data.Vm.fsample) + 1;
        startsample.Im = round(twin_start*data.Im.fsample) + 1;
        endsample.Im   = round(twin_end*data.Im.fsample) + 1;
        
%         %remove pulses
        if istrue(config{irat}.spike_overtime.ignore_pulses)
            % ignorer la fenetre si mean(abs(canal I)) est supérieur à 0.01 
            max_im            = max(abs(data.Im.trial{1}(startsample.Im:endsample.Im)));
            if max_im > config{irat}.im_threshold
                keep_window   = false;
            end
        end
        
        % remove puffs
        % ignorer la fenetre si trigger puff -> trigger puff + 1s est présent dans la fenetre
        if istrue(config{irat}.spike_overtime.ignore_puffs)
            haspulse_before  = any(abs(t_puffs - twin_start) < 1);
            haspulse_after   = any(abs(t_puffs - twin_end) < 1);
            haspulse_inside  = any(abs(t_puffs>twin_start & t_puffs < twin_end));
            haspulse         = haspulse_before || haspulse_after || haspulse_inside;
            if haspulse
                keep_window = false;
            end
        end
        
        %compute values averaged for each window
        for spikechan_name = string(config{irat}.spike_overtime.spikechannels)
            if keep_window
                spikes_selected = t_PA.(spikechan_name) > twin_start & t_PA.(spikechan_name)<twin_end;
                spike_overtime.(spikechan_name).freq(i_window)           = sum(spikes_selected)/config{irat}.spike_overtime.window.size;
                if do_compute_morpho
                    spike_overtime.(spikechan_name).amplitude(i_window)      = nanmean(spike_morpho.(spikechan_name).amplitude(spikes_selected));
                    spike_overtime.(spikechan_name).vmax(i_window)           = nanmean(spike_morpho.(spikechan_name).peak.value(spikes_selected));
                    spike_overtime.(spikechan_name).threshold(i_window)      = nanmean(spike_morpho.(spikechan_name).thresh.value(spikes_selected));
                end
            else
                spike_overtime.(spikechan_name).freq(i_window) = NaN;
                spike_overtime.(spikechan_name).amplitude(i_window) = NaN;
                spike_overtime.(spikechan_name).vmax(i_window) = NaN;
                spike_overtime.(spikechan_name).threshold(i_window) = NaN;
            end
        end
        
        %go to the next window
        twin_start = twin_start + config{irat}.spike_overtime.window.step;
        twin_end   = twin_end   + config{irat}.spike_overtime.window.step;
    end %while
    
    ft_progress('close');
    
    %compute baseline and normalize
    for spikechan_name = string(config{irat}.spike_overtime.spikechannels)
        
        %compute baseline and normalize
        %prestim : baselinewindow relative to the begining of the stim
        %begin : baselinewindow relative to the begining of the file
        switch config{irat}.spike_overtime.baseline
            case 'prestim'
                baseline_idx = spike_overtime.endtime > config{irat}.spike_overtime.baselinewindow(1) & spike_overtime.endtime < config{irat}.spike_overtime.baselinewindow(2);
            case 'begin'
                baseline_idx = spike_overtime.endtime_orig > config{irat}.spike_overtime.baselinewindow(1) & spike_overtime.endtime_orig < config{irat}.spike_overtime.baselinewindow(2);
        end
              
        spike_overtime.(spikechan_name).freq_baseline        = nanmean(spike_overtime.(spikechan_name).freq(baseline_idx));
        spike_overtime.(spikechan_name).freq_relative        = spike_overtime.(spikechan_name).freq ./ spike_overtime.(spikechan_name).freq_baseline .* 100;
        spike_overtime.(spikechan_name).freq_diff            = spike_overtime.(spikechan_name).freq - spike_overtime.(spikechan_name).freq_baseline;
        spike_overtime.(spikechan_name).amplitude_baseline   = nanmean(spike_overtime.(spikechan_name).amplitude(baseline_idx));
        spike_overtime.(spikechan_name).amplitude_relative   = spike_overtime.(spikechan_name).amplitude ./ spike_overtime.(spikechan_name).amplitude_baseline .* 100;
        spike_overtime.(spikechan_name).amplitude_diff       = spike_overtime.(spikechan_name).amplitude - spike_overtime.(spikechan_name).amplitude_baseline;
        spike_overtime.(spikechan_name).threshold_baseline   = nanmean(spike_overtime.(spikechan_name).threshold(baseline_idx));
        spike_overtime.(spikechan_name).threshold_relative   = spike_overtime.(spikechan_name).threshold ./ spike_overtime.(spikechan_name).threshold_baseline .* 100 *-1 + 200;
        spike_overtime.(spikechan_name).threshold_diff       = spike_overtime.(spikechan_name).threshold - spike_overtime.(spikechan_name).threshold_baseline;
        spike_overtime.(spikechan_name).vmax_baseline        = nanmean(spike_overtime.(spikechan_name).vmax(baseline_idx));
        spike_overtime.(spikechan_name).vmax_relative        = spike_overtime.(spikechan_name).vmax ./ spike_overtime.(spikechan_name).vmax_baseline .* 100;
        spike_overtime.(spikechan_name).vmax_diff            = spike_overtime.(spikechan_name).vmax - spike_overtime.(spikechan_name).vmax_baseline;
    end

    %keep stim timings
    spike_overtime.t_stim_orig = [t_stim_start t_stim_end];
    spike_overtime.t_stim      = [0 t_stim_end - t_stim_start];
    spike_overtime.stim_artefacts      = data.markers.markers.(config{irat}.stim_marker).synctime - t_stim_start;
    spike_overtime.stim_artefacts_orig = data.markers.markers.(config{irat}.stim_marker).synctime;
    
    %re-order fields to be better readable
    spike_overtime = orderfields(spike_overtime);
    for spikechan_name = string(config{irat}.spike_overtime.spikechannels)
        spike_overtime.(spikechan_name) = orderfields(spike_overtime.(spikechan_name));
    end
    
    %save data to disk
    fprintf('save spike stats over time to : %s\n', fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spikefreq_over_time.mat']));
    save(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spikefreq_over_time.mat']), 'spike_overtime', '-v7.3');
    

%% plot for each rat
%each data point is the end of the window

    fprintf('plot spike freq over time for %s\n', config{irat}.prefix(1:end-1));
    
    C = linspecer(size(config{irat}.spike_overtime.spikechannels,2));
    
    for iparam = ["freq"]% , "vmax", "threshold", "amplitude", "vmax", "amplitude"
        fprintf('%s : plot %s\n', config{irat}.prefix(1:end-1), iparam)
        clear leg
        fig=figure('visible','on');
        ichan = 0;
        for spikechan_name = string(config{irat}.spike_overtime.spikechannels)
            ichan = ichan+1;

            %raw param
            subplot(3,1,1);hold on
            leg{ichan} = scatter(spike_overtime.endtime,spike_overtime.(spikechan_name).(iparam),'.','MarkerEdgeColor',C(ichan,:),'MarkerEdgeAlpha',0.8);
            axis tight
            ax = axis;
            baselinename = sprintf('%s_baseline',iparam);
            
            title(sprintf('%s : raw %s', config{irat}.prefix(1:end-1), iparam),'Interpreter','none');
            set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
            xticks([]);
            ax = axis;

            %plot stim :
            if strcmp(config{irat}.plotstim, 'patch')
                x = [spike_overtime.t_stim(1) spike_overtime.t_stim(2) spike_overtime.t_stim(2) spike_overtime.t_stim(1)];%600 because the stimulation is always 10 minuts
                y = [ax(3) ax(3) ax(4) ax(4)];
                p = patch('XData',x,'YData',y,'facecolor',[0 0 0],'edgecolor','none','facealpha',0.1);
                p.ZData = [-1 -1 -1 -1];%move patch to background
            elseif strcmp(config{irat}.plotstim, 'lines')
                for istim = 1:size(spike_overtime.stim_artefacts,2)
                    p = plot([spike_overtime.stim_artefacts(istim) spike_overtime.stim_artefacts(istim)], [ax(3) ax(4)], 'color',[0.8 0.8 0.8]);
                    p.Color(4) = 0.1;%set line as transparent
                    p.ZData = [-1 -1];%move line to background
                end
            end
                
            %relative param
            subplot(3,1,2);hold on
            param_rel = sprintf('%s_relative',iparam);
            scatter(spike_overtime.endtime,spike_overtime.(spikechan_name).(param_rel),'.','MarkerEdgeColor',C(ichan,:),'MarkerEdgeAlpha',0.8);
            axis tight
            ax = axis;
            plot([ax(1) ax(2)], [100 100], '--k');
            
            title(sprintf('%s : relative %s', config{irat}.prefix(1:end-1), iparam),'Interpreter','none');
            ylabel('% of baseline');
            set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
            xticks([]);
            ax = axis;
            %plot stim :
            if strcmp(config{irat}.plotstim, 'patch')
                x = [spike_overtime.t_stim(1) spike_overtime.t_stim(2) spike_overtime.t_stim(2) spike_overtime.t_stim(1)];%600 because the stimulation is always 10 minuts
                y = [ax(3) ax(3) ax(4) ax(4)];
                p = patch('XData',x,'YData',y,'facecolor',[0.949 0.268 0.268],'edgecolor','none','facealpha',0.1);
                p.ZData = [-1 -1 -1 -1];%move patch to background
            elseif strcmp(config{irat}.plotstim, 'lines')
                for istim = 1:size(spike_overtime.stim_artefacts,2)
                    p = plot([spike_overtime.stim_artefacts(istim) spike_overtime.stim_artefacts(istim)], [ax(3) ax(4)], 'color',[0.949 0.268 0.268]);
                    p.Color(4) = 0.1;%set line as transparent
                    p.ZData = [-1 -1];%move line to background
                end
            end
            
            %diff param
            subplot(3,1,3);hold on
            param_diff = sprintf('%s_diff',iparam);
            scatter(spike_overtime.endtime,spike_overtime.(spikechan_name).(param_diff),'.','MarkerEdgeColor',C(ichan,:),'MarkerEdgeAlpha',0.8);
            axis tight
            ax = axis;
            plot([ax(1) ax(2)], [0 0], '--k');
            
            title(sprintf('%s : diff %s', config{irat}.prefix(1:end-1),iparam),'Interpreter','none');
            ylabel(sprintf('difference \nfrom baseline'));
            set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
            xlabel('Time from stim begin (s)');
            ax = axis;
            %plot stim :
            if strcmp(config{irat}.plotstim, 'patch')
                x = [spike_overtime.t_stim(1) spike_overtime.t_stim(2) spike_overtime.t_stim(2) spike_overtime.t_stim(1)];%600 because the stimulation is always 10 minuts
                y = [ax(3) ax(3) ax(4) ax(4)];
                p = patch('XData',x,'YData',y,'facecolor',[0 0 0],'edgecolor','none','facealpha',0.1);
                p.ZData = [-1 -1 -1 -1];%move patch to background
            elseif strcmp(config{irat}.plotstim, 'lines')
                for istim = 1:size(spike_overtime.stim_artefacts,2)
                    p = plot([spike_overtime.stim_artefacts(istim) spike_overtime.stim_artefacts(istim)], [ax(3) ax(4)], 'color',[0.8 0.8 0.8]);
                    p.Color(4) = 0.1;%set line as transparent
                    p.ZData = [-1 -1];%move line to background
                end
            end
        end
        
        subplot(3,1,1);
        legend([leg{:}], config{irat}.spike_overtime.spikechannels{:},'Interpreter','none');
        
        %save figure
        set(fig,'PaperOrientation','landscape');
        set(fig,'PaperUnits','normalized');
        set(fig,'PaperPosition', [0 0 1 1]);
        set(fig, 'renderer', 'painters');
        fig_name = fullfile(config{irat}.imagesavedir, 'spike_over_time',sprintf('%sspike_%s_over_time',config{irat}.prefix,iparam));
        print(fig, '-dpng',[fig_name, '.png'],'-r600');
        print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
        close(fig);
    end %iparam

end %irat