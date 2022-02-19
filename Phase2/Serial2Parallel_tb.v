`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:27:28 02/07/2021 
// Design Name: 
// Module Name:    Serial2Parallel_tb 
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
module Serial2Parallel_tb;
	reg clock;
	reg Reset;
	reg DataIN;
	reg [1:0] mode;
	wire DataOUT1;
	wire DataOUT2;
	wire DataOUTVALID;
	reg DataINVALID;
	reg read_enable;
	
	integer counter, read, outputCounter, readcounter;
	integer op_DataOut, op_DataIn, fsa, numOfout, numofData;

Serial2Parallel S2P (
    .clock(clock), 
    .reset(Reset), 
    .data_in(DataIN), 
    .mode(mode), 
    .data_in_valid(DataINVALID), 
    .read_en(read_enable), 
    .data_out({DataOUT1, DataOUT2}), 
    .data_out_valid(DataOUTVALID)
    );


	initial 
	begin
		// Initialization 
		clock = 0;
		Reset = 1;
		counter = 0;
		outputCounter = 0;
		readcounter = 0;
		read = 0;
		mode = 2;
		numofData = 96;
		// Reset --> 0
		#20;
		if(mode == 0)
			numOfout = numofData / 2;
		
		if(mode == 1)
			numOfout = numofData * 3 / 4;
		
		if(mode == 2)
			numOfout = numofData * 2 / 3;
		
		Reset = 0;
		#160;
		// Files preparation
		#10;
		read = 1;
		
		// Input data
		op_DataIn = $fopen("Serial2Parallel_DataIn.txt", "r");
		if(op_DataIn)  $display("File Serial2Parallel_DataIn_Matlab.txt was opened successfully !");
		else    			$display("File Serial2Parallel_DataIn_Matlab.txt was NOT opened successfully !");
		
		// Output data
		op_DataOut = $fopen("Serial2Parallel_DataOut_HDL.txt", "w");
		if(op_DataOut) $display("File Serial2Parallel_DataOut_HDL.txt was opened successfully !");
		else    			$display("File Serial2Parallel_DataOut_HDL.txt was NOT opened successfully !");
		
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
			$fwrite(op_DataOut, "%b\n", DataOUT2);
			$fwrite(op_DataOut, "%b\n", DataOUT1);
	
			counter <= counter + 1;
		end
		if(DataINVALID)
			readcounter <= readcounter + 1;
		
		if(readcounter == numOfout)
			read_enable <= 1;
			
		if(counter == numOfout-1)
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

