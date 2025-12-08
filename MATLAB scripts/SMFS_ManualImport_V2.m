%Changes from V1: only imports data which does not reach end of block 3
%(retract) in order to save data
%% Import options / settings / parameters
%Data import options:
datop.location = 'C:\Your-path-to-the-example-data\Example_raw_data\processed_curves-2023.03.23-17.41.31'; %Folder with txt files of curves
        %Block 1: extend; Block 2: constant force; Block 3: retract; Block 4: constant force; Block 5: retract; Block 6: constant height
datop.saveas = '20230323_05-01';
datop.datapoints = [4096 1024 1024 16384 1024 1024];
datop.nCol =  [9 6 9 6 9 6];   %Number of columns for each block

% Plotting options
% Color gradient from color1 to color2 [RGB] over N, font and line sizes
plotop.color1 = [1 0.5 0];
plotop.color2 = [0 0.5 1];
plotop.axfontsize = 14;
plotop.tickfontsize = 14;
plotop.linewidth = 1;
plotop.markersize = 8;

%% Pre-import calculated parameters and pre-allocate

datop.directory = dir(datop.location);
N = length(datop.directory) - 2;    %Removes the "." and ".." from the list to get the number of txt files
plotop.color = [linspace(plotop.color1(1), plotop.color2(1), N)', linspace(plotop.color1(2), plotop.color2(2), N)', linspace(plotop.color1(3), plotop.color2(3), N)'];
measdetect.index = zeros(N,1);
measdetect.filename = strings(N,1);
measdetect.manual = zeros(N,1);

for i=1:N
    measdetect.index(i)=i;
    measdetect.filename(i) = compose('%s\\%s',datop.location,datop.directory(i+2,1).name);
end

%% Importing data
f = waitbar(0,sprintf('0 out of %d files',N),'Name','Importing data');
k = 0;
for i = 1:N
waitbar(i/N,f,sprintf('%d out of %d files',i,N));
filename = compose('%s\\%s',datop.location,datop.directory(i+2,1).name);
    fileID = fopen(filename{1},'r');
    Block = 0;
    C = 1;  %   1: comment; 0: data
    while ~feof(fileID)
        line = fgetl(fileID);
        if line ~= ""       %skips blank lines
            Iscomm = strcmp(line(1),'#');   %Line is a comment if it starts with #
            if Iscomm == 0     %If the line is not a comment
                if C == 1                           %If the previous line was a comment,
                    C = 0; 
                    Block = Block + 1;                          %start a new block
                    Structure = repmat('%f',1,datop.nCol(Block));     %   with the right # of columns
                    Data{i,Block} = zeros(0,datop.nCol(Block));       %Make a new empty data matrix for this file and block
                end
                dataline = cell2mat(textscan(line,Structure,'delimiter',' ')); %Makes a matrix with the data
                Data{i,Block} = cat(1,Data{i,Block},dataline); %Appends the data to the previous line in same block and file

            elseif C == 0                   %If the line is a comment but the last line wasn't
                C = 1;                      %Mark this line as a comment
            end
        end
    end
    fclose(fileID);
    if length(Data{i,3}) >= datop.datapoints(3)     %If the retraction block does not stop early (i.e. the specified tensile force is not reached) do not import measurement
       Data(i,:) = [];
    else
       k = k+1;
       measdetect.filtindex(k) = i;
    end
end
delete(f);
Data(all(cellfun(@isempty, Data),2),:) = [];
M = size(Data,1);
save(datop.saveas);