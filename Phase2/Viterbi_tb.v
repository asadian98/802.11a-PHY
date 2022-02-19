`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:57:02 01/21/2021 
// Design Name: 
// Module Name:    Viterbi_tb 
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
module Viterbi_tb;

reg clk, rst, enable;
reg [1:0] inData;
wire Voutput, outputValid;

Viterbi V1(
		.clock(clk),
		.reset(rst),
		.enable(enable),
		.Vinput(inData),
		.outputValid(outputValid),
		.Voutput(Voutput)
    );
defparam V1.N = 96;
integer op_DataIn, read, fsa, counter, op_DataOut;
 
	initial
	begin
		clk = 0;
		rst = 1;
		counter = 0;
		#20;

		rst = 0;
		#10;
		read = 1;
		// Input data
		op_DataIn = $fopen("Viterbi_DataIn.txt", "r");
		if(op_DataIn)  $display("File Viterbi_DataIn.txt was opened successfully !");
		else    			$display("File Viterbi_DataIn.txt was NOT opened successfully !");

		// Output data
		op_DataOut = $fopen("Viterbi_DataOut_HDL.txt", "w");
		if(op_DataOut) $display("File Viterbi_DataOut_HDL.txt was opened successfully !");
		else    			$display("File Viterbi_DataOut_HDL.txt was NOT opened successfully !");
		
			
		#10;
		enable = 1;
		
	end

	always @(posedge clk) 
	begin
		if(read)
		begin
			fsa <= $fscanf(op_DataIn, "%b\n", inData);

			counter <= counter + 1;	
		end
		if(outputValid)     // Data is valid after one clock cycle after Enable = 1;
			$fwrite(op_DataOut, "%b\n", Voutput);
		
		if(counter == 95)
		begin
			$fclose(op_DataIn);
			read = 0;
		end
	end
	// Clock period --> 20 ns
	always #10 clk = ~clk;

endmodule
