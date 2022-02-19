`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:47:02 01/02/2021 
// Design Name: 
// Module Name:    Descrambler_tb 
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
module Descrambler_tb;

	reg clock;
	reg Reset;
	reg DescramblerInputDataVALID;
	reg [6:0] InitialState;
	reg DataIN;
	wire DataOUT;
	wire DataVALID;
	
	integer counter, read;
	integer op_DataOut, op_DataIn, op_Sequence, fsa;

	Descrambler MyDescrambler(
		 .clock(clock), 
		 .Descrambler_Reset(Reset), 
		 .Descrambler_InitialState(InitialState), 
		 .Descrambler_DataIN(DataIN),
		 .Descrambler_DataIN_VALID(DescramblerInputDataVALID),		 
		 .Descrambler_DataOUT(DataOUT),
		 .Descrambler_DataVALID(DataVALID)
		 );

	initial 
	begin
		// Initialization 
		clock = 0;
		Reset = 1;
		InitialState = 7'b101_1101;
		counter = 0;
		read = 0;
		
		// Reset --> 0
		#20;
		Reset = 0;
		
		// Files preparation
		#10;
		read = 1;
		
		// Input data
		op_DataIn = $fopen("Descrambler_DataIn_Matlab.txt", "r");
		if(op_DataIn)  $display("File Descrambler_DataIn_Matlab.txt was opened successfully !");
		else    			$display("File Descrambler_DataIn_Matlab.txt was NOT opened successfully !");
		
		// Output data
		op_DataOut = $fopen("Descrambler_DataOut_HDL.txt", "w");
		if(op_DataOut) $display("File Descrambler_DataOut_HDL.txt was opened successfully !");
		else    			$display("File Descrambler_DataOut_HDL.txt was NOT opened successfully !");
		
		// Descrambling sequence
		op_Sequence = $fopen("Descrambler_Sequence_HDL.txt", "w");
		if(op_Sequence)	$display("File Descrambler_Sequence_HDL.txt was opened successfully !");
		else    			   $display("File Descrambler_Sequence_HDL.txt was NOT opened successfully !");
		
		// input data valid --> 1
		#10;
		DescramblerInputDataVALID = 1;
		$display("Running Testbench");
		$display("Descrambling sequence :");		
	end
	
	always @(posedge clock) 
	begin
		if(read)
		begin
			fsa <= $fscanf(op_DataIn, "%b\n", DataIN);
		end
		if(DataVALID)     // Data is valid after one clock cycle after Enable = 1;
		begin
			$monitor("%b", MyDescrambler.state[0]);
			$fwrite(op_Sequence, "%b\n", MyDescrambler.state[0]);
			$fwrite(op_DataOut, "%b\n", DataOUT);
			counter <= counter + 1;
		end
		
		// After 100 input data
		if(counter == 99)
		begin
			$fclose(op_Sequence);
			$fclose(op_DataOut);
			$fclose(op_DataIn);
			$display("Simulation finished !");
			$finish;
		end
	end
	
	// Clock period --> 20 ns
	always #10 clock = ~clock;
	
endmodule 