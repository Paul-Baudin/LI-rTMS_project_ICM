%% Set parameters
if ispc
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
    addpath \\lexport\iss01.charpier\analyses\tms\scripts;
    addpath(genpath('\\lexport\iss01.charpier\analyses\tms\scripts\external'));
    addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;
elseif isunix
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/fieldtrip;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts;
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/external;
    addpath(genpath('/network/lustre/iss01/charpier/analyses/tms/scripts/external'));
    addpath /network/lustre/iss01/charpier/analyses/tms/scripts/ced-functions;
end

ft_defaults

config = tms_setparams;

%tous les TFR sont alignés avec t0 = le début de la stim (début stim =
%temps du premier artefact de stim)

%% read precomputed TFR
clear TFR
for irat = 7:size(config, 2)
    if isempty(config{irat})
        continue
    end

    load(fullfile(config{irat}.datasavedir, sprintf('%sTFR_smooth', config{irat}.prefix)), 'TFR');
    
    %fill from -1250 to 3250 to have data with the same length for
    %concatenation
    if TFR.time(1) > - 1300
        winsize         = diff(TFR.time(1:2));
        toadd           = TFR.time(1) : -winsize : -1300;
        toadd           = flip(toadd);
        toadd           = toadd(1:end-1); %remove last time otherwise it will be count 2 times
        TFR.time        = [toadd, TFR.time];
        toadd_data      = nan(size(TFR.label, 1), size(TFR.freq, 2), size(toadd, 2));
        TFR.powspctrm   = cat(3, toadd_data, TFR.powspctrm);
        clear toadd*
    end
    
    if TFR.time(end) < 3500
        winsize         = diff(TFR.time(1:2));
        toadd           = TFR.time(end) : winsize : 3500;
        toadd           = toadd(2:end);
        TFR.time        = [TFR.time, toadd]; 
        toadd_data      = nan(size(TFR.label, 1), size(TFR.freq, 2), size(toadd, 2));
        TFR.powspctrm   = cat(3, TFR.powspctrm, toadd_data);
        clear toadd*
    end
    
    TFR_allrats{irat} = TFR;
    
    clear TFR
end

%% plot un TFR moyen pour tous les rats

hasdata = ~cellfun(@isempty, TFR_allrats);
cfgtemp = [];
cfgtemp.keepindividual = 'yes';
cfgtemp.toilim = [-1200 3400];
TFR_all = ft_freqgrandaverage(cfgtemp, TFR_allrats{hasdata});

TFR_all.powspctrm = mean(TFR_all.powspctrm, 1, 'omitnan');
TFR_all.powspctrm = permute(TFR_all.powspctrm, [2 3 4 1]);
TFR_all.dimord    = 'chan_freq_time';

%plot raw TFR
fig = figure;
subplot(2,1,1);
cfgtemp                 = [];
TFR_all.tokeep = ~isnan(TFR_all.powspctrm);
cfgtemp.maskparameter   = 'tokeep';
cfgtemp.maskalpha       = 0.5;
cfgtemp.zlim            = 'maxmin';
cfgtemp.ylim            = [1 50];
cfgtemp.xlim            = [TFR_all.time(1) + 20, TFR_all.time(end) - 20];
cfgtemp.figure          = gcf;
cfgtemp.interactive     = 'no';
cfgtemp.colormap        = jet;
ft_singleplotTFR(cfgtemp, TFR_all);

title('Raw');

%plot stim
hold on;
y = ylim;
plot([0 0], y, 'r', 'LineWidth', 2);
plot([600 600], y, 'r', 'LineWidth', 2);

%correct baseline
cfgtemp                 = [];
cfgtemp.baseline        = [TFR_all.time(1), 0]; %all before zero
cfgtemp.baselinetype    = 'relchange'; %-mean /mean
TFR_blcorrected         = ft_freqbaseline(cfgtemp, TFR_all);

%plot TFR bl corrected
subplot(2,1,2);
cfgtemp                 = [];
cfgtemp.zlim            = [];
cfgtemp.xlim            = [TFR_blcorrected.time(1) + 20, TFR_blcorrected.time(end) - 20];
cfgtemp.figure          = gcf;
cfgtemp.interactive     = 'no';
TFR_blcorrected.tokeep  = ~isnan(TFR_blcorrected.powspctrm);
cfgtemp.maskparameter   = 'tokeep';
cfgtemp.maskalpha       = 0.5;

cfgtemp.colormap        = jet;
ft_singleplotTFR(cfgtemp, TFR_blcorrected);

title('Baseline corrected');

%plot stim
hold on;
y = ylim;
plot([0 0], y, 'r', 'LineWidth', 2);
plot([600 600], y, 'r', 'LineWidth', 2);

fname = fullfile(config{irat}.imagesavedir, 'TFR_smooth', sprintf('allrats-TFR_grandaverage'));

%save plot
if ~isfolder(fileparts(fname))
    fprintf('creating directory %s\n', fileparts(fname));
    mkdir(fileparts(fname));
end

print(fig, '-dpng',[fname, '.png'],'-r600');
close(fig);

%% rassembler les données, et séparer en différentes périodes

hasdata = ~cellfun(@isempty, TFR_allrats);

cfgtemp = [];
cfgtemp.keepindividual = 'yes';

cfgtemp.toilim = [-1200 -600];
TFR.baseline1 = ft_freqgrandaverage(cfgtemp, TFR_allrats{hasdata});

cfgtemp.toilim = [-600 0];
TFR.baseline2 = ft_freqgrandaverage(cfgtemp, TFR_allrats{hasdata});

cfgtemp.toilim = [0 600];
TFR.stim = ft_freqgrandaverage(cfgtemp, TFR_allrats{hasdata});

cfgtemp.toilim = [600 1200];
TFR.post1 = ft_freqgrandaverage(cfgtemp, TFR_allrats{hasdata});

cfgtemp.toilim = [1200 1800];
TFR.post2 = ft_freqgrandaverage(cfgtemp, TFR_allrats{hasdata});

cfgtemp.toilim = [2400 3000];
TFR.post3 = ft_freqgrandaverage(cfgtemp, TFR_allrats{hasdata});

%% average over time for each period and remove channel dimension
for ifield = string(fieldnames(TFR))'
    TFR.(ifield).powspctrm = mean(TFR.(ifield).powspctrm, 4, 'omitnan');
    TFR.(ifield).powspctrm = permute(TFR.(ifield).powspctrm, [1 3 2]);
    TFR.(ifield).dimord = 'subj_freq';
end

%% vérifier si les données sont distribuées de manière normale
for ifield = string(fieldnames(TFR))'
    %figure; hold on;
    for ifreq = 1:size(TFR.(ifield).powspctrm, 2)
        
        data = TFR.(ifield).powspctrm(:,ifreq);
        [H, pValue.(ifield)(ifreq), W] = swtest(data, 0.05);
        
    end
    %scatter(rand(size(pValue.(ifield))), pValue.(ifield), 'xk');
    %title(ifield);
end

%conclusion : la plupart des samples sont distribués de manière non
%normale, donc on va faire un test non paramétrique.

%% ANOVA

%création du modèle à tester
y    = [];
time = {};
rat  = [];
freq = [];
for ifield = string(fieldnames(TFR))'
    for ifreq = 1:size(TFR.(ifield).powspctrm, 2)
        for irat = 1:size(TFR.(ifield).powspctrm, 1)
            
            y(end+1)    = TFR.(ifield).powspctrm(irat, ifreq);
            time{end+1} = char(ifield);
            rat(end+1)  = irat;
            freq(end+1) = ifreq;
            
        end
    end
end

statstable      = table.empty;
statstable.data = y';
statstable.time = time';
statstable.rat  = rat';
statstable.freq = freq';

mdl   = fitlm(statstable,  'data ~ time + rat + freq + time:freq + time:rat + freq:rat + time:freq:rat');
stats = anova(mdl);

C = linspecer(numel(fieldnames(TFR)));
iplot = 0;
figure; hold on;
clear p leg
for ifield = string(fieldnames(TFR))'
    
    iplot = iplot+1;
    
    for ifreq = 1:size(TFR.(ifield).powspctrm, 2)
        
        datactrl = TFR.baseline2.powspctrm(:,ifreq);
        datatest = TFR.(ifield).powspctrm(:,ifreq);
        
        pval.(ifield)(ifreq) = signrank(datactrl, datatest);
        
    end
    
    [h, crit_p, adj_ci_cvrg, pval_corr.(ifield)] = fdr_bh(pval.(ifield));
    
    p{iplot} = plot(TFR.(ifield).freq, pval_corr.(ifield), 'linewidth', 2, 'color', C(iplot, :));
    
    leg{iplot} = ifield;
    
end
yline(0.05, '--r', 'linewidth', 2);
yline(0.01, '--r', 'linewidth', 2);
yline(0.001, '--r', 'linewidth', 2);
legend([p{:}], leg, 'location', 'eastoutside');
axis tight
set(gca, 'Yscale', 'log');

%% plot le fft de chaque période avec les stats : tous ensemble
C = linspecer(numel(fieldnames(TFR)));
iplot = 0;
figure; hold on;
clear p leg
for ifield = string(fieldnames(TFR))'
    
    iplot = iplot+1;
    
    %plot mean
    p{iplot} = plot(TFR.(ifield).freq, mean(TFR.(ifield).powspctrm, 1, 'omitnan'), 'color', C(iplot, :), 'linewidth', 2);
    p{iplot}.ZData = ones(size(p{iplot}.YData));
    
    %plot std
    ymean = mean(TFR.(ifield).powspctrm, 1, 'omitnan');
    %ysem = std(TFR.(ifield).powspctrm, 0, 1, 'omitnan') / sqrt(size(TFR.(ifield).powspctrm, 1));
    ystd = std(TFR.(ifield).powspctrm, 0, 1, 'omitnan');
    patch_std(TFR.(ifield).freq, ymean, ystd, C(iplot, :));
    
    %plot significant samples
    sel = pval_corr.(ifield) < 0.05;
    y = mean(TFR.(ifield).powspctrm, 1, 'omitnan');
    y(~sel) = nan;
    s = plot(TFR.(ifield).freq,y, 'k', 'linewidth', 2);
    s.ZData = ones(size(s.YData))*2;
    
    leg{iplot} = ifield;
end
legend([p{:}], leg, 'location', 'eastoutside');
set(gca, 'tickdir', 'out', 'fontsize', 15);

set(gcf, 'renderer', 'painters');

fname = fullfile(config{irat}.imagesavedir, 'TFR_stats', 'FFT_over_periods_stats_all_smooth');

if ~isfolder(fileparts(fname))
    fprintf('Creating folder %s\n', fileparts(fname));
    mkdir(fileparts(fname));
end

print(gcf, '-dpng', [fname, '.png'], '-r600');
print(gcf, '-dpdf', [fname, '.pdf'], '-r600');

close(gcf)

%% plot le fft de chaque période avec les stats : periode par periode

for ifield = string(fieldnames(TFR))'
    C = linspecer(numel(fieldnames(TFR)));
    iplot = 0;
    figure; hold on;
    clear p leg
    
    iplot = iplot+1;
    
    %plot mean
    p{iplot} = plot(TFR.(ifield).freq, mean(TFR.(ifield).powspctrm, 1, 'omitnan'), 'color', C(iplot, :), 'linewidth', 2);
    p{iplot}.ZData = ones(size(p{iplot}.YData));
    
    
    %plot std
    ymean = mean(TFR.(ifield).powspctrm, 1, 'omitnan');
    ystd = std(TFR.(ifield).powspctrm, 0, 1, 'omitnan') / sqrt(size(TFR.(ifield).powspctrm, 1));
    patch_std(TFR.(ifield).freq, ymean, ystd, C(iplot, :));
    
    %plot significant samples
    sel = pval_corr.(ifield) < 0.05;
    y = mean(TFR.(ifield).powspctrm, 1, 'omitnan');
    y(~sel) = nan;
    s = plot(TFR.(ifield).freq,y, 'k', 'linewidth', 2);
    s.ZData = ones(size(s.YData))*2;
    
    set(gca, 'tickdir', 'out', 'fontsize', 15);
    
    set(gcf, 'renderer', 'painters');
    
    fname = fullfile(config{irat}.imagesavedir, 'TFR_stats', sprintf('FFT_over_periods_stats_%s_smooth', ifield));
    
    
    if ~isfolder(fileparts(fname))
        fprintf('Creating folder %s\n', fileparts(fname));
        mkdir(fileparts(fname));
    end
    
    ylim([0 0.4]);
    title(ifield);
    
    print(gcf, '-dpng', [fname, '.png'], '-r600');
    print(gcf, '-dpdf', [fname, '.pdf'], '-r600');
    
    close(gcf)
end