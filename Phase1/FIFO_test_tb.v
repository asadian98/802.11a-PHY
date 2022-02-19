`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:03:22 02/06/2021 
// Design Name: 
// Module Name:    FIFO_test_tb 
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
module FIFO_test_tb;


	 
reg clock1;
reg reset1;
reg writeEN;
reg readEN;
wire full;
wire empty;
wire [1:0] dout; 
reg [1:0] din;


TestFIFO MYFIFO(
	.clock(clock1),
	.reset(reset1),
	.din(din),
	.writeEN(writeEN),
	.readEN(readEN),
	.dout(dout),
	.full(full),
	.empty(empty)
    );
	 
	 
initial
begin
		clock1 = 0;
		reset1 = 1;
		#40;
		reset1 = 0;
		din = 2'b11;
		writeEN = 1;
		#20
		din = 2'b10;
		#20
		din = 2'b10;
		#20
		din = 2'b11;
		#20
		din = 2'b00;


end

	// Clock period --> 20 ns
	always #10 clock1 = ~clock1;

endmodule
