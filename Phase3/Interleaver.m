%% Interleaver output
%    Generate Interleaver_DataOut_Matlab.txt & Compare the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc, clear;
close all;

% Open/create Interleaver_DataIn.txt for writing
fileID = fopen('Interleaver_DataIn.txt','w');

% Generate 96 random numbers (0 or 1)
DataIn = randi([0,1],288*2,1);                       

% Write input data to text file
fprintf(fileID, '%d\r\n', DataIn);                 

% Check whether the file is generated successfully
if fileID > 0                                      
     disp('File Interleaver_DataIn.txt generated successfully !');
else
    disp('File Interleaver_DataIn.txt NOT generated successfully !');
end

% Close all files
fclose('all');       

%%

fileID = fopen('Interleaver_DataIn.txt', 'r');
DataIn = fscanf(fileID, '%d');

fclose('all');

%% Calculate the output data

Ncbps = 288;
DataOut = wlanBCCInterleave(DataIn,'Non-HT',Ncbps);

%% Write the output file

% Open Interleaver_DataOut_Matlab.txt for writing
fileID = fopen('Interleaver_DataOut_Matlab.txt','w'); 

fprintf(fileID, '%d\r\n', DataOut);       

% Check whether the file is generated successfully
if fileID > 0                                         
    disp('File Interleaver_DataOut_Matlab.txt generated successfully !');
else
    disp('File Interleaver_DataOut_Matlab.txt NOT generated successfully !');
end

% Close all files
fclose('all');   

%% Compare HDL and Matlab

fileID = fopen('Interleaver_DataOut_Matlab.txt', 'r');  % Generated by Matlab
dataMatlab = fscanf(fileID, '%d');
fileID2 = fopen('Interleaver_DataOut_HDL.txt', 'r');    % Generated by HDL
dataHDL = fscanf(fileID2, '%d');
fclose('all');

if(isequal(dataMatlab, dataHDL))
   disp('Interleaver output data for Matlab and HDL are equal!'); 
else 
   disp('Interleaver output data for Matlab and HDL are NOT equal!');
end