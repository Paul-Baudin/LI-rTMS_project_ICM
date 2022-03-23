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

config = tms_setparams_verification_artifacts;

%% read precomputed TFR
clear TFR
for irat = 1:size(config, 2)
    if isempty(config{irat})
        continue
    end
    
    load(fullfile(config{irat}.datasavedir, sprintf('%sTFR', config{irat}.prefix)), 'TFR');
    
    %fill from -50 to +650 to have data with the same length for
    %concatenation
    if TFR.time(1) > - 50
        winsize         = diff(TFR.time(1:2));
        toadd           = TFR.time(1) : -winsize : -50;
        toadd           = flip(toadd);
        toadd           = toadd(1:end-1); %remove last time otherwise it will be count 2 times
        TFR.time        = [toadd, TFR.time];
        toadd_data      = nan(size(TFR.label, 1), size(TFR.freq, 2), size(toadd, 2));
        TFR.powspctrm   = cat(3, toadd_data, TFR.powspctrm);
        clear toadd*
    end
    
    if TFR.time(end) < 650
        winsize         = diff(TFR.time(1:2));
        toadd           = TFR.time(end) : winsize : 650;
        toadd           = toadd(2:end);
        TFR.time        = [TFR.time, toadd]; 
        toadd_data      = nan(size(TFR.label, 1), size(TFR.freq, 2), size(toadd, 2));
        TFR.powspctrm   = cat(3, TFR.powspctrm, toadd_data);
        clear toadd*
    end
    
        TFR_allrats{irat} = TFR;
    
    clear TFR
end

%% plot un TFR moyen des channels VmArtRem

% select rats
for irat = 1:size(config,2)
    tokeep(irat) = true;
    if ~contains(config{irat}.prefix, 'real')
        tokeep(irat) = false;
    end
end

cfgtemp = [];
cfgtemp.keepindividual = 'yes';
TFR_all = ft_freqgrandaverage(cfgtemp, TFR_allrats{irat});

TFR_all.powspctrm = mean(TFR_all.powspctrm, 1, 'omitnan');
TFR_all.powspctrm = permute(TFR_all.powspctrm, [2 3 4 1]);
TFR_all.dimord = 'chan_freq_time';

%plot raw TFR
fig = figure;
subplot(2,1,1);
cfgtemp                 = [];
TFR_all.tokeep = ~isnan(TFR_all.powspctrm);
cfgtemp.maskparameter   = 'tokeep';
cfgtemp.maskalpha       = 0.5;
cfgtemp.zlim            = 'maxmin';
cfgtemp.ylim            = [1 50];
cfgtemp.xlim            = [0 600];
cfgtemp.figure          = gcf;
cfgtemp.interactive     = 'no';
cfgtemp.colormap        = jet;
ft_singleplotTFR(cfgtemp, TFR_all);

title('Raw');
%save plot
%close

%% plot un TFR moyen des channels VmFakeRem

% select rats
for irat = 1:size(config,2)
    tokeep(irat) = true;
    if ~contains(config{irat}.prefix, 'fake')
        tokeep(irat) = false;
    end
end

cfgtemp = [];
cfgtemp.keepindividual = 'yes';
TFR_all = ft_freqgrandaverage(cfgtemp, TFR_allrats{irat});

TFR_all.powspctrm = mean(TFR_all.powspctrm, 1, 'omitnan');
TFR_all.powspctrm = permute(TFR_all.powspctrm, [2 3 4 1]);
TFR_all.dimord = 'chan_freq_time';

%plot raw TFR
fig = figure;
subplot(2,1,1);
cfgtemp                 = [];
TFR_all.tokeep = ~isnan(TFR_all.powspctrm);
cfgtemp.maskparameter   = 'tokeep';
cfgtemp.maskalpha       = 0.5;
cfgtemp.zlim            = 'maxmin';
cfgtemp.ylim            = [1 50];
cfgtemp.xlim            = [0 600];
cfgtemp.figure          = gcf;
cfgtemp.interactive     = 'no';
cfgtemp.colormap        = jet;
ft_singleplotTFR(cfgtemp, TFR_all);