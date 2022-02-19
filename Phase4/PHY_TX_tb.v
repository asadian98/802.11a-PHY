`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:17:23 02/07/2021 
// Design Name: 
// Module Name:    PHY_TX_tb 
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
module PHY_TX_tb;

	reg clock;
	reg Reset;
	reg enable;
	reg PHY_TXSTART_req;
	reg PHY_DATA_req;
	reg inputData;
	reg [34:0] TXVECTOR;
	
	wire PHY_TXSTART_conf;
	wire TX_OUT;
	wire PHY_DATA_conf;
	wire TX_OUT_VALID;
	
	integer counter, read, write;
	integer op_DataOut, op_DataIn, op_Sequence, fsa;

PHY_TX Transmitter(
    .clock(clock), 
    .reset(Reset), 
    .enable(enable), 
    .PHY_TXSTART_req(PHY_TXSTART_req), 
    .PHY_TXSTART_conf(PHY_TXSTART_conf), 
    .PHY_DATA_req(PHY_DATA_req), 
    .PHY_DATA_conf(PHY_DATA_conf), 
    .inputData(inputData), 
    .TXVECTOR(TXVECTOR), 
    .TX_OUT(TX_OUT), 
    .TX_OUT_VALID(TX_OUT_VALID)
    );
	reg [3:0] 	 Rate;
	reg [11:0] 	 Length;
	reg [15:0] 	 Service;
	reg [2:0] 	 PowerLevel;

	initial 
	begin
		// Initialization 
		clock = 0;
		Reset = 1;
		counter = 0;
		read = 0;
		
		// Reset --> 0
		#20;
		Reset = 0;
		#160;
		// Files preparation
		#10;
		
		// Input data
		op_DataIn = $fopen("Scrambler_DataIn_Matlab.txt", "r");
		if(op_DataIn)  $display("File Scrambler_DataIn_Matlab.txt was opened successfully !");
		else    			$display("File Scrambler_DataIn_Matlab.txt was NOT opened successfully !");
		
		// Output data
		op_DataOut = $fopen("Interleaver_DataOut_HDL.txt", "w");
		if(op_DataOut) $display("File ConvEncoder_DataOut_HDL.txt was opened successfully !");
		else    			$display("File ConvEncoder_DataOut_HDL.txt was NOT opened successfully !");

		// input data valid --> 1
		#10;
		enable = 1;
		PHY_TXSTART_req = 1;
		Length = 12;
		Rate = 4'b1011;
		Service = 16'd0;
		PowerLevel = 0;
		TXVECTOR = {Length, Rate, Service, PowerLevel};
		
		#10;
		read = 1;
		#10;
		PHY_TXSTART_req = 0;
		PHY_DATA_req = 1;
		
		$display("Running Testbench");
		$display("Scrambling sequence :");		
	end
	
		
	always @(posedge clock) 
	begin
		if(PHY_DATA_conf)
			PHY_DATA_req <= 0;
	end
	
	always @(posedge clock) 
	begin
		if(read)
		begin
			fsa <= $fscanf(op_DataIn, "%b\n", inputData);
		end
		if(TX_OUT_VALID)		// Data is valid after one clock cycle after Enable = 1;
		begin 
			$fwrite(op_DataOut, "%b\n", TX_OUT);
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
