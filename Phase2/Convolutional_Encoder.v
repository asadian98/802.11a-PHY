`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:34:09 01/12/2021 
// Design Name: 
// Module Name:    Convolutional_Encoder 
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
module Convolutional_Encoder(
		input wire			clock,
		input wire			reset,
	
		input wire [1:0] 	mode, // mode : 0 --> r = 1/2, 1 --> r = 3/4, 2 --> r = 2/3
		input wire			data_in,
		input wire 			inputValid,
		output reg 			data_out,
		output reg 			outputValid
    );

	reg [5:0] state;
	reg [1:0] FIFO_input;
	wire [1:0] FIFO_output;
	reg FIFO_readEn;
	wire FIFO_empty;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			state <= 6'd0;
			FIFO_input <= 2'b00;
		end
		else if(inputValid)
		begin
			state <= {state[4:0], data_in};
			FIFO_input[0] <= data_in ^ state[1] ^ state[2] ^ state[4] ^ state[5];
			FIFO_input[1] <= data_in ^ state[0] ^ state[1] ^ state[2] ^ state[5];
		end

	end
	
	reg [2:0] counter;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			data_out <= 0;
			FIFO_readEn <= 0;
			counter <= 0;
			outputValid <= 0;
		end
		else if(~FIFO_empty)
		begin
		// mode : 0 --> r = 1/2, 1 --> r = 3/4, 2 --> r = 2/3
			case(mode)
				0: begin
						if(FIFO_readEn == 0)
						begin
							if(counter == 1)
								outputValid <= 1;
							FIFO_readEn <= 1;
							data_out <= FIFO_output[0];
						end
						else 
						begin
							counter <= 1;
							FIFO_readEn <= 0;
							data_out <= FIFO_output[1];
						end
				end
				1: begin
						if(counter == 0)
						begin
							FIFO_readEn <= 1;
							data_out <= FIFO_output[0];
							counter <= 1;
						end
						else if(counter == 1)
						begin
							counter <= 2;
							FIFO_readEn <= 0;
							data_out <= FIFO_output[1];
						end
						else if(counter == 2)
						begin
							counter <= 3;
							outputValid <= 1;
							FIFO_readEn <= 1;
							data_out <= FIFO_output[0];						
						end
						else if(counter == 3)
						begin
							counter <= 0;
							FIFO_readEn <= 1;
							data_out <= FIFO_output[1];						
						end
				end
				2: begin
						if(counter == 0)
						begin
							FIFO_readEn <= 1;
							data_out <= FIFO_output[1];
							counter <= 1;
						end
						else if(counter == 1)
						begin
							counter <= 2;
							FIFO_readEn <= 0;
							data_out <= FIFO_output[0];
						end
						else if(counter == 2)
						begin
							counter <= 0;
							outputValid <= 1;
							FIFO_readEn <= 1;
							data_out <= FIFO_output[0];						
						end
				end
			endcase
		end
		else
		begin
			data_out <= 0;
			FIFO_readEn <= 0;
			counter <= 0;
			outputValid <= 0;
		end
	end
	
EncoderFIFO FIFO(
  .clk(clock), // input clk
  .rst(reset), // input rst
  .din(FIFO_input), // input [1 : 0] din
  .wr_en(inputValid), // input wr_en
  .rd_en(FIFO_readEn), // input rd_en
  .dout(FIFO_output), // output [1 : 0] dout
  .full(), // output full
  .empty(FIFO_empty) // output empty
);
		
endmodule 