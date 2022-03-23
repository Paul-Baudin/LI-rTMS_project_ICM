addpath \\lexport\iss01.charpier\analyses\tms\scripts;

%CHANGER LES SETPARAMS DANS CHAQUE SCRIPT EN FONCTION DU GROUPE DE NEURONES
%A ANALYSER

% convert data and save to disk
tms_ced_to_matlab;

% remove artefacts and save to disk 
% Attention, it replaces the data created by tms_ced_to_matlab
tms_remove_artefacts;

%analysis of Vm and spikes over time
tms_Vm_over_time; %compute values for each neuron
tms_spike_over_time; %compute values for each neuron
tms_vm_spike_overtime_grandaverage;
tms_pearson_baseline;
tms_spikemorpho_figure_zoom; %pour faire les PA moyen du neurone 803 selon la période, figure 4
tms_spikemorpho_grandaverage;

%TFR analysis
tms_tfr_intra;
tms_tfr_grandaverage;

%correct p-values
tms_correct_pvalue;
