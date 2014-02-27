function remArtIca(tetrodes)  % isolate and exclude the noisy bursts that occur on all the
% channels (or a significant subset of them)





% folder='/Users/Giuliano/Documents/MATLAB/matlabNLX/Ariosto';
% filename=fullfile(folder,'matlabData.mat');

load('matlabData.mat');

%debug
% ch = 1:12; 
% subset2plot = [1,2,5,6,11,12]; %ordinal number within ch: pick one or two channels per tetrode
% folder = '/Users/Giuliano/Documents/MATLAB/matlabNLX/Ariosto'; %'E:\Optetrode_Experiments\Cortex\CB98\140202_CB98\2014-02-02_14-34-54\iMatlabOutput';
% cd(folder)
%  n_ica = 10;
%

    


% for count = 1:length(ch)
%     channel = ch(count);
%     CSC_title = sprintf('CSC%d.mat', channel);
%     filename = fullfile(folder, CSC_title);
%     input = load(filename);
%     mixedsig(count,:) = input.FiltSamples1;
% end
% clear input



mixedsig=[];
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
        mixedsig(i + j,:) = sample.FiltSamples1;  % I should preallocate
    end
    j = j + i;
    ch_names = [ch_names channels];
    channels=[];
end

ch_names = ch_names(:);
ch_names = ch_names';


%% Extract ICs

% [icasig, A, W] = fastica(mixedsig,'numOfIC',n_ica,'lastEig',n_ica,'stabilization','on','g','tanh','approach','symm');
tic
[icasig, A, W] = fastica(mixedsig,'stabilization','on','g','tanh','approach','symm');
toc

%calculate sparsness of coulmns of mixing matrix A
% need to be implemented a little bit better

p = ones(size(A));
g = ginicoeff(p, abs(A));

ch = size(icasig,1);

%% ICs to reject

cmi =  (1-g) .* (median(abs(A)) / max(A(:)));

scrsz = get(0,'ScreenSize');
hg = figure('Position',[1 scrsz(4)/3 scrsz(3)/2 scrsz(4)/2]);
hold on; 

plot(cmi,'-xb');
plot([0 ch+1],[2.5 * std(cmi) + median(cmi) 2.5 * std(cmi) + median(cmi)],'-r')
xlabel('IC component');
ylabel('common mode index');
set(gca, 'xtick', 1:ch)
title(' common mode index  =  (1-ginicoeff) .* (median(abs(A)) / max(A(:))) ')
set(gca, 'ylim', [0 max(cmi)])



%% JUST PLOT SIGNAL CORRESPONDING TO EACH IC AND ASK to keep or reject SELECT ARTIFACTS...



choose = questdlg('Do you want to see ICs?', ...
            'ICs', ...
            'yes', ' no', ' no');




if strcmp(choose, 'yes')
    stringa=sprintf('ICA');
    take_ch = inputdlg(stringa,'Enter space-separated channel numbers?',1,{''});
    subset2plot = str2num(take_ch{:});
    
    figure(hg)
    exclude = zeros(1,ch);
    
    for i = 1:ch
        ica_sel = i;
        time2show = 1.66e6:5e6;
        
        M_star = zeros(size(A));
        M_star(:,ica_sel) = A(:,ica_sel);
        
        CSCs_star = M_star * icasig(:,time2show);
        
        figure('Name',['ICA ' num2str(i)], 'Position', [scrsz(3)/2 1 scrsz(3)/2 scrsz(4)])
        for j = 1:length(subset2plot)
            subplot(length(subset2plot),1,j)
            plot(CSCs_star(subset2plot(j),:))
            ylim([-200, 200])
            set(gca,'FontSize',6)
            %ylabel(['CSC* ' num2str(ch(subset2plot(j)))])
        end
        choice = questdlg('Do you want to exclude this IC?', ...
            'IC artifacts selection', ...
            'yes', ' no', ' no');
        % Handle response
        if strcmp(choice, 'yes')
            exclude(i) = 1;
            print(gcf,'-dpdf',['IC' num2str(i) '.pdf']);
            figure(hg); plot(i, cmi(i),'or');
        end
        
    end
    
else
    
    exclude = zeros(1,length(cmi));
    for i = 1:length(cmi)
        if cmi(i) >= median(cmi) + 2.5 * std(cmi)
            exclude(i) = 1;
        end
    end
end
% %% save all output
% 
% folder2 = ['ICAartifacts_' num2str(ica_sel)];
% 
% mkdir(folder2)
% cd(folder2)
% save('ICAartifacts.mat', '-v7.3')
% print(hg,'-dpdf','thresh_chosenICAs.pdf');



%% eliminate IC#,  ( maybe main artifact) and save CSCcorr 
ica_sel = find(exclude);
M_star = A;
M_star(:,ica_sel) = 0;
CSCs_star = M_star * icasig;
  
for i=1:ch
     fname = sprintf('CSC%d.mat', str2num(ch_names{i}(4:end)));    %Save data
    FiltSamples1 = CSCs_star(i,:);
    save(fname, 'FiltSamples1', '-v7.3');
end



