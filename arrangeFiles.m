function arrangeFiles
%enter numTetrodes
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
stringa=sprintf('Tetrodes');
x = inputdlg(stringa,'How many tetrodes?',1,{''},options);
numTetrodes = str2num(x{:});

    
    
for i = 1 : numTetrodes
        
    %enter  numChannels
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    stringa=sprintf('Channels?');
    x = inputdlg(stringa,'Enter space-separated channel numbers?',1,{''},options);
    numChannels = str2num(x{:}); 
    fName = sprintf('tetrode%d.txt', i);
    
    fid = fopen(fName,'w');            %# Open the file
    if fid ~= -1
        for j = numChannels
            str = sprintf('CSC%d', j);
            fprintf(fid,'%s\r\n',str);       %# Print the string
        end
        fclose(fid);%# Close the file
    end
end

    
