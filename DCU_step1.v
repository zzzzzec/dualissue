`timescale 1ns / 1ps
`include "defines.v"

module DCU_step1(
	input wire[5:0]			  op,
	input wire[5:0]			  func,
	input wire[`REG_ADDR_BUS] rt,
	input wire[`REG_ADDR_BUS] rs,

	output wire 			inst_add,
	output wire             inst_addi,
	output wire             inst_addu,
	output wire             inst_addiu,
	output wire             inst_sub,
	output wire 			inst_subu,
	output wire 			inst_slt,
	output wire 			inst_slti,
	output wire				inst_sltu,
	output wire				inst_sltiu,
	output wire				inst_mult,
	output wire				inst_multu,
	output wire             inst_div,
	output wire             inst_divu,
	
	output wire				inst_and,
	output wire 			inst_andi,
	output wire 			inst_lui ,
	output wire 			inst_nor ,
	output wire				inst_or,
	output wire 			inst_ori,
	output wire				inst_xor,
	output wire 			inst_xori,
	
	output wire 			inst_sll ,
	output wire             inst_sllv,
	output wire             inst_sra,
	output wire             inst_srav ,
	output wire             inst_srl ,
	output wire             inst_srlv ,
	output wire             inst_mfhi,
	output wire             inst_mflo,
	output wire             inst_mthi,
	output wire             inst_mtlo,
	output wire             inst_lb,
	output wire             inst_lbu,
	output wire             inst_lh,
	output wire             inst_lhu,
	output wire 			inst_lw,

	output wire 			inst_sb,
	output wire             inst_sh,
	output wire 			inst_sw,

	output wire 			inst_j,
	output wire 			inst_jal,
	output wire 			inst_jr,
	output wire             inst_jalr,

	output wire 			inst_beq,
	output wire 			inst_bne,
	output wire             inst_bgez,
	output wire             inst_bgtz,
	output wire				inst_blez,
	output wire             inst_bltz,
	output wire             inst_bgezal,
	output wire             inst_bltzal,

	output wire    			inst_mfc0,
	output wire 			inst_mtc0,
	output wire 			inst_eret,

	output wire 			inst_syscall,
	output wire             inst_break
    );
wire inst_reg = ~|op;
wire inst_bgez_group;
wire inst_mtc0_group;

assign inst_add = inst_reg & (func[5]) & (~func[4]) & (~func[3]) & (~func[2]) & (~func[1]) & (~func[0]);
assign inst_addi =    (~op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (~op[1]) & (~op[0]) ;
assign inst_addu = inst_reg & (func[5]) & (~func[4]) & (~func[3]) & (~func[2]) & (~func[1]) & (func[0]);
assign inst_addiu = (~op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (~op[1]) & (op[0]);

assign inst_sub =  inst_reg & (func[5]) & (~func[4]) & (~func[3]) & (~func[2]) & (func[1]) & (~func[0]);
assign inst_subu = inst_reg & (func[5]) & (~func[4]) & (~func[3]) & (~func[2]) & (func[1]) & (func[0]);

assign inst_slt = inst_reg & (func[5]) & (~func[4]) & (func[3]) & (~func[2]) & (func[1]) & (~func[0]);
assign inst_slti = 	(~op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (op[1]) & (~op[0]);
assign inst_sltu = inst_reg & (func[5]) & (~func[4]) & (func[3]) & (~func[2]) & (func[1]) & (func[0]);
assign inst_sltiu = (~op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (op[1]) & (op[0]);
assign inst_mult = inst_reg & (~func[5]) & (func[4]) & (func[3]) & (~func[2]) & (~func[1]) & (~func[0]);
assign inst_multu = inst_reg & (~func[5]) & (func[4]) & (func[3]) & (~func[2]) & (~func[1]) & (func[0]);
assign inst_div = inst_reg & (~func[5]) & (func[4]) & (func[3]) & (~func[2]) & (func[1]) & (~func[0]);
assign inst_divu = inst_reg & (~func[5]) & (func[4]) & (func[3]) & (~func[2]) & (func[1]) & (func[0]);

assign inst_and = inst_reg & (func[5]) & (~func[4]) & (~func[3]) & (func[2]) & (~func[1]) & (~func[0]);
assign inst_andi =(~op[5]) & (~op[4]) & (op[3]) & (op[2]) & (~op[1]) & (~op[0]) ;
assign inst_lui = (~op[5]) & (~op[4]) & (op[3]) & (op[2]) & (op[1]) & (op[0]);
assign inst_nor = inst_reg & (func[5]) & (~func[4]) & (~func[3]) & (func[2]) & (func[1]) & (func[0]);
assign inst_or =  inst_reg & (func[5]) & (~func[4]) & (~func[3]) & (func[2]) & (~func[1]) & (func[0]); 
assign inst_ori = (~op[5]) & (~op[4]) & (op[3]) & (op[2]) & (~op[1]) & (op[0]);
assign inst_xor = inst_reg & (func[5]) & (~func[4]) & (~func[3]) & (func[2]) & (func[1]) & (~func[0]);
assign inst_xori = (~op[5]) & (~op[4]) & (op[3]) & (op[2]) & (op[1]) & (~op[0]);

assign inst_sll = inst_reg & (~func[5]) & (~func[4]) & (~func[3]) & (~func[2]) & (~func[1]) & (~func[0]);
assign inst_sllv = inst_reg & (~func[5]) & (~func[4]) & (~func[3]) & (func[2]) & (~func[1]) & (~func[0]);
assign inst_sra = inst_reg & (~func[5]) & (~func[4]) & (~func[3]) & (~func[2]) & (func[1]) & (func[0]);
assign inst_srav = inst_reg & (~func[5]) & (~func[4]) & (~func[3]) & (func[2]) & (func[1]) & (func[0]);
assign inst_srl = inst_reg & (~func[5]) & (~func[4]) & (~func[3]) & (~func[2]) & (func[1]) & (~func[0]);
assign inst_srlv = inst_reg & (~func[5]) & (~func[4]) & (~func[3]) & (func[2]) & (func[1]) & (~func[0]);

assign inst_mfhi = inst_reg & (~func[5]) & (func[4]) & (~func[3]) & (~func[2]) & (~func[1]) & (~func[0]);
assign inst_mflo = inst_reg & (~func[5]) & (func[4]) & (~func[3]) & (~func[2]) & (func[1]) & (~func[0]); 
assign inst_mthi =  inst_reg & (~func[5]) & (func[4]) & (~func[3]) & (~func[2]) & (~func[1]) & (func[0]);
assign inst_mtlo =  inst_reg & (~func[5]) & (func[4]) & (~func[3]) & (~func[2]) & (func[1]) & (func[0]);

assign inst_lb = (op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (~op[1]) & (~op[0]);
assign inst_lbu =  (op[5]) & (~op[4]) & (~op[3]) & (op[2]) & (~op[1]) & (~op[0]);
assign inst_lh =  (op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (~op[1]) & (op[0]);
assign inst_lhu =  (op[5]) & (~op[4]) & (~op[3]) & (op[2]) & (~op[1]) & (op[0]);
assign inst_lw = (op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (op[1]) & (op[0]);

assign inst_sb = (op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (~op[1]) & (~op[0]);
assign inst_sh = (op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (~op[1]) & (op[0]);
assign inst_sw = (op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (op[1]) & (op[0]);

assign inst_jal =  (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (op[1]) & (op[0]);
assign inst_j =    (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (op[1]) & (~op[0]);
assign inst_jr = inst_reg & (~func[5]) & (~func[4]) & (func[3]) & (~func[2]) & (~func[1]) & (~func[0]);
assign inst_jalr = inst_reg & (~func[5]) & (~func[4]) & (func[3]) & (~func[2]) & (~func[1]) & (func[0]);

assign inst_beq  = (~op[5]) & (~op[4]) & (~op[3]) & (op[2])  & (~op[1]) & (~op[0]);
assign inst_bne  = (~op[5]) & (~op[4]) & (~op[3]) & (op[2])  & (~op[1]) & (op[0]);	
assign inst_bgtz = (~op[5]) & (~op[4]) & (~op[3]) & (op[2])  & (op[1])  & (op[0]);	
assign inst_blez = (~op[5]) & (~op[4]) & (~op[3]) & (op[2])  & (op[1])  & (~op[0]);	

assign inst_bgez_group  = (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (~op[1]) & (op[0]);	

assign inst_bgez = inst_bgez_group & ((~rt[4]) & (~rt[3]) & (~rt[2]) & (~rt[1]) & (rt[0]));
assign inst_bltz = inst_bgez_group & ((~rt[4]) & (~rt[3]) & (~rt[2]) & (~rt[1]) & (~rt[0]));
assign inst_bgezal = inst_bgez_group & ((rt[4]) & (~rt[3]) & (~rt[2]) & (~rt[1]) & (rt[0]));
assign inst_bltzal = inst_bgez_group & ((rt[4]) & (~rt[3]) & (~rt[2]) & (~rt[1]) & (~rt[0]));

assign inst_mtc0_group = (~op[5]) & (op[4]) & (~op[3]) & (~op[2]) & (~op[1]) & (~op[0]);
assign inst_eret = inst_mtc0_group & rs[4];
//
assign inst_mfc0 = inst_mtc0_group & ((~rs[4]) & (~rs[3]) & (~rs[2]) & (~rs[1]) & (~rs[0]) );
//00100
assign inst_mtc0 = inst_mtc0_group & ((~rs[4]) & (~rs[3]) & rs[2] & (~rs[1]) & (~rs[0]) );

assign inst_syscall = inst_reg & (~func[5]) & (~func[4]) & (func[3]) & (func[2]) & (~func[1]) & (~func[0]);
assign inst_break   = inst_reg & (~func[5]) & (~func[4]) & (func[3]) & (func[2]) & (~func[1]) & (func[0]);
endmodule


