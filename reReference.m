function reReference(tetrodes)

% folder='/Users/Giuliano/Documents/MATLAB/matlabNLX/Ariosto';
% filename=fullfile(folder,'matlabData.mat');
% 
% load(filename);
load('matlabData.mat');

csc_data=zeros(n_traces, n_samples);
j = 0;
i = 0;
channels = [];
ch_names = [];

for k=1:length(tetrodes)
    tetrode = tetrodes(k);
    % LOAD TETRODE CHANNELS
    pol = strcat('tetrode',num2str(tetrode),'.txt');
    channels = textread(pol,'%s');
    
    for i=1:length(channels)
        file_to_cluster = channels(i);
        disp('-----------------------------------------------------------')
        string = sprintf('Loading channel %s', file_to_cluster{1}(4:end));
        disp(string)
        sample = load (sprintf('%s',channels{i}));
        csc_data(i + j,:) = sample.Samples;
    end
    j = j + i;
    ch_names = [ch_names channels];
    clear channels;
end

ch_names = ch_names(:);
ch_names = ch_names';


csc_mean=mean(csc_data);
for i=1:length(ch_names(:))
    disp('-----------------------------------------------------------')
    string = sprintf('Re-referencing channel %d', str2num(ch_names{i}(4:end)));
    disp(string)
    csc_data(i,:)=csc_data(i,:)-csc_mean;
    fname = sprintf('CSC%d.mat', str2num(ch_names{i}(4:end)));    %Save data
    Samples = csc_data(i,:);
    save(fname, 'Samples', '-v7.3');
end
disp('Done!')
clear csc_mean;



