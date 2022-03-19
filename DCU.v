`include "defines.v"
`timescale 1ns / 1ps
`define SRC1_EXE_RELATIVE     		((exe2id_mreg == `TRUE_V) && (rreg1 == `TRUE_V) && (rs == exe2id_wa) && (exe2id_mreg ==`TRUE_V))
`define SRC1_MEM_RELATIVE 	      	((mem2id_mreg == `TRUE_V) && (rreg1 == `TRUE_V) && (rs == mem2id_wa) && (mem2id_mreg == `TRUE_V))
`define SRC2_EXE_RELATIVE  			((exe2id_mreg == `TRUE_V) && (rreg2 == `TRUE_V) && (rt == exe2id_wa) && (exe2id_mreg == `TRUE_V))
`define SRC2_MEM_RELATIVE         	((mem2id_mreg == `TRUE_V) && (rreg2 == `TRUE_V) && (rt == mem2id_wa) && (mem2id_mreg == `TRUE_V))
module DCU(
	input  wire   					resetn,

	input wire [`REG_ADDR_BUS]		inst1_exe2id_wa,
	input wire						inst1_exe2id_wreg,
	input wire [`REG_ADDR_BUS] 		inst1_mem2id_wa,
	input wire 						inst1_mem2id_wreg,

	input wire [`REG_ADDR_BUS]		inst2_exe2id_wa,
	input wire						inst2_exe2id_wreg,
	input wire [`REG_ADDR_BUS] 		inst2_mem2id_wa,
	input wire 						inst2_mem2id_wreg,

	input wire[`REG_BUS]			reg_rs,
	input wire[`REG_ADDR_BUS]  		rs,
	input wire[`REG_ADDR_BUS] 		rt, 
	input wire[5:0]					op,
	input wire[5:0]					func,
	input wire  		  			equ,

    output wire[7:0]               	memtype,
	output wire[`DUC_fwrd_BUS] 		fwrd2,
	output wire[`DUC_fwrd_BUS]		fwrd1,
	output wire[1:0] 		    	whilo,
	output wire						wreg,
	output wire[2:0] 				alutype,
	output wire[7:0]				aluop,
	output wire 					shift,
	output wire	    				rreg1,
	output wire 					rreg2,
	output wire						immsel,
	output wire 					rtsel,
	output wire						sext,
	output wire 					upper,
	output wire 					mreg,
	output wire 					jal,
	output wire                     branchal,
	output wire[1:0]  				jtsel,
	output wire         			stallreq_id,
	output wire[1:0]				is_mthilo,
	output wire[1:0]				rwc0,
	output wire						ov_enable,
	output wire[`EXC_CODE_BUS]		id_exccode,
	output wire  					next_delay,
	
	output wire 					issue_mult_div,
	output wire  					issue_jmp_branch,
	output wire 					issue_load_store
);

wire 			inst_add_out;
wire            inst_addi_out;
wire         	inst_addu_out;
wire            inst_addiu_out;
wire            inst_sub_out;
wire 			inst_subu_out;
wire 			inst_slt_out;
wire 			inst_slti_out;
wire			inst_sltu_out;
wire			inst_sltiu_out;
wire			inst_mult_out;
wire			inst_multu_out;
wire            inst_div_out;
wire  			inst_divu_out;
wire			inst_and_out;
wire 			inst_andi_out;
wire 			inst_lui_out;
wire 			inst_nor_out;
wire			inst_or_out;
wire 			inst_ori_out;
wire			inst_xor_out;
wire 			inst_xori_out;
wire 			inst_sll_out;
wire            inst_sllv_out;
wire            inst_sra_out;
wire            inst_srav_out;
wire            inst_srl_out;
wire            inst_srlv_out;
wire            inst_mfhi_out;
wire            inst_mflo_out;
wire            inst_mthi_out;
wire            inst_mtlo_out;
wire            inst_lb_out;
wire            inst_lbu_out;
wire            inst_lh_out;
wire            inst_lhu_out;
wire 			inst_lw_out;
wire 			inst_sb_out;
wire            inst_sh_out;
wire 			inst_sw_out;
wire 			inst_jal_out;
wire 			inst_j_out;
wire 			inst_jr_out;
wire   			inst_jalr_out;

wire 			inst_beq_out;
wire 			inst_bne_out;
wire            inst_bgez_out;
wire            inst_bgtz_out;
wire			inst_blez_out;
wire            inst_bltz_out;
wire            inst_bgezal_out;
wire            inst_bltzal_out;

wire  			inst_mfc0_out;
wire        	inst_mtc0_out;

wire 			inst_syscall_out;
wire    		inst_eret_out;
wire     		inst_break_out;

wire  			RI;
assign is_mthilo = 	{inst_mthi_out,inst_mtlo_out};
assign ov_enable =	{inst_add_out | inst_addi_out | inst_sub_out};
assign id_exccode = (inst_syscall_out) ? `EXC_SYS   :
					(inst_eret_out	 ) ? `EXC_ERET  :
					(inst_break_out  ) ? `EXC_BREAK : 
					(RI				 ) ? `EXC_RI	:`EXC_NONE;  

					
DCU_step1 DCU_step10(
	.op         (op         	),
	.func       (func       	),
	.rt 		(rt				),
	.rs 		(rs				),
	.inst_add   (inst_add_out   ),
	.inst_addi  (inst_addi_out  ),
	.inst_addu  (inst_addu_out  ),
	.inst_addiu (inst_addiu_out ),
	.inst_sub   (inst_sub_out   ),
	.inst_subu  (inst_subu_out  ),
	.inst_slt   (inst_slt_out   ),
	.inst_slti  (inst_slti_out  ),
	.inst_sltu  (inst_sltu_out  ),
	.inst_sltiu (inst_sltiu_out ),

	.inst_mult  (inst_mult_out  ),
	.inst_multu (inst_multu_out ),
	.inst_div   (inst_div_out	),
	.inst_divu  (inst_divu_out	),

	.inst_and   (inst_and_out   ),
	.inst_andi  (inst_andi_out  ),
	.inst_lui   (inst_lui_out   ),
	.inst_nor   (inst_nor_out   ),
	.inst_or    (inst_or_out    ),
	.inst_ori   (inst_ori_out   ),
	.inst_xor   (inst_xor_out   ),
	.inst_xori  (inst_xori_out  ),

	.inst_sll   (inst_sll_out   ),
	.inst_sllv  (inst_sllv_out  ),
	.inst_sra   (inst_sra_out   ),
	.inst_srav  (inst_srav_out  ),
	.inst_srl   (inst_srl_out   ),
	.inst_srlv  (inst_srlv_out  ),

	.inst_mfhi  (inst_mfhi_out  ),
	.inst_mflo  (inst_mflo_out  ),
	.inst_mthi  (inst_mthi_out  ),
	.inst_mtlo  (inst_mtlo_out  ),

	.inst_lb    (inst_lb_out    ),
	.inst_lbu   (inst_lbu_out  	),
	.inst_lh    (inst_lh_out    ),
	.inst_lhu   (inst_lhu_out   ),
	.inst_lw    (inst_lw_out    ),
	.inst_sb    (inst_sb_out    ),
	.inst_sh    (inst_sh_out    ),
	.inst_sw    (inst_sw_out    ),

	.inst_jal   (inst_jal_out   ),
	.inst_j     (inst_j_out     ),
	.inst_jr    (inst_jr_out    ),
	.inst_jalr 	(inst_jalr_out	),

	.inst_beq   (inst_beq_out   ),
	.inst_bne   (inst_bne_out   ),
    .inst_bgez  (inst_bgez_out	),
   	.inst_bgtz	(inst_bgtz_out	),
  	.inst_blez	(inst_blez_out	),
	.inst_bltz	(inst_bltz_out	),
	.inst_bgezal(inst_bgezal_out),
	.inst_bltzal(inst_bltzal_out),

	.inst_mfc0  (inst_mfc0_out	),
    .inst_mtc0  (inst_mtc0_out	),
	.inst_eret	(inst_eret_out	),

	.inst_syscall(inst_syscall_out),
	.inst_break (inst_break_out	)
);


DCU_step2 DCU_step20(
	.reg_rs		(reg_rs			),
	.inst_add   (inst_add_out   ),
	.inst_addi  (inst_addi_out  ),
	.inst_addu  (inst_addu_out  ),
	.inst_addiu (inst_addiu_out ),
	.inst_sub   (inst_sub_out   ),
	.inst_subu  (inst_subu_out  ),
	.inst_slt   (inst_slt_out   ),
	.inst_slti  (inst_slti_out  ),
	.inst_sltu  (inst_sltu_out  ),
	.inst_sltiu (inst_sltiu_out ),
	.inst_mult  (inst_mult_out  ),
	.inst_multu (inst_multu_out ),
	.inst_div  	(inst_div_out	),
	.inst_divu  (inst_divu_out	),
	.inst_and   (inst_and_out   ),
	.inst_andi  (inst_andi_out  ),
	.inst_lui   (inst_lui_out   ),
	.inst_nor   (inst_nor_out   ),
	.inst_or    (inst_or_out    ),
	.inst_ori   (inst_ori_out   ),
	.inst_xor   (inst_xor_out   ),
	.inst_xori  (inst_xori_out  ),
	.inst_sll   (inst_sll_out   ),
	.inst_sllv  (inst_sllv_out  ),
	.inst_sra   (inst_sra_out   ),
	.inst_srav  (inst_srav_out  ),
	.inst_srl   (inst_srl_out   ),
	.inst_srlv  (inst_srlv_out  ),
	.inst_mfhi  (inst_mfhi_out  ),
	.inst_mflo  (inst_mflo_out  ),
	.inst_mthi  (inst_mthi_out  ),
	.inst_mtlo  (inst_mtlo_out  ),
	.inst_lb    (inst_lb_out    ),
	.inst_lbu   (inst_lbu_out  	),
	.inst_lh    (inst_lh_out    ),
	.inst_lhu   (inst_lhu_out   ),
	.inst_lw    (inst_lw_out    ),
	.inst_sb    (inst_sb_out    ),
	.inst_sh    (inst_sh_out    ),
	.inst_sw    (inst_sw_out    ),

	.inst_jal   (inst_jal_out   ),
	.inst_j     (inst_j_out     ),
	.inst_jr    (inst_jr_out    ),
	.inst_jalr  (inst_jalr_out	),

	.inst_beq   (inst_beq_out   ),
	.inst_bne   (inst_bne_out   ),
    .inst_bgez  (inst_bgez_out	),
   	.inst_bgtz	(inst_bgtz_out	),
  	.inst_blez	(inst_blez_out	),
	.inst_bltz	(inst_bltz_out	),
	.inst_bgezal(inst_bgezal_out),
	.inst_bltzal(inst_bltzal_out),

	.inst_mfc0  (inst_mfc0_out	),
    .inst_mtc0  (inst_mtc0_out	),
	.inst_syscall(inst_syscall_out),
	.inst_eret	(inst_eret_out	),
	.inst_break (inst_break_out	), 

	.equ		(equ			),
    .whilo		(whilo			),
	.wreg		(wreg			),
	.alutype	(alutype		),
	.aluop		(aluop			),
    .shift		(shift			),
	.rreg1		(rreg1			),
	.rreg2		(rreg2			),
    .immsel		(immsel			),
    .rtsel		(rtsel			),
    .sext		(sext			),
    .upper		(upper			),
    .mreg		(mreg			),
	.jal		(jal			),
	.jtsel		(jtsel			),
	.branchal 	(branchal		),
	.rwc0 		(rwc0			),
	.next_delay (next_delay		),
	.RI 		(RI				)
	);

	// rule: 1. wb > mem > exe
	//       2. inst2 > inst1
	// choose from inst1_exe, inst2_exe, inst1_mem, inst2_mem, reg 			
	//读寄存器端口1可能的数据来源

	assign fwrd1 =	(inst2_mem2id_wreg == `WRITE_ENABLE  && inst2_mem2id_wa == rs && rreg1 == `READ_ENABLE  && inst2_mem2id_wa != 0 ) ? `DCU_fwrd_inst2_mem :
				 	(inst1_mem2id_wreg == `WRITE_ENABLE  && inst1_mem2id_wa == rs && rreg1 == `READ_ENABLE  && inst1_mem2id_wa != 0 ) ? `DCU_fwrd_inst1_mem :
					(inst2_exe2id_wreg == `WRITE_ENABLE  && inst2_exe2id_wa == rs && rreg1 == `READ_ENABLE  && inst2_exe2id_wa != 0 ) ? `DCU_fwrd_inst2_exe :
					(inst1_exe2id_wreg == `WRITE_ENABLE  && inst1_exe2id_wa == rs && rreg1 == `READ_ENABLE  && inst1_exe2id_wa != 0 ) ? `DCU_fwrd_inst1_exe :
					(rreg1 == `READ_ENABLE) ?  `DCU_fwrd_no : 0;   

	assign fwrd2 =	(inst2_mem2id_wreg == `WRITE_ENABLE  && inst2_mem2id_wa == rs && rreg2 == `READ_ENABLE  && inst2_mem2id_wa != 0 ) ? `DCU_fwrd_inst2_mem :
				 	(inst1_mem2id_wreg == `WRITE_ENABLE  && inst1_mem2id_wa == rs && rreg2 == `READ_ENABLE  && inst1_mem2id_wa != 0 ) ? `DCU_fwrd_inst1_mem :
					(inst2_exe2id_wreg == `WRITE_ENABLE  && inst2_exe2id_wa == rs && rreg2 == `READ_ENABLE  && inst2_exe2id_wa != 0 ) ? `DCU_fwrd_inst2_exe :
					(inst1_exe2id_wreg == `WRITE_ENABLE  && inst1_exe2id_wa == rs && rreg2 == `READ_ENABLE  && inst1_exe2id_wa != 0 ) ? `DCU_fwrd_inst1_exe :
					(rreg2 == `READ_ENABLE) ?  `DCU_fwrd_no : 0;   

	//assign stallreq_id = 			(resetn == `RST_ENABLE) ?  `PIPELINE_NOSTOP :
	//								 (`SRC1_EXE_RELATIVE || `SRC1_MEM_RELATIVE || `SRC2_EXE_RELATIVE || `SRC2_MEM_RELATIVE) ? 
	//								 `PIPELINE_STOP : `PIPELINE_NOSTOP;

	assign memtype = { inst_sw_out,inst_sh_out,inst_sb_out,inst_lw_out,inst_lhu_out,inst_lh_out,inst_lbu_out,inst_lb_out };
	
	assign issue_mult_div 	= 	inst_mult_out | inst_multu_out | inst_div_out | inst_divu_out;

	assign issue_jmp_branch = 	inst_j_out | inst_jal_out | inst_jr_out | inst_jalr_out |
								inst_beq_out | inst_bne_out | inst_bgez_out | inst_bgtz_out | inst_blez_out |
							 	inst_bltz_out | inst_bgezal_out | inst_bltzal_out;
								 
	assign issue_load_store = 	inst_lb_out | inst_lbu_out | inst_lh_out | inst_lhu_out | inst_lw_out |
								inst_sb_out | inst_sh_out  | inst_sw_out;
endmodule	
