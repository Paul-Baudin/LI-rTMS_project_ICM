%% QX-314: spike vmax & amplitude over time

% Set parameters
addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
addpath \\lexport\iss01.charpier\analyses\tms\scripts;
% addpath \\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML;
% addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;

ft_defaults

%load config
%config = tms_setparams;
config = tms_setparams_QX;


%load precomputed data
ft_progress('init','text');
for irat = 1:size(config,2)
    ft_progress(irat/size(config,2), 'load precomputed data for rat %d from %d', irat, size(config,2)); 
    temp = load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'spikefreq_over_time.mat']), 'spike_overtime');
    spike_overtime{irat} = temp.spike_overtime;
    clear temp
end
ft_progress('close');

%%Analysis
% select rats
for irat = 1:size(config,2)
    tokeep(irat) = true;
    if ~contains(config{irat}.prefix, 'QX')
        tokeep(irat) = false;
    end
end

spike_overtime_cleaned = spike_overtime(tokeep);
config_cleaned = config(tokeep);


for iparam = ["vmax_diff"]
    for channame = ["PA_TOTAL", "PA_STIM"] % 
        
        fig = QX_summary_over_time(config_cleaned, spike_overtime_cleaned, iparam, channame);
        xlim([90 3000]);
        title(sprintf('%s : chan %s', iparam, channame),'Interpreter','none');
        ylabel('normalized');
        xlabel('Time from begining(s)');
        set(gca,'TickDir','out','FontSize',15, 'FontWeight','bold');
        
        %print image to file
        %save figure
        set(fig,'PaperOrientation','landscape');%portrait
        set(fig,'PaperUnits','normalized');
        set(fig,'PaperPosition', [0 0 1 1]);
        fig_name = fullfile(config{irat}.imagesavedir,sprintf('allrats-%s',iparam));
%         print(fig, '-dpng',[fig_name, '.png'],'-r600');
%         print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
%          savefig(fig,[fig_name, '.fig']);
%         close all;
        
    end
    
end %iparam
