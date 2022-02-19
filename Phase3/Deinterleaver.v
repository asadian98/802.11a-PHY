`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:23:24 01/28/2021 
// Design Name: 
// Module Name:    Deinterleaver 
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
module Deinterleaver(
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
										
					case(mode)
						2'b00: begin
								for(k = 0; k < 48; k = k + 1)
								begin
									Ind[k] <= 3 * (k % 16) + (k / 16);
								end
								i <= 3;
						end
						2'b01: begin
								for(k = 0; k < 96; k = k + 1)
								begin
									Ind[k] <= 6 * (k % 16) + (k / 16);
								end
								i <= 3;
						end
						2'b10: begin
								for(k = 0; k < 192; k = k + 1)
								begin
									p = 12 * (k % 16) + (k / 16);
									Ind[k] <= 2 * (p/2) + ((p + 192 - (16 * p / 192)) % 2);
								end
								i <= 13;
						end
						2'b11: begin
								for(k = 0; k < 288; k = k + 1)
								begin
									p = 18 * (k % 16) + (k / 16);
									Ind[k] <= 3 * (p/3) + ((p + 288 - (16 * p / 288)) % 3);
								end
								i <= 20;
						end
					endcase
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
						if(mode == 3)
							i <= 20;
						else if(mode == 2)
							i <= 13;
						else
							i <= 3;
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
