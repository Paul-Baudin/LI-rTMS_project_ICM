% Set parameters
addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
addpath \\lexport\iss01.charpier\analyses\tms\scripts;
% addpath \\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML;
% addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;

ft_defaults

config = tms_setparams_QX;


%load precomputed data
ft_progress('init','text');
for irat = 1:size(config,2)
    if isempty(config{irat})
        continue
    end
    
    ft_progress(irat/size(config,2), 'load precomputed data for rat %d from %d', irat, size(config,2)); 
    temp = load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spikefreq_over_time.mat']), 'spike_overtime');
    spike_overtime{irat} = temp.spike_overtime;
    clear temp
end

ft_progress('close');

for irat = 1:size(config,2)
    if isempty(config{irat})
        tokeep(irat) = false;
        continue
    end
    tokeep(irat) = true;
end

spike_overtime_cleaned = spike_overtime(tokeep);
config_cleaned = config(tokeep);

for iparam = ["vmax_diff", "amplitude_diff"] %"freq", "freq_diff"
    for channame = ["PA_TOTAL", "PA_STIM"]

    [fig] = QX_spike_overtime_grandaverage_plot(config_cleaned, spike_overtime_cleaned, iparam, channame);
    
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
%     fig_name = fullfile(config{irat}.imagesavedir, 'spike_over_time_grandaverage', sprintf('allrats-%s_stim',iparam));
%     print(fig, '-dpng',[fig_name, '.png'],'-r600');
%     print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
%     savefig(fig,[fig_name, '.fig']);
    fig_name = fullfile(config{irat}.imagesavedir,'spike_over_time_grandaverage', sprintf('allrats-%s_stim',iparam));
    print(fig, '-dpng',[fig_name, '.png'],'-r600');
    print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
    save = fullfile(config{irat}.imagesavedir,'spike_over_time_grandaverage', sprintf('allrats-%s_stim',iparam));
    
    end %channame
    
end %iparam

    

