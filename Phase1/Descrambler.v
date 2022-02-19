`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:45:02 01/02/2021 
// Design Name: 
// Module Name:    Descrambler 
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
module Descrambler(
	input wire clock,
	input wire Descrambler_Reset, 
	input wire [6:0] Descrambler_InitialState,
	input wire Descrambler_DataIN,
	input wire Descrambler_DataIN_VALID,
	output reg Descrambler_DataOUT,
	output reg Descrambler_DataVALID
);

	reg [6:0] state;

	always@(posedge clock)
	begin 
			if(Descrambler_Reset)
			begin
				state <= Descrambler_InitialState;
				Descrambler_DataOUT <= 1'b0;
				Descrambler_DataVALID <= 1'b0;
			end
			else if(Descrambler_DataIN_VALID)
			begin
					state <= {state[5:0], state[6] ^ state[3]};
					Descrambler_DataOUT <= Descrambler_DataIN ^ (state[6] ^ state[3]);
					Descrambler_DataVALID <= 1'b1;
			end
			else
			begin
				Descrambler_DataOUT <= 1'b0;
				Descrambler_DataVALID <= 1'b0;
			end
	end

endmodule
