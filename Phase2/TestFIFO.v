`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:58:47 02/06/2021 
// Design Name: 
// Module Name:    TestFIFO 
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
module TestFIFO(
	wire clock,
	wire reset,
	wire [1:0] din,
	wire writeEN,
	wire readEN,
	wire [1:0] dout,
	wire full,
	wire empty
    );

EncoderFIFO myFIFO (
  .clk(clock), // input clk
  .rst(reset), // input rst
  .din(din), // input [1 : 0] din
  .wr_en(writeEN), // input wr_en
  .rd_en(readEN), // input rd_en
  .dout(dout), // output [1 : 0] dout
  .full(full), // output full
  .empty(empty) // output empty
);


endmodule
