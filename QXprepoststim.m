%% QX-314: comparaison pre/during/post stimulation du Vm max

% Set parameters
addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
addpath \\lexport\iss01.charpier\analyses\tms\scripts;
addpath \\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML;
addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;

%load CED library
CEDS64LoadLib('\\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML');

ft_defaults

analysis_name = 'QX'; %'QX';

%load config
%config = tms_setparams;
config = tms_setparams_QX;

%%Analysis
% select rats
for irat = 1:size(config,2)
    tokeep(irat) = true;
    %only for TMS rats
    if ~contains(config{irat}.prefix, analysis_name)|| ismember(irat, config{irat}.has_big_offset)
        tokeep(irat) = false;
    end
end

config_cleaned = config(tokeep);

stim_count  = 0;

for channame = ["PA_TOTAL", "PA_STIM"]
    vmax.(channame)        = table;
    vmax_diff.(channame)   = table;
end

for irat = 1:size(config_cleaned,2)
       
    %load events data from Spike2
    events = readCEDmarkers(config_cleaned{irat}.readCED.datapath);
    t_stim = events.markers.(config_cleaned{irat}.stim_marker).synctime;
    
    %load spike morpho
    %computed in tms_spike_over_time.m. 
    load(fullfile(config_cleaned{irat}.datasavedir,[config_cleaned{irat}.prefix,'spike_morpho.mat']));
    
    %trouver les temps de chaque stim
    idx_big_diff   = find(diff(t_stim) >1);
    idx_debut_stim = [1, idx_big_diff+1];
    idx_fin_stim   = [idx_big_diff, size(t_stim,2)];
    t_debut_stim   = t_stim(idx_debut_stim);
    t_fin_stim     = t_stim(idx_fin_stim);
    
    for channame = ["PA_TOTAL", "PA_STIM"]
        for istim = 1:size(t_debut_stim,2)
            
            stim_count = stim_count+1;    
            vmax.(channame).rat_name{stim_count} = config_cleaned{irat}.prefix(1:end-1);
            vmax_diff.(channame).rat_name{stim_count} = config_cleaned{irat}.prefix(1:end-1);
            
            % Pre
            %prestim is of the size of the stim
            toi(1) = t_debut_stim(istim) - ((t_fin_stim(istim)) - (t_debut_stim(istim))); 
            toi(2) = t_debut_stim(istim);
            spike_idx = spike_morpho.(channame).time > toi(1) &  spike_morpho.(channame).time < toi(2); 
            vmax.(channame).prestim(stim_count)       = nanmean(spike_morpho.(channame).peak.value(spike_idx));
            vmax_diff.(channame).prestim(stim_count)  = nanmean(spike_morpho.(channame).peak.value(spike_idx)) - vmax.(channame).prestim(stim_count);
            
            % LI-rTMS
            toi(1) = t_debut_stim(istim); 
            toi(2) = t_fin_stim(istim);
            spike_idx = spike_morpho.(channame).time > toi(1) &  spike_morpho.(channame).time < toi(2); 
            vmax.(channame).stim(stim_count)       = nanmean(spike_morpho.(channame).peak.value(spike_idx));
            vmax_diff.(channame).stim(stim_count)  = nanmean(spike_morpho.(channame).peak.value(spike_idx)) - vmax.(channame).stim(stim_count);
            
            % Post
            toi(1) = t_fin_stim(istim);
            toi(2) = t_fin_stim(istim) + ((t_fin_stim(istim)) - (t_debut_stim(istim))); 
            spike_idx = spike_morpho.(channame).time > toi(1) &  spike_morpho.(channame).time < toi(2); 
            vmax.(channame).poststim(stim_count)       = nanmean(spike_morpho.(channame).peak.value(spike_idx));
            vmax_diff.(channame).poststim(stim_count)  = nanmean(spike_morpho.(channame).peak.value(spike_idx)) - vmax.(channame).poststim(stim_count);
            
        end
    end
end

save(fullfile(config_cleaned{1}.datasavedir, [analysis_name,'_vmax_prepoststim.mat']), 'vmax*');          