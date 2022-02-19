`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:40:00 01/01/2021 
// Design Name: 
// Module Name:    Scrambler 
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
module Scrambler(
	input wire clock,
	input wire Scrambler_Reset, 
	input wire [6:0] Scrambler_InitialState,
	input wire Scrambler_DataIN,
	input wire Scrambler_DataIN_VALID,
	output reg Scrambler_DataOUT,
	output reg Scrambler_DataOUTVALID
);

	reg [6:0] state;

	always@(posedge clock)
	begin 
			if(Scrambler_Reset)
			begin
				state <= Scrambler_InitialState;
				Scrambler_DataOUT <= 1'b0;
				Scrambler_DataOUTVALID <= 1'b0;
			end
			else if(Scrambler_DataIN_VALID)
			begin
					state <= {state[5:0], state[6] ^ state[3]};
					Scrambler_DataOUT <= Scrambler_DataIN ^ (state[6] ^ state[3]);
					Scrambler_DataOUTVALID <= 1'b1;	
			end
			else
			begin
				Scrambler_DataOUT <= 1'b0;
				Scrambler_DataOUTVALID <= 1'b0;
			end
	end

endmodule
