
%remove artefacted periods according to triggers

% cfg.artrm.triggers %name of the trigger channel on Spike2
% cfg.artrm.toi %time to remove before and after each trigger
% cfg.artrm.replace %nan, pchip, linear
% cfg.artrm.chan 

config = tms_setparams_CP;


for irat = 1:size(config, 2)
    
    %load converted data
    fprintf('reading %s\n',fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']));
    load(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']),'data');
    data_orig = data;

    trigger_list = data.markers.markers.(config{irat}.artrm.triggers).synctime;
    
    ft_progress('init', 'text');
    for ichan = 1:size(config{irat}.artrm.chan, 2)
        
        channame = config{irat}.artrm.chan{ichan};
                
        for i_trigger = 1:size(trigger_list, 2)
            
            ft_progress(0, 'Chan %s : trigger %d from %d', channame, i_trigger, size(trigger_list, 2));
            
            t1 = trigger_list(i_trigger) + config{irat}.artrm.toi(1);
            t2 = trigger_list(i_trigger) + config{irat}.artrm.toi(2);


            %find window samples
            startsample = round(t1*data.(channame).fsample) + 1;
            endsample   = round(t2*data.(channame).fsample) + 1;
            
            %remove the identified window
            data.(channame).trial{1}(startsample:endsample) = nan;
            
        end
        
        %interpolate if needed
        switch config{irat}.artrm.replace{ichan}
            case 'nan'
                %do nothing
            case 'linear'
                data.(channame).trial{1} = fillmissing(data.(channame).trial{1}, 'linear', 'EndValues', 'none');
            case 'pchip'
                data.(channame).trial{1} = fillmissing(data.(channame).trial{1}, 'pchip', 'EndValues', 'none');
        end
        
    end
    
    %plot to check that artefacts are well removed
    for ichan = 1:size(config{irat}.artrm.chan, 2)
        channame = config{irat}.artrm.chan{ichan};
        
        fig = figure; hold on;
        plot(data_orig.(channame).time{1}, data_orig.(channame).trial{1});
        plot(data.(channame).time{1}, data.(channame).trial{1});
        x = trigger_list(randperm(size(trigger_list(1:end-10), 2),1));
        xlim([x x+0.3]);
        set(gca, 'tickdir', 'out', 'fontsize', 15);
        ylabel(channame);
        xlabel('time (s)');
        
        figname = fullfile(config{irat}.imagesavedir, 'check_artefacts_remove', sprintf('%sartefact_removed_%s', config{irat}.prefix, channame));
        if ~isfolder(fileparts(figname))
            fprintf('creating directory %s\n', fileparts(figname));
            mkdir(fileparts(figname));
        end
        print(fig, '-dpng', [figname, '.png'], '-r600');
        print(fig, '-dpdf', [figname, '.pdf'], '-r600');
        close all        
    end
        
    %save cleaned data
    fprintf('writing cleaned data to %s\n',fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']));
    save(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']),'data', '-v7.3');

end