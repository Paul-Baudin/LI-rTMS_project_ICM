function [fig, stats, p, leg] = QX_summary_over_time(config,data_input,fieldname,channame)

%to smooth average and/or raw data
t_smooth = 60;
smooth_sample   = round(t_smooth / diff(data_input{1}.starttime(1:2)));

clear leg data t0*
fig = figure; hold on

%plot raw data
for irat = 1:size(data_input,2)
       
    if nargin == 4
        data_input{irat}.(fieldname) = data_input{irat}.(channame).(fieldname);
    end
        
    data_input{irat}.(fieldname) = fillmissing(data_input{irat}.(fieldname),'linear');

    p{irat} = plot(data_input{irat}.endtime_orig, movmean(data_input{irat}.(fieldname), [smooth_sample 0], 'omitnan'), 'color', [0.6 0.6 0.6]);
    p{irat}.Color(4) = 1; %set transparency
    leg{irat} = config{irat}.prefix(1:end-1);

    data.label{1}      = 'Vm';
    t0_idx             = nearest(data_input{irat}.endtime_orig,0);
    t0_diff(irat)      = data_input{irat}.endtime_orig(t0_idx); %0; 
    data.time{irat}    = data_input{irat}.endtime_orig - t0_diff(irat);
    
    data.trial{irat}   = data_input{irat}.(fieldname);
    
    if all(isnan(data_input{irat}.(fieldname)))
        warning('rat %d (%d) : only nans',irat, irat);
    end
end

%compute average and variance
cfgtemp             = [];
data_rat_avg        = ft_timelockanalysis(cfgtemp,data);

%compte smooth avg and std
avg_smoothed    = movmean(data_rat_avg.avg, [smooth_sample 0], 'omitnan');
std_data        = sqrt(data_rat_avg.var);
std_smoothed    = movmean(std_data, [smooth_sample 0], 'omitnan');

%find normalized-baseline
if contains(fieldname,'diff')
    baseline = 0;
elseif contains(fieldname,'relative')
    baseline = 100;
else
    baseline = nan;
end

%plot stim patch

axis tight
ax = axis;
% x = [0 600 600 0];%600 because the stimulation is always 10 minuts
% y = [ax(3) ax(3) ax(4) ax(4)];
% p2 = patch('XData',x,'YData',y,'facecolor',[0 0 0],'edgecolor','none','facealpha',0.1);
% p2.ZData = [-1 -1 -1 -1];%move patch to background

%plot std
x = data_rat_avg.time;
y = [avg_smoothed - std_smoothed; std_smoothed; std_smoothed]';
filled_SD = area(x,y);
filled_SD(1).FaceAlpha = 0; filled_SD(2).FaceAlpha = 0.4; filled_SD(3).FaceAlpha = 0.4;
filled_SD(1).EdgeColor = 'none'; filled_SD(2).EdgeColor = 'none'; filled_SD(3).EdgeColor = 'none';
filled_SD(2).FaceColor = 'b'; filled_SD(3).FaceColor = 'b';
filled_SD(1).ShowBaseLine = 'off';

ylim([ax(3) ax(4)]);

%plot smoothed average
plot(data_rat_avg.time,avg_smoothed, 'b', 'LineWidth', 2);

plot([ax(1) ax(2)], [baseline baseline], '--k');


end