function make_CSC


load('matlabData.mat')
%% save as csc

%cd('E:\Optetrode_Experiments\Ariosto\140215_171354\iMatlabOutput') %change this

choose_Upsample = 1;
a = amplifier_channels;

for i = 1:length(a)
    ch_name = amplifier_channels(i).native_channel_name;
    ch_num = str2num(ch_name(3:end));
    fname = sprintf('CSC%d.mat', ch_num);
    if choose_Upsample ==1
        [t2, v2] = upsample2x(t_amplifier, amplifier_data(i,:));
        Samples = v2;
    else
        Samples = amplifier_data(i,:);
    end
    save(fname, 'Samples', '-v7.3');
end

if choose_Upsample ==1
    sf = 2 * frequency_parameters.amplifier_sample_rate;
else
    sf = frequency_parameters.amplifier_sample_rate;
end
n_traces = length(amplifier_channels);
n_samples = length(Timestamps);

fileToSave='matlabData.mat';     %stores parameters and other useful information
Timestamps = t2*1e6;    %store timestamps in microseconds
save(fileToSave, '-append', 'Timestamps', 'n_traces', 'n_samples', 'sf','-v7.3');