clc, clear;
close all;

fileID = fopen('ConvEncoder_DataIn.txt', 'r');  % Standard example
DataIn = fscanf(fileID, '%d');
fclose('all');
Input = [zeros(6, 1); DataIn];

trellis = poly2trellis(7,[133 171]);
% calculate encoded data
Encodedtmp = convenc(DataIn,trellis);
Encoded = Encodedtmp(1:(end - 20));
tbdepth = 96;
% calculate decoded data
decodedData = vitdec(Encoded,trellis,tbdepth,'trunc','hard');

%% write the output file

fileID = fopen('Viterbi_DataOut_Matlab.txt', 'w');
fprintf(fileID, '%d\r\n', decodedData);
fclose('all');
disp('File Viterbi_DataOut_Matlab.txt generated successfully !');

%% Compare the results

fileID = fopen('Viterbi_DataOut_HDL.txt', 'r');  % Generated by HDL
dataHDL = fscanf(fileID, '%d');
fileID = fopen('Viterbi_DataOut_Matlab.txt', 'r');  % Generated by Matlab
dataMatlab = fscanf(fileID, '%d');

if(isequal(dataMatlab(1:end-9), dataHDL(1:end-9)))
   disp('Viterbi output data for Matlab and HDL are equal!'); 
else 
   disp('Viterbi output data for Matlab and HDL are NOT equal!');
end