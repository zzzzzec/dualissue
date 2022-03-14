`include "defines.v"
`timescale 1ns / 1ps
`define IP7_IP0 15:8

module CP0(
    input wire 			    	clk,
    input wire 					resetn,
    input wire                  re,
    input wire[`CP0_ADDR_BUS]   raddr,
    input wire[`CP0_ADDR_BUS]   waddr,
    input wire                  we,
    input wire[`WORD_BUS]       wdata,

	input wire[`WORD_BUS]		badaddr,
	input wire[`WORD_BUS]		pc_i,
	input wire[`EXC_CODE_BUS]	exccode,
	input wire					in_delay,

	output reg   				flush,
    output reg[`WORD_BUS]      	data_o,
    output wire[`WORD_BUS]     	cause_o,
    output wire[`WORD_BUS]      status_o,
	output reg[`WORD_BUS]	 	excaddr
    );

reg [`WORD_BUS] CP0reg[0:31];

always @(*) begin
	if(resetn == `RST_ENABLE)  begin
		flush = 1'b0;
	end
	else begin
		if(exccode != `EXC_NONE) begin
			flush = 1'b1;
		end
		else begin
			flush = 1'b0;
		end
	end
end

always @(*) begin
	if(resetn == `RST_ENABLE) begin
		excaddr = `PC_INIT;
	end
	else begin
			case (exccode)
				`EXC_NONE: begin
					excaddr = `ZERO_WORD;
				end
				`EXC_INT :begin
					excaddr = `EXC_INT_ADDR;
				end 
				`EXC_ERET:begin
					excaddr = (waddr == `EPC && we == `WRITE_ENABLE)? wdata : CP0reg[`EPC];
				end
				default: begin
					excaddr = `EXC_ADDR;
				end
			endcase
	end
end

always @(posedge clk) begin
    if(resetn == `RST_ENABLE) begin
        	CP0reg[ 0] <= `ZERO_WORD;
			CP0reg[ 1] <= `ZERO_WORD;     
			CP0reg[ 2] <= `ZERO_WORD;
			CP0reg[ 3] <= `ZERO_WORD;
			CP0reg[ 4] <= `ZERO_WORD;
			CP0reg[ 5] <= `ZERO_WORD;
			CP0reg[ 6] <= `ZERO_WORD;
			CP0reg[ 7] <= `ZERO_WORD;	

			CP0reg[`BadVaddr] <= `ZERO_WORD;
			
			CP0reg[ 9] <= `ZERO_WORD;
			CP0reg[10] <= `ZERO_WORD;
			CP0reg[11] <= `ZERO_WORD;

			CP0reg[`Status	] <= 32'h1000_0000;
			CP0reg[`Cause	] <= {25'b0,`EXC_NONE,2'b0};
			CP0reg[`EPC		] <= `ZERO_WORD;

			CP0reg[15] <= `ZERO_WORD;
			CP0reg[16] <= `ZERO_WORD;
			CP0reg[17] <= `ZERO_WORD;
			CP0reg[18] <= `ZERO_WORD;
			CP0reg[19] <= `ZERO_WORD;
			CP0reg[20] <= `ZERO_WORD;
			CP0reg[21] <= `ZERO_WORD;
			CP0reg[22] <= `ZERO_WORD;
			CP0reg[23] <= `ZERO_WORD;
			CP0reg[24] <= `ZERO_WORD;
			CP0reg[25] <= `ZERO_WORD;
			CP0reg[26] <= `ZERO_WORD;
			CP0reg[27] <= `ZERO_WORD;
			CP0reg[28] <= `ZERO_WORD;
			CP0reg[29] <= `ZERO_WORD;
			CP0reg[30] <= `ZERO_WORD;
			CP0reg[31] <= `ZERO_WORD;
    end
    else begin
		case (exccode)
			`EXC_NONE: begin
				if(we == `WRITE_ENABLE) begin
            		CP0reg[waddr] <= wdata;
        		end
			end	
			`EXC_ERET: begin
				CP0reg[`Status][`STATUS_EXL] <= 1'b0;
			end
			default: begin
				if(CP0reg[`Status][`STATUS_EXL] == 0) begin
					if(in_delay) begin
						CP0reg[`Cause][`CAUSE_BD] <= 1;
						CP0reg[`EPC] <= pc_i - 4;
					end
					else begin
						CP0reg[`Cause][`CAUSE_BD] <= 0;
						CP0reg[`EPC] <= pc_i;
					end
				end
				CP0reg[`Status][`STATUS_EXL] <= 1'b1;
				CP0reg[`Cause][`CAUSE_EXCCODE] <= exccode;
				if(exccode == `EXC_AdEL || exccode == `EXC_AdES) begin
					CP0reg[`BadVaddr] <= badaddr;
				end
			end 
		endcase

	end
end

assign cause_o 	 = CP0reg[`Cause];
assign status_o  = CP0reg[`Status];

always @(*) begin
	if(resetn == `RST_ENABLE) begin
		data_o <= `ZERO_WORD;
	end
    else begin
		if(re == `READ_ENABLE) begin
        	data_o <= CP0reg[raddr];
    	end
		else begin
			
		end
	end
end

endmodule
