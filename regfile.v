`include "defines.v"
`define INIT_SP 32'h0000_1c00
module regfile(
    input  wire 				 clk,
	input  wire 				 resetn,
	
	input  wire  [`REG_ADDR_BUS] inst1_wa,
	input  wire  [`REG_BUS 	   ] inst1_wd,
	input  wire 				 inst1_we,
	input  wire  [`REG_ADDR_BUS] inst2_wa,
	input  wire  [`REG_BUS 	   ] inst2_wd,
	input  wire 				 inst2_we,

	input  wire  [`REG_ADDR_BUS] inst1_ra1,
	output reg   [`REG_BUS 	   ] inst1_rd1,
	input  wire 				 inst1_re1,
	input  wire  [`REG_ADDR_BUS] inst2_ra1,
	output reg   [`REG_BUS 	   ] inst2_rd1,
	input  wire 				 inst2_re1,
	
	input  wire  [`REG_ADDR_BUS] inst1_ra2,
	output reg   [`REG_BUS 	   ] inst1_rd2,
	input  wire 			     inst1_re2,
	input  wire  [`REG_ADDR_BUS] inst2_ra2,
	output reg   [`REG_BUS 	   ] inst2_rd2,
	input  wire 			     inst2_re2
    );

	reg [`REG_BUS] 	regs[0:`REG_NUM-1];
	integer i; 
	always @(posedge clk) begin
		if (resetn == `RST_ENABLE) begin
			for(i = 0; i < `REG_NUM - 1; i = i + 1) begin
				regs[i] <= 0; 
			end
		end
		else begin
			if ((inst1_we & inst2_we ==  `WRITE_ENABLE) && (inst1_wa == inst2_wa ) && inst1_wa != 0) begin
				regs[inst1_wa] <= inst1_wd; // it should be not
			end
			else begin
				if(inst1_we == `WRITE_ENABLE &&  inst1_we != 0) begin
					regs[inst1_wa] <= inst1_wd;
				end
				if(inst2_we == `WRITE_ENABLE &&  inst2_we != 0) begin
					regs[inst2_wa] <= inst2_wd;
 				end
			end
		end
	end
	
	always @(*) begin
		if (resetn == `RST_ENABLE)
			inst1_rd1 <= `ZERO_WORD;
		else if (inst1_ra1 == `REG_NOP)
			inst1_rd1 <= `ZERO_WORD;
		else if ( (inst1_re1 == `READ_ENABLE) && (inst1_we == `WRITE_ENABLE)  && (inst1_ra1 == inst1_wa))
			inst1_rd1 <= inst1_wd;
		else if (inst1_re1 == `READ_ENABLE)
			inst1_rd1 <= regs[inst1_ra1];
		else
			inst1_rd1 <= `ZERO_WORD;
	end

	always @(*) begin
		if (resetn == `RST_ENABLE)
			inst1_rd2 <= `ZERO_WORD;
		else if (inst1_ra2 == `REG_NOP)
			inst1_rd2 <= `ZERO_WORD;
		else if ( (inst1_re2 == `READ_ENABLE) && (inst1_we == `WRITE_ENABLE)  && (inst1_ra2 == inst1_wa))
			inst1_rd2 <= inst1_wd;
		else if (inst1_re2 == `READ_ENABLE)
			inst1_rd2 <= regs[inst1_ra2];
		else
			inst1_rd2 <= `ZERO_WORD;
	end


	always @(*) begin
		if (resetn == `RST_ENABLE)
			inst2_rd1 <= `ZERO_WORD;
		else if (inst2_ra1 == `REG_NOP)
			inst2_rd1 <= `ZERO_WORD;
		else if ( (inst2_re1 == `READ_ENABLE) && (inst2_we == `WRITE_ENABLE)  && (inst2_ra1 == inst2_wa))
			inst2_rd1 <= inst2_wd;
		else if (inst2_re1 == `READ_ENABLE)
			inst2_rd1 <= regs[inst2_ra1];
		else
			inst2_rd1 <= `ZERO_WORD;
	end

	always @(*) begin
		if (resetn == `RST_ENABLE)
			inst2_rd2 <= `ZERO_WORD;
		else if (inst2_ra2 == `REG_NOP)
			inst2_rd2 <= `ZERO_WORD;
		else if ( (inst2_re2 == `READ_ENABLE) && (inst2_we == `WRITE_ENABLE)  && (inst2_ra2 == inst2_wa))
			inst2_rd2 <= inst1_wd;
		else if (inst2_re2 == `READ_ENABLE)
			inst2_rd2 <= regs[inst2_ra2];
		else
			inst2_rd2 <= `ZERO_WORD;
	end

endmodule
