`include "defines.v"

module DCU_step2(
	input wire [`REG_BUS] 	reg_rs,
	input wire 				inst_add,
	input wire              inst_addi,
	input wire              inst_addu,
	input wire              inst_addiu,
	input wire              inst_sub,
	input wire 				inst_subu,
	input wire 				inst_slt,
	input wire 				inst_slti,
	input wire				inst_sltu,
	input wire				inst_sltiu,
	input wire				inst_mult,
	input wire				inst_multu,
	input wire              inst_div,
	input wire              inst_divu,
    input wire				inst_and,
	input wire 				inst_andi,
	input wire 				inst_lui ,
	input wire 				inst_nor ,
	input wire				inst_or,
	input wire 				inst_ori,
	input wire				inst_xor,
	input wire 				inst_xori,
	input wire 				inst_sll ,
	input wire              inst_sllv,
	input wire              inst_sra,
	input wire              inst_srav ,
	input wire              inst_srl ,
	input wire              inst_srlv ,
	input wire              inst_mfhi,
	input wire              inst_mflo,
	input wire              inst_mthi,
	input wire              inst_mtlo,
	input wire              inst_lb,
	input wire              inst_lbu,
	input wire              inst_lh,
	input wire              inst_lhu,
	input wire 				inst_lw,
    input wire 				inst_sb,
	input wire              inst_sh,
	input wire 				inst_sw,

	input wire 				inst_jal,
	input wire 				inst_j,
	input wire 				inst_jr,
	input wire  			inst_jalr,

	input wire 				inst_beq,
	input wire 				inst_bne,
	input wire            	inst_bgez,
	input wire             	inst_bgtz,
	input wire				inst_blez,
	input wire             	inst_bltz,
	input wire             	inst_bgezal,
	input wire            	inst_bltzal,
	input wire    			inst_mfc0,
	input wire 				inst_mtc0,	
	input wire 				inst_eret,

	input wire 				inst_syscall,
	input wire              inst_break,
	 
	input wire              equ,
	
	output wire[1:0] 		whilo,
	output wire			    wreg,
	output wire[2:0] 		alutype,
	output wire[7:0]		aluop,
	output wire 		    shift,
	output wire			    rreg1,
	output wire 		    rreg2,
	output wire			    immsel,
	output wire 		    rtsel,
	output wire			    sext,
	output wire 		    upper,
	output wire 		    mreg,
	output wire 		    jal,
	output wire[1:0]        jtsel,
	output wire             branchal,
	output wire[1:0]		rwc0,
	output wire  			next_delay,
	output wire             RI
);
assign RI = ~(`ALL_INST);
assign next_delay = `ALL_bne_INST | `ALL_jmp_INST ;
assign equ_in = (inst_beq == 1) ? equ :
				(inst_bne == 1) ? (~equ) : 1'b0;

assign rreg1 = inst_add  | inst_addi | inst_addu | inst_addiu | 
						inst_subu | inst_sub  | 
						inst_slt     | inst_slti   | inst_sltu    | inst_sltiu   | 
						inst_mult | inst_multu | inst_div   | inst_divu  |  
						inst_and | inst_andi | inst_nor | inst_or | inst_ori | inst_xor | inst_xori |
						inst_sllv | inst_srav | inst_srlv | 
						inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal |
						inst_jr |  inst_jalr |
						inst_mthi | inst_mtlo | 
						inst_lb | inst_lbu | inst_lh | inst_lhu |  inst_lw | inst_sb | inst_sh | inst_sw ;

assign rreg2 = inst_add | inst_addi | inst_addu | inst_addiu | 
						inst_subu | inst_sub |
						inst_slt | inst_sltu |
						inst_mult | inst_multu  | inst_div   | inst_divu  |  
						inst_and | inst_lui | inst_nor | inst_or | inst_xor | 
						inst_sllv | inst_sll | inst_srav | inst_sra | inst_srlv | inst_srl | 
						inst_beq | inst_bne | 
						inst_sb | inst_sh |  inst_sw |
						inst_mtc0;

//??????????????????????????????????????????????????? jal ????????? jr
assign wreg  = inst_add | inst_addi | inst_addu | inst_addiu | 
						inst_subu | inst_sub |
						inst_slt | inst_slti | inst_sltu | inst_sltiu | 
						inst_and | inst_andi | inst_lui | inst_nor | inst_or | inst_ori | inst_xor | inst_xori |
						inst_sll | inst_sllv | inst_srav | inst_sra | inst_srl | inst_srlv |
						inst_mfhi | inst_mflo | 
						inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw | 
						inst_bgezal | inst_bltzal | 
						inst_jal | inst_jalr |
						inst_mfc0;

assign whilo[1] = inst_mult | inst_multu | inst_div | inst_divu | inst_mthi;
assign whilo[0] = inst_mult | inst_multu | inst_div | inst_divu | inst_mtlo;

assign aluop[7] = inst_mfhi;
assign aluop[6:5] = (inst_mult  == 1) ? 2'b01 : 
					(inst_multu == 1) ? 2'b00 :
					(inst_div == 1	) ? 2'b11 :
					(inst_divu == 1	) ? 2'b10 : 2'b00 ;

assign aluop[4] = 	`ALL_xor_INST | inst_slt | inst_slti  | inst_lui | inst_mthi | inst_mtlo ;
assign aluop[3] = 	`ALL_and_INST | `ALL_or_INST | 
					inst_sub 	| inst_subu 	| inst_sltu 	| inst_sltiu	| 
					inst_sra  	| inst_srav  	| inst_srl 		| inst_srlv		| 
					inst_mthi 	| inst_mtlo;

assign aluop[2] = 	inst_nor	| `ALL_or_INST	| `ALL_add_INST	| `ALL_MEM_INST |
					inst_lui 	|
					inst_sltu 	| inst_sltiu 	| inst_sll 		| inst_sllv 	| 
					inst_srl 	| inst_srlv		| inst_mthi		| inst_mtlo; 
// ???????????? ??? ????????????
assign aluop[1] = 	`ALL_LOGIC_INST	| `ALL_SHIFT_INST	| inst_lui	| inst_mthi	| 
					inst_mtlo;
//???????????? ??? ???????????? 
assign aluop[0] = 	`ALL_LOGIC_INST | `ALL_ARITH_INST 	| `ALL_MEM_INST	|
					inst_lui		| inst_mthi 		| inst_mtlo;


//alutype[2] = shift + jump 
assign alutype[2] =`ALL_SHIFT_INST | inst_jal | inst_jalr | inst_bgezal | inst_bltzal ;
//alutype[1] = logic + move
assign alutype[1] = `ALL_LOGIC_INST | inst_mfhi | inst_mflo | inst_lui | inst_mthi | inst_mtlo | inst_mfc0;
//alutyep[0] = arith + move + jump + ?????? 
assign alutype[0] = `ALL_ARITH_INST | `ALL_MEM_INST | inst_jal | inst_jalr | inst_bgezal | inst_bltzal  | inst_mfhi | inst_mflo | inst_mfc0 ;

//???????????? sa ??????
assign shift  = inst_sll | inst_sra | inst_srl ;
//????????? i ????????? (BEQ ??? BNE ?????????)
assign immsel = `ALL_IMM_INST | `ALL_MEM_INST;
//??????????????? rt ?????????
assign rtsel     = `ALL_IMM_INST | `ALL_LMEM_INST | inst_mfc0 ;
//???????????????????????? (BEQ ??? BNE ?????????)
assign sext  = inst_addi | inst_addiu | inst_slti | inst_sltiu | `ALL_MEM_INST ; 
//upper ????????? lui 
assign upper  = inst_lui;
//????????????????????????????????????
assign mreg   = `ALL_LMEM_INST;


assign jal = inst_jal;

//?????????????????????  
/*  jtsel = 00 -> ?????????
	      = 01 -> ????????????1 J/JAL
		  = 10 -> ????????????3 JR/JALR
		  = 11 -> ????????????2 ???????????????
	?????????????????????????????? ????????????2 ??? ???????????? -> ??????????????? -> ???????????????PC 	
	?????????????????????????????????????????????????????????????????????????????????
*/
wire branch_enable;
assign branchal = inst_bgezal | inst_bltzal ;
assign branch_enable =  (inst_beq & equ_in) 	|	(inst_bne & (~equ)) 	|
						(inst_bgez & ($signed(reg_rs) >= 0)) |	(inst_bgtz & ($signed(reg_rs) > 0))  |  
						(inst_blez & ($signed(reg_rs) <= 0)) | 	(inst_bltz & ($signed(reg_rs) < 0))	|
						(inst_bgezal & ($signed(reg_rs) >= 0)) | (inst_bltzal & ($signed(reg_rs) < 0));

/*assign jtsel[0] = inst_j  | inst_jal | (inst_beq & equ_in ) | (inst_bne & (~equ));
assign jtsel[1] = inst_jr | (inst_beq & equ_in) | (inst_bne & (~equ));*/

assign jtsel[0] = inst_j  | inst_jal  | branch_enable;
assign jtsel[1] = inst_jr | inst_jalr | branch_enable;

assign rwc0[0] = inst_mfc0; //read;
assign rwc0[1] = inst_mtc0; //write;
endmodule