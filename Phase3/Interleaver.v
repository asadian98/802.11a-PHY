`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:05:03 01/27/2021 
// Design Name: 
// Module Name:    Interleaver 
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
module Interleaver(
	input wire clock,
	input wire reset,
	input wire inputData,
	input wire inputValid,
	input wire [1:0] mode,
	
	output reg outputData,
	output reg outputValid
    );

	
	reg [287:0] wMEM, rMEM; 
	reg [8:0] writeCounter, i, q;
	wire [8:0] NCBPS;
	reg endflag2, endflag, read, flag;
	reg [8:0] Ind [287:0];
	integer k, p;
	
	
	assign NCBPS = (mode == 2'b00) ? 48 : 
			(mode == 2'b01) ? 96 :
			(mode == 2'b01) ? 192 :
			(mode == 2'b01) ? 288 : 288;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			writeCounter <= 0;
			read <= 0;
			endflag <= 0;
		end
		else if(inputValid)
		begin
			if(writeCounter != NCBPS)
			begin
				wMEM[writeCounter] <= inputData;
				writeCounter <= writeCounter + 1;
				if(writeCounter == NCBPS - 1)
				begin
					read <= 1;
					case(NCBPS)
						'd48: rMEM <= {inputData, wMEM[46:0]};
						'd96: rMEM <= {inputData, wMEM[94:0]};
						'd192: rMEM <= {inputData, wMEM[190:0]};
						'd288: rMEM <= {inputData, wMEM[286:0]};
					endcase
					
					case(mode)
					2'b00: begin
							for(k = 0; k < 48; k = k + 1)
							begin
								Ind[k] <= 16 * k - (48 - 1)*(16 * k / 48);
							end
					end
					2'b01: begin
							for(k = 0; k < 96; k = k + 1)
							begin
								Ind[k] <= 16 * k - (96 - 1)*(16 * k / 96);
							end
					end
					2'b10: begin
							for(k = 0; k < 192; k = k + 1)
							begin
								p = 2 * (k/2) + ((k + 16 * k / 192) % 2);
								Ind[k] <= 16 * p - (192 - 1)*(16 * p / 192);
							end
					end
					2'b11: begin
							for(k = 0; k < 288; k = k + 1)
							begin
								p = 3 * (k/3) + ((k + 16 * k / 288) % 3);
								Ind[k] <= 16 * p - (288 - 1)*(16 * p / 288);
							end
					end
				endcase
				end	
			end
			else
			begin
				wMEM[0] <= inputData;
				writeCounter <= 1;
			end
		end
		else if(~inputValid && read == 1)
			endflag <= 1;
	end
	

	always@(posedge clock)
	begin
		if(reset)
		begin
			q <= 2;
			i <= 16;
			flag <= 1;
			endflag2 <= 0;
		end
		else 
		begin
			if(read)
			begin
				if(flag)
				begin
					outputData <= rMEM[0];
					outputValid <= 1;
					flag <= 0;
				end
				else if(outputValid)
				begin
					if(q != (NCBPS + 1))
					begin
						q <= q + 1;
						i <= Ind[q];
						outputData <= rMEM[i];
					end
					else
					begin
						if(endflag)
						begin
							endflag2 <= 1;
						end
						q <= 2;
						i <= 16;
						if(~endflag2)
						begin
							outputData <= rMEM[0];
							outputValid <= 1;
						end
						else
						begin
							outputData <= 0;
							outputValid <= 0;
						end
					end
				end
			end
		end
	end
	
endmodule 