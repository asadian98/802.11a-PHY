`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:54:55 02/07/2021 
// Design Name: 
// Module Name:    Serial2Parallel 
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
module Serial2Parallel(
	input wire clock,
	input wire reset,
	input wire data_in,
	input wire [1:0] mode,				// mode : 0 --> r = 1/2, 1 --> r = 3/4, 2 --> r = 2/3
	input wire data_in_valid,
	input wire read_en,
	output reg [1:0] data_out,
	output reg data_out_valid
    );

reg [500:0] MEM; //max needed: 4096 * 8 / 2 - 1 = 16383
reg [1:0] counter; 
reg [13:0] writeCounter, readCounter;

always@(posedge clock)
begin
	if(reset)
	begin
		writeCounter <= 0;
		counter <= 0;
	end
	else if(data_in_valid)
	begin
		case(mode) // mode : 0 --> r = 1/2, 1 --> r = 3/4, 2 --> r = 2/3
			0:begin
				MEM[writeCounter] <= data_in;
				writeCounter <= writeCounter + 1;
			end
			1:begin
				if(counter == 3)
				begin
					MEM[writeCounter] <= data_in;
					writeCounter <= writeCounter + 1;
					counter <= 0;
				end
				else if(counter == 2)
				begin
					MEM[writeCounter] <= data_in;
					MEM[writeCounter+1] <= 0;
					MEM[writeCounter+2] <= 0;
					writeCounter <= writeCounter + 3;
					counter <= 3;
				end
				else
				begin
					counter <= counter + 1;
					MEM[writeCounter] <= data_in;
					writeCounter <= writeCounter + 1;
				end
			end
			2:begin
				if(counter == 2)
				begin
					MEM[writeCounter] <= data_in;
					MEM[writeCounter+1] <= 0;
					writeCounter <= writeCounter + 2;
					counter <= 0;
				end
				else
				begin
					counter <= counter + 1;
					MEM[writeCounter] <= data_in;
					writeCounter <= writeCounter + 1;
				end
			end
		endcase
	end
end

always@(posedge clock)
begin
	if(reset)
	begin
		readCounter <= 0;
		data_out_valid <= 0;
		data_out <= 0;
	end
	else if(read_en)
	begin
		data_out <= {MEM[readCounter+1], MEM[readCounter]};
		readCounter <= readCounter + 2;
		data_out_valid <= 1;
	end
end

endmodule
