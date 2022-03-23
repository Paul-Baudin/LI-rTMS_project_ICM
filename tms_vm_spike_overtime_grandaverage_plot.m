function [fig, p, leg] = tms_vm_spike_overtime_grandaverage_plot(config,data_input,fieldname,channame)

if nargin < 4 
    channame = "dummy";
end
if nargin < 5
    do_fill_missing = true;
end

%to smooth average and/or raw data
t_smooth = 0;
smooth_sample   = round(t_smooth / diff(data_input{1}.starttime(1:2)))+1;

clear leg data t0*
fig = figure; hold on

%plot raw data
for irat = 1:size(data_input,2)
       
    %select channame only if required (for spike data)
    if nargin >= 4
        data_input{irat}.(fieldname) = data_input{irat}.(channame).(fieldname);
    end
        
    if channame == "PA_INDUITS"
        data_input{irat}.(fieldname) = fillmissing(data_input{irat}.(fieldname),'linear', 'MaxGap', 3); %car pas de PA induits en dehors de la stim
    else
        data_input{irat}.(fieldname) = fillmissing(data_input{irat}.(fieldname),'linear');
    end

%     leg{irat} = config{irat}.prefix(1:end-1);
%     p{irat} = plot(data_input{irat}.endtime, movmean(data_input{irat}.(fieldname), [smooth_sample 0], 'omitnan'), 'color', 'k');%, 'linewidth',2);
%     p{irat} = plot(data_input{irat}.endtime, data_input{irat}.(fieldname), 'color', [0 0 0]);
%     p{irat}.Color(4) = 1; %set transparency
%     leg{irat} = config{irat}.prefix(1:end-1);

    data.label{1}      = 'Vm';
    data.time{irat}    = data_input{irat}.endtime;
    data.trial{irat}   = data_input{irat}.(fieldname);
        
    if all(isnan(data_input{irat}.(fieldname)))
        warning('rat %d (%d) : only nans',irat, irat);
    end
end

%realigner pour pouvoir moyenner
cfgtemp             = [];
cfgtemp.time        = repmat({-600:30:3600}, 1, size(data.trial, 2));
cfgtemp.extrapval   = nan;
cfgtemp.method      = 'linear';
data                = ft_resampledata(cfgtemp, data);

%compute average and variance
data_rat_avg        = ft_timelockanalysis([],data);

%compte smooth avg and std
avg_smoothed    = movmean(data_rat_avg.avg, [smooth_sample 0], 'omitnan');
std_data        = sqrt(data_rat_avg.var); %sqrt(data_rat_avg.var/(size(data.trial, 2))); 
std_smoothed    = movmean(std_data, [smooth_sample 0], 'omitnan');

%find normalized-baseline
if contains(fieldname,'diff')
    baseline = 0;
elseif contains(fieldname,'relative')
    baseline = 100;
else
    baseline = mean(avg_smoothed(data_rat_avg.time<0 & data_rat_avg.time>-600), 'omitnan');
end

%plot SD
x = data_rat_avg.time;
y = [avg_smoothed - std_smoothed; std_smoothed; std_smoothed]';
filled_SD = area(x,y);
filled_SD(1).FaceAlpha = 0; filled_SD(2).FaceAlpha = 0.4; filled_SD(3).FaceAlpha = 0.4;
filled_SD(1).EdgeColor = 'none'; filled_SD(2).EdgeColor = 'none'; filled_SD(3).EdgeColor = 'none';
filled_SD(2).FaceColor = 'k'; filled_SD(3).FaceColor = 'k';
filled_SD(1).ShowBaseLine = 'off';

%plot average
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