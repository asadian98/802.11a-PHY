`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:46:52 01/05/2021 
// Design Name: 
// Module Name:    PHY_TX 
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
module PHY_TX(

		input wire 			clock,
		input wire 			reset,
		input wire 			enable,
		
		input wire 			PHY_TXSTART_req,
		output reg 			PHY_TXSTART_conf,
		
		input wire 			PHY_DATA_req,
		output reg 			PHY_DATA_conf,

		input wire 		 	inputData,
		
		input wire [34:0] TXVECTOR,
		
		output reg 			TX_OUT,
		output reg			TX_OUT_VALID
    );
	 
	parameter LenMax = 200; // Max Length : Standard : 4095
	
	// TXVECTOR : 0-3:Rate, 5-16:LENGTH
	reg [3:0] 	 Rate;
	reg [11:0] 	 Length;
	reg [23:0] 	 Signal;
	reg [15:0] 	 Service;
	reg [2:0] 	 PowerLevel;
	reg [29:0] 	 Preamble;
	reg [LenMax:0] PSDU;
	
	reg [11:0] PSDU_counter;
	reg [11:0] scramPSDU_counter;
	reg [287:0] Z; // Pad zeros 
	reg [LenMax*8+21:0] Data; 
	reg Scrambler_Start;
	reg [1:0] mode;
	
	integer Npad, rate;
	
	wire Parity;
	assign Parity = ^{Rate, 1'b0, Length};
	
	
	/************************   Frame Structure   ************************/
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			Preamble <= 'd0;
			PSDU_counter <= 'd0;
			Z <= 'd0;
			Scrambler_Start <= 0;
		end
		if(enable)
		begin
			if(PHY_TXSTART_conf == 1)
				PHY_TXSTART_conf <= 0;
			
			if(PHY_DATA_conf == 1)
				PHY_DATA_conf <= 0;
				
			if(PHY_TXSTART_req)	// PHY_TXSTART_req become unasserted after PHY_TXSTART_conf
			begin
				Length <= TXVECTOR[34:23];
				Rate <= TXVECTOR[22:19];
				
				// mode : 0 --> r = 1/2, 1 --> r = 3/4, 2 --> r = 2/3
				case(TXVECTOR[22:19])
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
				
				Service <= TXVECTOR[18:3];
				PowerLevel <= TXVECTOR[2:0];
				Signal <= {6'd0, Parity, TXVECTOR[34:23], 1'b0, TXVECTOR[22:19]}; 
				PHY_TXSTART_conf <= 1;
			end
			else if(PHY_DATA_req) // PHY_DATA_req become unasserted after PHY_DATA_conf
			begin
				if(PSDU_counter < (Length << 3))
				begin 
					PSDU[PSDU_counter] <= inputData;
					PSDU_counter <= PSDU_counter + 1;
				end
				else if(PSDU_counter == (Length << 3))
				begin
					PHY_DATA_conf <= 1;
					Scrambler_Start <= 1;
					Npad = (rate * 8) - (22 + (Length << 3)) % (rate * 8);
					//Data <= {Service, PSDU, 6'd0, Z[Npad-1:0]};
				end
			end
		end
	end
	
	
	/************************   Scrambler   ************************/
	
	reg [8:0] Npadcounter;
	reg [2:0] Tailcounter;
	reg [3:0] Servicecounter;
	reg [2:0] ScramState;
	wire Scrambler_output;
	wire Scrambler_outputValid;
	reg Scrambler_inputValid;
	reg Scrambler_input;
	wire [6:0] Scrambler_InitialState;
	assign Scrambler_InitialState = 7'b101_1101;
	
	localparam	PreScram = 'd0,
					sendPad = 'd1,
					sendTail = 'd2,
					sendPSDU = 'd3,
					sendService = 'd4;		
					
	always@(posedge clock)
	begin
		if(reset)
		begin
			Npadcounter <= 0;
			ScramState <= PreScram;
			scramPSDU_counter <= 0;
		end
		else if(Scrambler_Start)
		begin
			case(ScramState)
				PreScram:begin
					ScramState <= sendPad;
					Scrambler_input <= 0;
				end
				sendPad:begin
						if(Npadcounter < Npad)
						begin
							Scrambler_inputValid <= 1;
							Npadcounter <= Npadcounter + 1;
						end
						else
						begin
							Scrambler_input <= 0; // tail
							ScramState <= sendTail;
							Tailcounter <= 0;
						end
							
				end
				sendTail:begin
						if(Tailcounter < 5)
						begin
							Scrambler_input <= 0;
							Tailcounter <= Tailcounter + 1;
						end
						else
						begin
							Scrambler_input <= PSDU[0];
							ScramState <= sendPSDU;
							scramPSDU_counter <= 1;
						end
				end
				sendPSDU:begin
						if(scramPSDU_counter < (Length << 3))
						begin
							Scrambler_input <= PSDU[scramPSDU_counter];
							scramPSDU_counter <= scramPSDU_counter + 1;
						end
						else 
						begin
							Scrambler_input <= Service[0];
							ScramState <= sendService;
							Servicecounter <= 1;
						end
				end
				sendService:begin
					if(Servicecounter < 16)
					begin
						Scrambler_input <= Service[Servicecounter];
						Servicecounter <= Servicecounter + 1;
						if(Servicecounter == 15)
						begin
							Scrambler_inputValid <= 0;
						end
					end
				end
			endcase
		end
	end
	
	Scrambler TX_Scrambler(
    .clock(clock), 
    .Scrambler_Reset(reset), 
    .Scrambler_InitialState(Scrambler_InitialState), 
    .Scrambler_DataIN(Scrambler_input), 
    .Scrambler_DataIN_VALID(Scrambler_inputValid), 
    .Scrambler_DataOUT(Scrambler_output), 
    .Scrambler_DataOUTVALID(Scrambler_outputValid)
    );
	 
	/************************   Convolutional Encoder   ************************/
	
	reg Encoder_data_in;
	reg Encoder_inputValid; 
	wire Encoder_outputValid;
	wire Encoder_data_out;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			Encoder_inputValid <= 0;
			Encoder_data_in <= 0;
		end
		else if(Scrambler_outputValid)
		begin
			Encoder_data_in <= Scrambler_output;
			Encoder_inputValid <= Scrambler_outputValid;		
		end
	end
	
	Convolutional_Encoder TX_Encoder(
    .clock(clock), 
    .reset(reset), 
    .mode(mode), 
    .data_in(Encoder_data_in), 
    .inputValid(Encoder_inputValid), 
    .data_out(Encoder_data_out), 
    .outputValid(Encoder_outputValid)
    );


	/************************   Interleaver   ************************/

	reg Interleaver_data_in;
	reg Interleaver_inputValid; 
	wire Interleaver_outputValid;
	wire Interleaver_data_out;
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			Interleaver_inputValid <= 0;
			Interleaver_data_in <= 0;
		end
		else if(Encoder_outputValid)
		begin
			Interleaver_data_in <= Encoder_data_out;
			Interleaver_inputValid <= Encoder_outputValid;		
		end
	end
	
	Interleaver TX_Interleaver(
    .clock(clock), 
    .reset(reset), 
    .inputData(Interleaver_data_in), 
    .inputValid(Interleaver_inputValid), 
    .mode(mode), 
    .outputData(Interleaver_data_out), 
    .outputValid(Interleaver_outputValid)
    );

	/************************   Output   ************************/
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			TX_OUT_VALID <= 0;
			TX_OUT <= 0;
		end
		else if(Interleaver_outputValid)
		begin
			TX_OUT <= Interleaver_data_out;
			TX_OUT_VALID <= Interleaver_outputValid;		
		end
	end
	
endmodule
