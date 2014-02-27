function extractDataFromIntan

read_Intan_RHD2000_file %does not save anything.
% fileToSave='matlabData.mat';
% save(fileToSave,'amplifier_channels','-v7.3');
%make_CSC

choose_Upsample = 0;


for i = 1:size(amplifier_data,1)
    ch_name = amplifier_channels(i).native_channel_name;
    ch_num = str2num(ch_name(3:end));
    fname = sprintf('CSC%d.mat', ch_num);
    if choose_Upsample ==1
        [t2, v2] = upsample2x(t_amplifier, amplifier_data(i,:));
        Samples = v2;
    else
        Samples = amplifier_data(i,:);
        t2 = t_amplifier;
    end
    save(fname, 'Samples', '-v7.3');
end

if choose_Upsample ==1
    sf = 2 * frequency_parameters.amplifier_sample_rate;
else
    sf = frequency_parameters.amplifier_sample_rate;
end
n_traces = size(amplifier_data,1);
n_samples = length(Samples);

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
stringa=sprintf('Tetrodes');
x = inputdlg(stringa,'How many tetrodes?',1,{''},options);
numTetrodes = str2num(x{:});

tetrodes = 1:1:numTetrodes;

fileToSave='matlabData.mat';     %stores parameters and other useful information
Timestamps = t2*1e6;    %store timestamps in microseconds
save(fileToSave, 'Timestamps', 'n_traces', 'n_samples', 'sf', 'tetrodes','-v7.3');