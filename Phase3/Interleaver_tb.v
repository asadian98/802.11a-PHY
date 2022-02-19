`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:57:53 01/27/2021 
// Design Name: 
// Module Name:    Interleaver_tb 
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
module Interleaver_tb;
	
	reg clock;
	reg Reset;
	reg DataIN;
	reg [1:0] mode;
	wire DataOUT;
	wire DataOUTVALID;
	reg DataINVALID;
	
	integer counter, read, outputCounter;
	integer op_DataOut, op_DataIn, fsa, numData;

Interleaver InterLeaver1 (
    .clock(clock), 
    .reset(Reset), 
    .inputData(DataIN), 
    .inputValid(DataINVALID), 
    .mode(mode), 
    .outputData(DataOUT), 
    .outputValid(DataOUTVALID)
    );


	initial 
	begin
		// Initialization 
		clock = 0;
		Reset = 1;
		counter = 0;
		outputCounter = 0;
		read = 0;
		mode = 3;
		numData = 576;
		// Reset --> 0
		#20;
		Reset = 0;
		
		// Files preparation
		#10;
		read = 1;
		
		// Input data
		op_DataIn = $fopen("Interleaver_DataIn.txt", "r");
		if(op_DataIn)  $display("File Interleaver_DataIn.txt was opened successfully !");
		else    			$display("File Interleaver_DataIn.txt was NOT opened successfully !");
		
		// Output data
		op_DataOut = $fopen("Interleaver_DataOut_HDL.txt", "w");
		if(op_DataOut) $display("File Interleaver_DataOut_HDL.txt was opened successfully !");
		else    			$display("File Interleaver_DataOut_HDL.txt was NOT opened successfully !");
		
		// Enable --> 1
		#10;
		DataINVALID = 1;
		
		$display("Running Testbench");	

	end
	
	always @(posedge clock) 
	begin
		if(read)
		begin
			fsa <= $fscanf(op_DataIn, "%b\n", DataIN);
			counter <= counter + 1;
		end
		if(DataOUTVALID)     
		begin
			$fwrite(op_DataOut, "%b\n", DataOUT);
			outputCounter = outputCounter + 1;
		end
		
		if(counter == numData)
		begin	
			read = 0;
			DataINVALID <= 0;
		end	
		// After 100 input data
		if(outputCounter == numData)
		begin
			$fclose(op_DataOut);
			$fclose(op_DataIn);
			$display("Simulation finished !");
			$finish;
		end
	end
	
	// Clock period --> 20 ns
	always #10 clock = ~clock;
	
endmodule 