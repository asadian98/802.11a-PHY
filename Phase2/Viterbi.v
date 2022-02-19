`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:15:34 01/21/2021 
// Design Name: 
// Module Name:    Viterbi 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Viterbi(
		input wire clock,
		input wire reset,
		input wire enable,
		input wire [1:0] Vinput,
		output reg outputValid,
		output reg Voutput
    );

	parameter N = 96;
	
	reg [N - 1:0] preState [63:0];
	reg [7:0] stateMetric [63:0];
	
	reg [7:0] inputCounter;
	reg [3:0] encOut [63:0];
	reg [N - 1:0] decoded;
	integer i, j, min;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			inputCounter <= 'd0;
			outputValid <= 'd0;
			min = 0;
			encOut[0] <= 4'b1100;
			encOut[1] <= 4'b0011;
			encOut[2] <= 4'b1001;
			encOut[3] <= 4'b0110;
			encOut[4] <= 4'b0011;
			encOut[5] <= 4'b1100;
			encOut[6] <= 4'b0110;
			encOut[7] <= 4'b1001;
			encOut[8] <= 4'b0011;
			encOut[9] <= 4'b1100;
			encOut[10] <= 4'b0110;
			encOut[11] <= 4'b1001;
			encOut[12] <= 4'b1100;
			encOut[13] <= 4'b0011;
			encOut[14] <= 4'b1001;
			encOut[15] <= 4'b0110;
			encOut[16] <= 4'b1100;
			encOut[17] <= 4'b0011;
			encOut[18] <= 4'b1001;
			encOut[19] <= 4'b0110;
			encOut[20] <= 4'b0011;
			encOut[21] <= 4'b1100;
			encOut[22] <= 4'b0110;
			encOut[23] <= 4'b1001;
			encOut[24] <= 4'b0011;
			encOut[25] <= 4'b1100;
			encOut[26] <= 4'b0110;
			encOut[27] <= 4'b1001;
			encOut[28] <= 4'b1100;
			encOut[29] <= 4'b0011;
			encOut[30] <= 4'b1001;
			encOut[31] <= 4'b0110;
			encOut[32] <= 4'b0110;
			encOut[33] <= 4'b1001;
			encOut[34] <= 4'b0011;
			encOut[35] <= 4'b1100;
			encOut[36] <= 4'b1001;
			encOut[37] <= 4'b0110;
			encOut[38] <= 4'b1100;
			encOut[39] <= 4'b0011;
			encOut[40] <= 4'b1001;
			encOut[41] <= 4'b0110;
			encOut[42] <= 4'b1100;
			encOut[43] <= 4'b0011;
			encOut[44] <= 4'b0110;
			encOut[45] <= 4'b1001;
			encOut[46] <= 4'b0011;
			encOut[47] <= 4'b1100;
			encOut[48] <= 4'b0110;
			encOut[49] <= 4'b1001;
			encOut[50] <= 4'b0011;
			encOut[51] <= 4'b1100;
			encOut[52] <= 4'b1001;
			encOut[53] <= 4'b0110;
			encOut[54] <= 4'b1100;
			encOut[55] <= 4'b0011;
			encOut[56] <= 4'b1001;
			encOut[57] <= 4'b0110;
			encOut[58] <= 4'b1100;
			encOut[59] <= 4'b0011;
			encOut[60] <= 4'b0110;
			encOut[61] <= 4'b1001;
			encOut[62] <= 4'b0011;
			encOut[63] <= 4'b1100;
		end
		else if(enable)
		begin
			if(inputCounter < 2 * N + 2)
				inputCounter <= inputCounter + 1;
			
			if(inputCounter == 0)
			begin
				for(i = 0; i < 2; i = i + 1)
				begin
					preState[i][inputCounter] <= 1'b0;
					stateMetric[i] <= ((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])); 
				end
			end
			else if(inputCounter == 1)
			begin
				for(i = 0; i < 4; i = i + 1)
				begin
					preState[i][inputCounter] <= 1'b0;
					stateMetric[i] <= ((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])) + stateMetric[i/2]; 
				end
			end
			else if(inputCounter == 2)
			begin
				for(i = 0; i < 8; i = i + 1)
				begin
					preState[i][inputCounter] <= 1'b0;
					stateMetric[i] <= ((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])) + stateMetric[i/2]; 
				end
			end
			else if(inputCounter == 3)
			begin
				for(i = 0; i < 16; i = i + 1)
				begin
					preState[i][inputCounter] <= 1'b0;
					stateMetric[i] <= ((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])) + stateMetric[i/2]; 
				end
			end
			else if(inputCounter == 4)
			begin
				for(i = 0; i < 32; i = i + 1)
				begin
					preState[i][inputCounter] <= 1'b0;
					stateMetric[i] <= ((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])) + stateMetric[i/2]; 
				end
			end
			else if(inputCounter == 5)
			begin
				for(i = 0; i < 64; i = i + 1)
				begin
					preState[i][inputCounter] <= 1'b0;
					stateMetric[i] <= ((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])) + stateMetric[i/2]; 
				end
			end
			else if(inputCounter < N)
			begin
				for(i = 0; i < 64; i = i + 1)
				begin
					if(((encOut[i][3] ^ Vinput[1]) + (encOut[i][2] ^ Vinput[0])) + stateMetric[(i + 64)/2] <= ((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])) + stateMetric[i/2])
					begin	
						preState[i][inputCounter] <= 1'b1;
						stateMetric[i] <= ((encOut[i][3] ^ Vinput[1]) + (encOut[i][2] ^ Vinput[0])) + stateMetric[(i + 64)/2]; 
						if(((encOut[i][3] ^ Vinput[1]) + (encOut[i][2] ^ Vinput[0])) + stateMetric[(i + 64)/2] < stateMetric[min])
							min = i;
					end
					else
					begin
						preState[i][inputCounter] <= 1'b0;
						stateMetric[i] <= ((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])) + stateMetric[i/2];
						if(((encOut[i][1] ^ Vinput[1]) + (encOut[i][0] ^ Vinput[0])) + stateMetric[i/2] < stateMetric[min])
							min = i;
					end
				end
			end
			else if(inputCounter == N) // Traceback and decoding progress 
			begin
				j = min;
				i = N - 1;
				while(i >= 0)
				begin
					if((j % 2) == 0)
						decoded[i] <= 0;
					else
						decoded[i] <= 1;
						
					if(preState[j][i] == 0)
						j = j / 2;
					else
						j = (j + 64) / 2;
				
					i = i - 1;
				end
			end
			else if(inputCounter < 2 * N + 1)
			begin
				outputValid <= 1;
				Voutput <= decoded[inputCounter - N - 1];
			end
			else 
				outputValid <= 0;
		end
	end

endmodule
