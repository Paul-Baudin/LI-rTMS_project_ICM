% Set parameters
addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
addpath \\lexport\iss01.charpier\analyses\tms\scripts;

ft_defaults

%load config
%config = tms_setparams_verification_artifacts;
config = tms_setparams;
%config = tms_setparams_CP;
% config = tms_setparams_i10Hz
%config = tms_setparams_QX;


%load precomputed data
ft_progress('init','text');
for irat = 1:size(config,2)
    if isempty(config{irat})
        continue
    end
    
    ft_progress(irat/size(config,2), 'load precomputed data for rat %d from %d', irat, size(config,2)); 
    temp = load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'vm_over_time.mat']), 'vm_over_time');
    vm_over_time{irat} = temp.vm_over_time;
    temp = load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spikefreq_over_time.mat']), 'spike_overtime');
    spike_overtime{irat} = temp.spike_overtime;
    clear temp
end
ft_progress('close');
    
% select rats
for irat = [7 8 10 12 13 14 15 16 17 18 19 20 21]
    if isempty(config{irat})
        tokeep(irat) = false;
        continue
    end
    tokeep(irat) = true;
end

vm_over_time_cleaned = vm_over_time(tokeep);
config_cleaned       = config(tokeep);

for iparam = ["mean_diff"] % "mean",, "mean_relative",  "std_relative","std","std_diff" 

    [fig] = tms_vm_spike_overtime_grandaverage_plot(config_cleaned, vm_over_time_cleaned, iparam);
    
    %legend([p{:}], leg{:},'Interpreter','none');
   
%     xlim([-600 3200]);
%     xticks([-600 : 600 : 3200]);
    xlim([-300 600]);
    xticks([-600 : 0 : 600]);
    xticklabels(xticks/60);
    %ylim([-5 5]);
    title(sprintf('%s', iparam),'Interpreter','none');
    xlabel('Time from begining of stim (s)');
    set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
    
   
    %print image to file
    %save figure
    set(fig,'PaperOrientation','landscape');%portrait
    set(fig,'PaperUnits','normalized');
    set(fig,'PaperPosition', [0 0 1 1]);
    set(fig, 'renderer', 'painters');
    fig_name = fullfile(config{irat}.imagesavedir,'vm_over_time_grandaverage', sprintf('allrats-%s_stim_RAW',iparam));
    print(fig, '-dpng',[fig_name, '.png'],'-r600');
    print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
    save = fullfile(config{irat}.imagesavedir,'vm_over_time_grandaverage', sprintf('allrats-%s_stim',iparam));

    %close all;
    
end %iparam 



%% spike vmax, amplitude, freq, threshold over time

%select rats
for irat = 1:size(config, 2)
    if isempty(config{irat})
        tokeep(irat) = false;
        continue
    end
	if ~ismember(irat, config{irat}.rat_list_spikefreq)
		tokeep(irat) = true;
		continue
	end
    tokeep(irat) = true;

end

spike_overtime_cleaned = spike_overtime(tokeep);
config_cleaned = config(tokeep);

for iparam = ["freq"] %"vmax_diff", "amplitude_diff", ""freq, , "freq_diff"
    for channame = [ "PA_TOTAL"] %, "PA_INDUITS""PA_SPONT",

    [fig] = tms_vm_spike_overtime_grandaverage_plot(config_cleaned, spike_overtime_cleaned, iparam, channame);
    
    axis tight
    %xlim([-300 600]);
    xlim([-600 3200]);
    %ylim([-4 8]);
    title(sprintf('%s : chan %s', iparam, channame),'Interpreter','none');
    %ylabel('normalized');
    xlabel('Time from begining of stim (s)');
    set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
    
    %print image to file
    %save figure
    set(fig,'PaperOrientation','landscape');%portrait
    set(fig,'PaperUnits','normalized');
    set(fig,'PaperPosition', [0 0 1 1]);
    set(fig, 'renderer', 'painters');
    fig_name = fullfile(config{irat}.imagesavedir,'spike_over_time_grandaverage', sprintf('%s_chan%s_-300_600', iparam, channame));
    print(fig, '-dpng',[fig_name, '.png'],'-r600');
    print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
    save = fullfile(config{irat}.imagesavedir,'spike_over_time_grandaverage', sprintf('%s_chan%s_-300_600', iparam, channame));
    close all
    
    end %channame
    
end %iparam