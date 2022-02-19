`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:07:49 01/15/2021 
// Design Name: 
// Module Name:    ConvEncoder_tb 
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
module ConvEncoder_tb;

	reg clock;
	reg Reset;
	reg DataIN;
	reg [1:0] mode;
	wire DataOUT1;
	wire DataOUT2;
	wire DataOUTVALID;
	reg DataINVALID;
	
	integer counter, read, outputCounter;
	integer op_DataOut, op_DataIn, fsa, numOfout, numofData;

Convolutional_Encoder CE(
		.clock(clock),
		.reset(Reset),
		.mode(mode),
		.data_in(DataIN),
		.inputValid(DataINVALID),
		.data_out(DataOUT1),
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
		mode = 2;
		numofData = 102;
		// Reset --> 0
		#20;
		if(mode == 0)
			numOfout = numofData * 2;
		
		if(mode == 1)
			numOfout = numofData * 4 / 3;
		
		if(mode == 2)
			numOfout = numofData * 3 / 2;
		
		Reset = 0;
		#160;
		// Files preparation
		#10;
		read = 1;
		
		// Input data
		op_DataIn = $fopen("ConvEncoder_DataIn_Matlab.txt", "r");
		if(op_DataIn)  $display("File ConvEncoder_DataIn_Matlab.txt was opened successfully !");
		else    			$display("File ConvEncoder_DataIn_Matlab.txt was NOT opened successfully !");
		
		// Output data
		op_DataOut = $fopen("ConvEncoder_DataOut_HDL.txt", "w");
		if(op_DataOut) $display("File ConvEncoder_DataOut_HDL.txt was opened successfully !");
		else    			$display("File ConvEncoder_DataOut_HDL.txt was NOT opened successfully !");
		
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
		end
		if(DataOUTVALID)     // Data is valid after one clock cycle after Enable = 1;
		begin
			$fwrite(op_DataOut, "%b\n", DataOUT1);
	
			counter <= counter + 1;
		end
		
		// After 100 input data
		if(counter == numOfout)
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

