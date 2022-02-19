`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:02:58 02/07/2021 
// Design Name: 
// Module Name:    PHY_RX_tb 
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
module PHY_RX_tb;
 
	reg clock;
	reg Reset;
	reg enable;
	reg RX_DATA; // indicates that data is available on the bus
	reg inputData;
	wire [34:0] RXVECTOR;
	
	wire RX_OUT;
	wire RX_OUT_VALID;
	
	integer counter, read, write;
	integer op_DataOut, op_DataIn, op_Sequence, fsa;

PHY_RX Reciever(
    .clock(clock), 
    .reset(Reset), 
    .enable(enable), 
    .inputData(inputData), 
    .RX_data(RX_DATA), 
    .RX_OUT(RX_OUT), 
    .RX_OUT_VALID(RX_OUT_VALID), 
    .RXVECTOR(RXVECTOR)
    );

	initial 
	begin
		// Initialization 
		clock = 0;
		Reset = 1;
		counter = 0;
		read = 0;
		RX_DATA = 0;
		// Reset --> 0
		#20;
		Reset = 0;
		#160;
		// Files preparation
		#10;
		
		// Input data
		op_DataIn = $fopen("Deinterleaver_DataIn.txt", "r");
		if(op_DataIn)  $display("File Deinterleaver_DataIn.txt was opened successfully !");
		else    			$display("File Deinterleaver_DataIn.txt was NOT opened successfully !");
		
		// Output data
		op_DataOut = $fopen("Deinterleaver_DataOut_HDL.txt", "w");
		if(op_DataOut) $display("File Deinterleaver_DataOut_HDL.txt was opened successfully !");
		else    			$display("File Deinterleaver_DataOut_HDL.txt was NOT opened successfully !");

		// input data valid --> 1
		#10;
		enable = 1;
		
		#10;
		read = 1;
		RX_DATA = 1;
		#10;
		
		$display("Running Testbench");
		$display("Scrambling sequence :");		
	end
	
	always @(posedge clock) 
	begin
		if(read)
		begin
			fsa <= $fscanf(op_DataIn, "%b\n", inputData);
		end
		if(RX_OUT_VALID)		// Data is valid after one clock cycle after Enable = 1;
		begin 
			$fwrite(op_DataOut, "%b\n", RX_OUT);
			counter <= counter + 1;
		end

		if(counter == 287)
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
