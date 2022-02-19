`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:38:09 01/05/2021 
// Design Name: 
// Module Name:    PHY_RX 
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
module PHY_RX(

		input wire 			clock,
		input wire 			reset,
		input wire 			enable,
		
		input wire 			inputData,
		input wire 			RX_data,
		
		output reg 			RX_OUT,
		output reg			RX_OUT_VALID,
		
		output reg [34:0] RXVECTOR	
		
	);

	reg [3:0] 	 Rate;
	reg [11:0] 	 Length;
	reg [23:0] 	 Signal;
	reg [2:0]    RSSI;
	reg [15:0]	 Service;
	reg Parity;
	reg [1:0] mode;
	reg [6:0] dataCounter;
	reg [6:0] PreambleLength;
	integer rate, Npad;
	reg [29:0] Preamble;
	reg Deinterleaver_Start;
	
	reg Deinterleaver_data_in;
	reg Deinterleaver_inputValid;
	wire Deinterleaver_data_out;
	wire Deinterleaver_outputValid;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			dataCounter <= 0;
			PreambleLength <= 30; // Do not care in our project.
			RSSI <= 3'd0; // Do not care in our project.
			Service <= 16'd0;
		end
		else if(enable)
		begin
			if(RX_data) // We can have a FSM to detect the preamble too.
			begin
				if(dataCounter < PreambleLength)
				begin
					Preamble[dataCounter] <= inputData;
					dataCounter <= dataCounter + 1;
				end
				else if(dataCounter < PreambleLength + 24)
				begin
					Signal[dataCounter - PreambleLength] <= inputData;
					dataCounter <= dataCounter + 1;
				end
				else if(dataCounter == PreambleLength + 24)
				begin
					Deinterleaver_Start <= 1;
					Length <= Signal[16:5];
					Rate <= Signal[3:0];
					// We can check the parity bit here too.
					Parity <= Signal[17];
					RXVECTOR = {Length, RSSI, Rate, Service};
					dataCounter <= dataCounter + 1; 
					
					// mode : 0 --> r = 1/2, 1 --> r = 3/4, 2 --> r = 2/3
					case(Signal[3:0])
						4'b1011: begin rate = 6; mode <= 0; end
						4'b1111: begin rate = 9; mode <= 1; end
						4'b1010: begin rate = 12; mode <= 0; end
						4'b1110: begin rate = 18; mode <= 1; end
						4'b1001: begin rate = 24; mode <= 0; end
						4'b1101: begin rate = 36; mode <= 1; end
						4'b1000: begin rate = 48; mode <= 2; end
						4'b1100: begin rate = 54; mode <= 1; end
						default: begin rate = 6; mode <= 0; end
					endcase
					Npad = (rate * 8) - (22 + (Signal[16:5] << 3)) % (rate * 8);
				end
			end
		end
	end
	
	/************************   Deinterleaver   ************************/
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			Deinterleaver_inputValid <= 0;
			Deinterleaver_data_in <= 0;
		end
		else if(RX_data && Deinterleaver_Start)
		begin
			Deinterleaver_data_in <= inputData;
			Deinterleaver_inputValid <= RX_data;
		end
	end
	
	Deinterleaver RX_Deinterleaver(
    .clock(clock), 
    .reset(reset), 
    .inputData(Deinterleaver_data_in), 
    .inputValid(Deinterleaver_inputValid), 
    .mode(mode), 
    .outputData(Deinterleaver_data_out), 
    .outputValid(Deinterleaver_outputValid)
    );

	/************************   Serial to Parallel   ************************/

	reg Serial2Parallel_data_in;
	reg Serial2Parallel_inputValid;
	reg Serial2Parallel_readEnable;
	wire [1:0] Serial2Parallel_data_out;
	wire Serial2Parallel_outputValid;
	reg [12:0] counter;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			Serial2Parallel_inputValid <= 0;
			Serial2Parallel_data_in <= 0;
			Serial2Parallel_readEnable <= 0;
			counter <= 0;
		end
		else if(Deinterleaver_outputValid)
		begin
			Serial2Parallel_data_in <= Deinterleaver_data_out;
			Serial2Parallel_inputValid <= Deinterleaver_outputValid;
		end
		
		if((counter < ((Length << 3) + 22 + Npad)/2) && Serial2Parallel_inputValid)
		begin
			counter <= counter + 1;
		end
		else if(counter == ((Length << 3) + 22 + Npad)/2)
			Serial2Parallel_readEnable <= 1;
	end

	Serial2Parallel RX_Serial2Parallel(
    .clock(clock), 
    .reset(reset), 
    .data_in(Serial2Parallel_data_in), 
    .mode(mode), 
    .data_in_valid(Serial2Parallel_inputValid), 
    .read_en(Serial2Parallel_readEnable), 
    .data_out(Serial2Parallel_data_out), 
    .data_out_valid(Serial2Parallel_outputValid)
    );

	/************************   Viterbi Decoder   ************************/
	
	reg [1:0] viterbi_data_in;
	reg viterbi_enable;
	wire viterbi_data_out;
	wire viterbi_outputValid;
	reg flag;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			viterbi_enable <= 0;
			viterbi_data_in <= 0;
			flag <= 0;
		end
		else if(Serial2Parallel_outputValid)
		begin
			if(~flag)
			begin
				flag <= 1;
				viterbi_enable <= 1;
			end
			viterbi_data_in <= Serial2Parallel_data_out;
		end
	end

	Viterbi RX_Viterbi(
    .clock(clock), 
    .reset(reset), 
    .enable(viterbi_enable), 
    .Vinput(viterbi_data_in), 
    .outputValid(viterbi_outputValid), 
    .Voutput(viterbi_data_out)
    );

	defparam RX_Viterbi.N = 96;
	
	/************************   Descrambler   ************************/
	
	wire [6:0] Descrambler_InitialState;
	assign Descrambler_InitialState = 7'b101_1101;
	
	wire Descrambler_output;
	wire Descrambler_outputValid;
	reg Descrambler_inputValid;
	reg Descrambler_input;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			Descrambler_inputValid <= 0;
			Descrambler_input <= 0;
		end
		else if(viterbi_outputValid)
		begin
			Descrambler_input <= viterbi_data_out;
			Descrambler_inputValid <= viterbi_outputValid;
		end
	end
	
	Descrambler RX_Descrambler(
    .clock(clock), 
    .Descrambler_Reset(reset), 
    .Descrambler_InitialState(Descrambler_InitialState), 
    .Descrambler_DataIN(Descrambler_input), 
    .Descrambler_DataIN_VALID(Descrambler_inputValid), 
    .Descrambler_DataOUT(Descrambler_output), 
    .Descrambler_DataVALID(Descrambler_outputValid)
    );

	/************************   Output   ************************/
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			RX_OUT_VALID <= 0;
			RX_OUT <= 0;
		end
		else if(Descrambler_outputValid)
		begin
			RX_OUT <= Descrambler_output;
			RX_OUT_VALID <= Descrambler_outputValid;		
		end
	end
	

endmodule 