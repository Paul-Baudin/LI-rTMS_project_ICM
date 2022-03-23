%Lis les données Spike2
%Attention, le fichier ne doit pas être ouvert dans Spike2

% Set parameters
addpath \\lexport\iss01.charpier\analyses\tms\scripts\fieldtrip;
addpath \\lexport\iss01.charpier\analyses\tms\scripts;
addpath \\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML;
addpath \\lexport\iss01.charpier\analyses\tms\scripts\ced-functions;

%load CED library
CEDS64LoadLib('\\lexport\iss01.charpier\analyses\tms\scripts\CEDMATLAB\CEDS64ML');
%load fieldtrip
ft_defaults

%load config
config = tms_setparams_ECoG; 

for irat = 1:size(config,2) %22 % % 
    
    if isempty(config{irat})
        continue
    end
    
    
    data.EEG_R = readCEDcontinuous(config{irat}.readCED.datapath,config{irat}.readCED.chan_EEG_R);
    %     cfgtemp             = [];
    %     cfgtemp.lpfilter    = 'yes';
    %     cfgtemp.lpfreq      = 100;
    %     data.Vm2            = ft_preprocessing(cfgtemp, data.Vm);
   
    data.EEG_L = readCEDcontinuous(config{irat}.readCED.datapath,config{irat}.readCED.chan_EEG_L); %used to exclued windows
    %filter Im to remove stim artefacts
%     cfgtemp             = [];
%     cfgtemp.lpfilter    = 'no';
%     cfgtemp.lpfreq      = config{irat}.readCED.im_lpfreq;
%     data.Im             = ft_preprocessing(cfgtemp, data.Im);
    
    %events
    data.markers = readCEDmarkers(config{irat}.readCED.datapath);
    
    fprintf('save data to %s\n',fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']));
    save(fullfile(config{irat}.datasavedir,[config{irat}.prefix,'raw.mat']), 'data', '-v7.3');
    clear data
end


