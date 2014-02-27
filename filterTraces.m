function filterTraces( tetrodes, HighPass1, LowPass1, varargin )
    %Filters the raw trace with a custom designed Butterworth IV band-pass
    %filter. 
    %
    %Adapted from Guido Meijer (Nov 2012)
    tic
    
    load('matlabData.mat');
    
    
    if nargin<2
        HighPass1 = 500; 
        LowPass1 = 5000;
        %HighPass2 = 500;
        %LowPass2 = 5000;
    end
    
    %Load in filter
     Flt{1} = [HighPass1 LowPass1];
     %Flt{2} = [HighPass2 LowPass2];
     FilterOrder = 4;
    
     
    if nargin > 5
        fs = varargin{1};
    else
        fs = 20000;
    end
    
    %FILTER #1: Set butterworths filter properties
    [B, A] = butter(FilterOrder, [(Flt{1}(1) / fs) (Flt{1}(2) / fs)]);
    %FILTER #2: Set butterworths filter properties
    %[B, A] = butter(FilterOrder, [(Flt{2}(1) / fs) (Flt{2}(2) / fs)]);
    
    
    disp('-----------------------------------------------------------')
    disp('## Starting band-pass filtering of all channels')
    disp(['Filter 1: ' num2str(HighPass1) ' - ' num2str(LowPass1) ' Hz'])
    %disp(['Filter 2: ' num2str(HighPass2) ' - ' num2str(LowPass2) ' Hz'])
    
    

    
    for k=1:length(tetrodes)
        tetrode = tetrodes(k);
        % LOAD TETRODE CHANNELS
        pol = strcat('tetrode',num2str(tetrode),'.txt');
        channels = textread(pol,'%s');
        
        for i=1:length(channels)
            file_to_cluster = channels(i);
            disp('-----------------------------------------------------------')
            string = sprintf('Filtering channel %s', file_to_cluster{1}(4:end));
            disp(string)
            sample = load (sprintf('%s',channels{i}));
            %Apply the filter once in the forward direction and once in the
            %backward direction using filtfilt so there is no phase shift
            FiltSamples1 = filtfilt(B, A, sample.Samples);
            %FiltSamples2 = filtfilt(B, A, sample.Samples);
            %Save output
            
            fileToSave = sprintf('CSC%d.mat', str2num(channels{i}(4:end)));
            save( fileToSave, 'FiltSamples1');
            %save( fileToSave, 'FiltSamples1', 'FiltSamples2'); %no necessity to -append and store the unfiltered Samples
            disp('Filtering done!')
        end
    end
    

toc
      


        

