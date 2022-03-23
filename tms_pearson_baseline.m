% Set parameters
addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
addpath \\lexport\iss01.charpier\analyses\tms\scripts;
% addpath \\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML;
% addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;

ft_defaults

%load config
config = tms_setparams;

%create output directory for images
if ~isfolder(fullfile(config{8}.imagesavedir,'vm_over_time_pearson_corr'))
    fprintf('Creating directory %s\n', fullfile(config{8}.imagesavedir,'vm_over_time_pearson_corr'));
    mkdir(fullfile(config{8}.imagesavedir,'vm_over_time_pearson_corr'));
end

%load precomputed data
ft_progress('init','text');
for irat = 7:size(config,2)
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
    
%% vm mean et sd over time

% select rats
for irat = 1:size(config,2)
    if isempty(config{irat})
        tokeep(irat) = false;
        continue
    end
    tokeep(irat) = false;
    %only for TMS rats
    if contains(config{irat}.prefix, 'Ctrl') %|| contains(config{irat}.prefix, 'TMS')  
        tokeep(irat) = true;
    end
    if ismember(irat, config{irat}.has_big_offset) || ismember(irat, config{irat}.instable_baseline) ...
            || contains(config{irat}.prefix, '1470') 
        %1470 : trop de protocoles pendant la baseline 
        tokeep(irat) = false;
    end
end

vm_over_time_cleaned = vm_over_time(tokeep);
config_cleaned       = config(tokeep);

spike_overtime_cleaned = spike_overtime(config{10}.rat_list_spikefreq_ctrl);
config_freq       = config(config{10}.rat_list_spikefreq_ctrl);

%% Pearson correlation

for iparam = ["mean","std","freq"] 
    clear data
    if contains(iparam, "freq")
        dataovertime = spike_overtime_cleaned;
    else
        dataovertime = vm_over_time_cleaned;
    end
    for irat = 1:size(dataovertime, 2)
        if contains(iparam, "freq")
            data.time{irat}  = spike_overtime_cleaned{irat}.starttime;
            data.trial{irat} = spike_overtime_cleaned{irat}.PA_TOTAL.(iparam);
            data.trial{irat} = fillmissing(data.trial{irat},'pchip', 'endvalues', 'nearest');
%			  normalize
%             idx = find(data.trial{irat}~=0, 1, 'first');
%             data.trial{irat} = data.trial{irat} / mean(data.trial{irat}(idx:idx+30), 'omitnan'); 
        else
            data.time{irat}  = vm_over_time_cleaned{irat}.starttime;
            data.trial{irat} = vm_over_time_cleaned{irat}.(iparam);
        end
        t0_idx             = nearest(data.time{irat},0);
        t0_diff(irat)      = data.time{irat}(t0_idx); %0;
        data.time{irat}    = data.time{irat} - t0_diff(irat);
    end
    data.label = {'Vm'}; 

%     %select baseline
    data_prestim = data;
    for irat = 1:size(dataovertime, 2)
        toi = [-1000 -400];
        sel = data.time{irat} < toi(1) | data.time{irat} > toi(2);
        data_prestim.time{irat}(sel) = [];
        data_prestim.trial{irat}(sel) = [];
    end
   
    %compute correlation
    x = [];
    y = [];
    for irat = 1:size(dataovertime, 2)
        x = [x, data_prestim.time{irat}];
        y = [y, data_prestim.trial{irat}];
    end
    x(isnan(y)) = [];
    y(isnan(y)) = [];
    [rho, pval] = corr(x',y','type','pearson');
    
    %compute linear fit
    coeffs_fit = polyfit(x', y',1);
    xFit = linspace(min(x), max(x), 500);
    yFit = polyval(coeffs_fit, xFit);
    
    %plot raw data and linear fit
    fig = figure; hold on;
    clear p leg
    for irat = 1:size(data_prestim.trial, 2)
        p{irat} = plot(data_prestim.time{irat},data_prestim.trial{irat});
        if contains(iparam, "freq")
            leg{irat} = config_freq{irat}.prefix(1:end-1);
        else
            leg{irat} = config_cleaned{irat}.prefix(1:end-1);
        end
    end
    legend([p{:}], leg{:}, 'location', 'eastoutside', 'interpreter', 'none');
    plot(xFit, yFit, 'r', 'linewidth', 2);
    set(gca, 'tickdir', 'out', 'fontsize', 15);
    y = ylim;
    datarange = diff(y);
    newrange = datarange * 0.5;
    ylim([y(1) - newrange/2, y(2) + newrange/2]);
    
    set(gcf, 'renderer', 'painters');
    fig_name = fullfile(config{irat}.imagesavedir,'vm_over_time_pearson_corr',['Ctrlrats-', char(iparam), '_rawdata']);
    print(fig, '-dpng',[fig_name, '.png'],'-r600');
    print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
    close all;

    %compute and plot mean +/- std of the parameter (smoothed)
    %smooth data
    data_smoothed = data_prestim;
    for irat = 1:size(data_prestim.trial, 2)
        data_smoothed.trial{irat} = fillmissing(data_smoothed.trial{irat},'linear', 'endvalues', 'nearest');
        data_smoothed.trial{irat} = movmean(data_smoothed.trial{irat}, 1, 'omitnan');
    end
      
    dataavg = ft_timelockanalysis([], data_smoothed);
    
    fig = figure; hold on;
    x = dataavg.time;
    y = dataavg.avg;
    ystd = sqrt(dataavg.var);
    plot(x,y, 'k', 'linewidth', 2);
    patch_std(x,y,ystd,'k');
    axis tight;
    ylim([min(y-ystd) max(y+ystd)]);
    set(gca, 'tickdir', 'out', 'fontsize', 15);
    y = ylim;
    datarange = diff(y);
    newrange = datarange * 0.5;
    ylim([y(1) - newrange/2, y(2) + newrange/2]);
    xticklabels(xticks+100);
    title(sprintf('%s \nrho = %.4f, p = %.4f (Pearson corr)\nLinear fit slope = %.5f', iparam, rho, pval, coeffs_fit(1)), 'interpreter', 'none');
        
    set(gcf, 'renderer', 'painters');
    fig_name = fullfile(config{irat}.imagesavedir,'vm_over_time_pearson_corr',['Ctrlrats-', char(iparam), '_10min']);
    print(fig, '-dpng',[fig_name, '.png'],'-r600');
    print(fig, '-dpdf',[fig_name, '.pdf'],'-r600');
    close all;
    
end