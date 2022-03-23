% function [stats, fig, p, leg] = QX_spike_overtime_grandaverage_plot(config,data_input,fieldname,channame)
function [fig, p, leg] = QX_spike_overtime_grandaverage_plot(config,data_input,fieldname,channame)


%to smooth average and/or raw data
t_smooth = 60; %30s
smooth_sample   = round(t_smooth / diff(data_input{1}.starttime(1:2)))+1;

clear leg data t0*
fig = figure; hold on

%plot raw data
for irat = 1:size(data_input,2)
       
    %select channame only if required (for spike data)
    if nargin == 4
        data_input{irat}.(fieldname) = data_input{irat}.(channame).(fieldname);
    end
        
%     %retirer les nans.je pense que c'est mieux pour les stats, et ^ça
%     %smooth la trace moyenne :
    data_input{irat}.(fieldname) = fillmissing(data_input{irat}.(fieldname),'linear');
%     if max( data_input{irat}.(fieldname) > 3)
%         error('stop here');
%     end
%     
%     
%     leg{irat} = config{irat}.prefix(1:end-1);
%     p{irat} = plot(data_input{irat}.endtime, movmean(data_input{irat}.(fieldname), [smooth_sample 0], 'omitnan'), 'color', 'k');
%     p{irat} = plot(data_input{irat}.endtime, data_input{irat}.(fieldname), 'color', [0 0 0]);
%     p{irat}.Color(4) = 1; %set transparency
%     leg{irat} = config{irat}.prefix(1:end-1);
    
%store data in a fieldtrip structure to compute average and variance
    %re synchro at zero to avoid bug (la précision temporelle sera réduite
    %environ de la taille du step de la fenetre divisé par 2)
    data.label{1}      = 'Vm';
    t0_idx             = nearest(data_input{irat}.endtime,0);
    t0_diff(irat)      = data_input{irat}.endtime(t0_idx); %0; 
    data.time{irat}    = data_input{irat}.endtime - t0_diff(irat);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %switch comment to change the smoothing
    data.trial{irat}   = data_input{irat}.(fieldname);
    %data.trial{irat}   = movmean(vm_over_time{irat}.(fieldname), [smooth_sample 0], 'omitnan');%vm_over_time{irat}.mean_diff;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if all(isnan(data_input{irat}.(fieldname)))
        warning('rat %d (%d) : only nans',irat, irat);
    end
    %if max(data.trial{irat}(data.time{irat}>600)) > 2, warning('rat %d : %s',irat, config{irat}.prefix(1:end-1)); end
end

%compute average and variance
cfgtemp             = [];
data_rat_avg        = ft_timelockanalysis(cfgtemp,data);

%compte smooth avg and std
avg_smoothed    = movmean(data_rat_avg.avg, [smooth_sample 0], 'omitnan');
std_data        = sqrt(data_rat_avg.var); %sqrt(data_rat_avg.var/(size(data.trial, 2))); 
std_smoothed    = movmean(std_data, [smooth_sample 0], 'omitnan');
%plot smoothed std

%find normalized-baseline
if contains(fieldname,'diff')
    baseline = 0;
elseif contains(fieldname,'relative')
    baseline = 100;
else
    baseline = nanmean(avg_smoothed(data_rat_avg.time<0 & data_rat_avg.time>-600));
end

% plotlim = ylim;
%plot SD
x = data_rat_avg.time;
y = [avg_smoothed - std_smoothed; std_smoothed; std_smoothed]';
filled_SD = area(x,y);
filled_SD(1).FaceAlpha = 0; filled_SD(2).FaceAlpha = 0.4; filled_SD(3).FaceAlpha = 0.4;
filled_SD(1).EdgeColor = 'none'; filled_SD(2).EdgeColor = 'none'; filled_SD(3).EdgeColor = 'none';
filled_SD(2).FaceColor = 'k'; filled_SD(3).FaceColor = 'k';
filled_SD(1).ShowBaseLine = 'off';

%ylim([ax(3) ax(4)]);

%plot smoothed average
plot(data_rat_avg.time,avg_smoothed, 'k', 'LineWidth', 2);

%plot stim patch
axis tight
ax = axis;
x = [0 600 600 0];%600 because the stimulation is always 10 minuts
y = [ax(3) ax(3) ax(4) ax(4)];
p2 = patch('XData',x,'YData',y,'facecolor','r','edgecolor','none','facealpha',0.1);
p2.ZData = [-1 -1 -1 -1];%move patch to background

%plot baseline
plot([ax(1) ax(2)], [baseline baseline], '--k');

% ylim(plotlim);
ylim([min(avg_smoothed - std_smoothed), max(avg_smoothed + std_smoothed)]);

end