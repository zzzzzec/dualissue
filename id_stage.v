`include "defines.v"

module id_stage(
    input  wire                         clk,
    input  wire                         resetn,

    input wire[`INST_BUS    ]           iaddr1,
    input wire[`INST_BUS    ]           inst1,
    input wire[`REG_ADDR_BUS]           inst1_exe2id_wa,
	input wire                          inst1_exe2id_wreg,
    input wire                          inst1_exe2id_mreg,
	input wire[`REG_ADDR_BUS]           inst1_mem2id_wa,
	input wire                          inst1_mem2id_wreg,
    input wire                          inst1_mem2id_mreg,
    input wire                          inst1_wreg_i,
    input wire[`REG_ADDR_BUS]           inst1_wa_i,
    input wire[`WORD_BUS    ]           inst1_w2regdata_i,
    input wire[`REG_BUS     ]           inst1_exe2id_w2regdata,     //exe
    input wire[`REG_BUS     ]           inst1_mem2id_w2regdata,    //mem

    input wire[`INST_BUS    ]           iaddr2,
    input wire[`INST_BUS    ]           inst2,
    input wire[`REG_ADDR_BUS]           inst2_exe2id_wa,
	input wire                          inst2_exe2id_wreg,
    input wire                          inst2_exe2id_mreg,
	input wire[`REG_ADDR_BUS]           inst2_mem2id_wa,
	input wire                          inst2_mem2id_wreg,
    input wire                          inst2_mem2id_mreg,
    input wire                          inst2_wreg_i,
    input wire[`REG_ADDR_BUS]           inst2_wa_i,
    input wire[`WORD_BUS    ]           inst2_w2regdata_i,
    input wire[`REG_BUS     ]           inst2_exe2id_w2regdata,
    input wire[`REG_BUS     ]           inst2_mem2id_w2regdata,

    input wire[`EXC_CODE_BUS]           pc_exccode,

    output wire[7:0]                    inst1_DCU_memtype,
    output wire                         inst1_DCU_mreg,  
    output wire[1:0]                    inst1_DCU_whilo,
    output wire                         inst1_DCU_wreg,
    output wire[`ALUTYPE_BUS]           inst1_DCU_alutype,
    output wire[`ALUOP_BUS  ]           inst1_DCU_aluop,

    output wire[7:0]                    inst2_DCU_memtype,
    output wire                         inst2_DCU_mreg,  
    output wire[1:0]                    inst2_DCU_whilo,
    output wire                         inst2_DCU_wreg,
    output wire[`ALUTYPE_BUS]           inst2_DCU_alutype,
    output wire[`ALUOP_BUS  ]           inst2_DCU_aluop,

    output wire[`REG_ADDR_BUS]          inst1_wa_o,
    output wire[`REG_ADDR_BUS]          inst2_wa_o,

    output wire[`WORD_BUS   ]           inst1_src1_o,
    output wire[`WORD_BUS   ]           inst1_src2_o,
    output wire[`WORD_BUS   ]           inst2_src1_o,
    output wire[`WORD_BUS   ]           inst2_src2_o,

    output wire[`REG_BUS    ]           inst1_w2ramdata,
    output wire[`INST_BUS   ]           pc_plus8_o,
    output wire[1:0]                    DCU_jtsel,
    output wire[`INST_BUS   ]           jmp_addr1_o,
    output wire[`INST_BUS   ]           jmp_addr2_o,
    output wire[`INST_BUS   ]           jmp_addr3_o,
    output wire                         stallreq_id,   
    output wire[1:0]				    is_mthilo,
    output wire[1:0]                    rwc0,
    output wire[`REG_ADDR_BUS]          cp0addr,
    output wire                         ov_enable,
    output wire[`EXC_CODE_BUS]          id_exccode,
    output wire  					    next_delay,


    output wire                         instBuffer_re
    );


    wire[`REG_ADDR_BUS]          rs1;
    wire[`REG_ADDR_BUS]          rt1;
    wire[`REG_ADDR_BUS]          rd1;
    wire[`REG_ADDR_BUS]          sa1;
    wire[`HALF_WORD_BUS]        imm1;
    wire[`INST_INDEX_BUS]       instr_index1;

    assign rs1 = inst1[25:21];
    assign rt1 = inst1[20:16];
    assign rd1 = inst1[15:11];
    assign sa1 = inst1[10:6];
    assign imm1 = inst1[15:0];
    assign instr_index1 = inst1[25:0];


    wire[`REG_ADDR_BUS]          rs2;
    wire[`REG_ADDR_BUS]          rt2;
    wire[`REG_ADDR_BUS]          rd2;
    wire[`REG_ADDR_BUS]          sa2;
    wire[`HALF_WORD_BUS]        imm2;
    wire[`INST_INDEX_BUS]       instr_index2;

    assign rs2 = inst2[25:21];
    assign rt2 = inst2[20:16];
    assign rd2 = inst2[15:11];
    assign sa2 = inst2[10:6];
    assign imm2 = inst2[15:0];
    assign instr_index2 = inst2[25:0];

/*===================================*/
/*                         DCU                                          */
    wire[1:0]           inst1_DCU_fwrd1;
    wire[1:0]           inst1_DCU_fwrd2;
    wire                inst1_DCU_shift;
    wire                inst1_DCU_rreg1;
    wire                inst1_DCU_rreg2;
    wire                inst1_DCU_immsel;
    wire                inst1_DCU_rtsel;
    wire                inst1_DCU_sext;
    wire                inst1_DCU_upper;
    wire                inst1_DCU_jal;
    wire                inst1_DCU_branchal;

    wire[1:0]           inst2_DCU_fwrd1;
    wire[1:0]           inst2_DCU_fwrd2;
    wire                inst2_DCU_shift;
    wire                inst2_DCU_rreg1;
    wire                inst2_DCU_rreg2;
    wire                inst2_DCU_immsel;
    wire                inst2_DCU_rtsel;
    wire                inst2_DCU_sext;
    wire                inst2_DCU_upper;
    wire                inst2_DCU_jal;
    wire                inst2_DCU_branchal;
/*===================================*/
/*                          REG_FILE                                                   */
    wire[`REG_BUS]              regfile_inst1_rd1;
    wire[`REG_BUS]              regfile_inst1_rd2;
    wire[`REG_BUS]              regfile_inst2_rd1;
    wire[`REG_BUS]              regfile_inst2_rd2;
/*                           EXT                                           */
    wire [`WORD_BUS]            inst1_EXT_result;
    wire [`WORD_BUS]            inst2_EXT_result;

    wire [`REG_ADDR_BUS]        MUX_rtsel;
/*===================================*/


    
    wire                    equ_in;
    wire[`REG_BUS]          jmp_addr2_offset;
    wire[17:0]              imm_shift2;
    wire[27:0]              instr_index_shift2;


    //assign imm_inst1_shift2 = imm1 << 2;
    //assign instr_index_shift2 = instr_index << 2;
    //assign pc_plus8_o = pc_plus4_i + 4;

    /*
    assign jmp_addr2_offset = (imm_shift2[17] == 1) ? {{14{1'b1}}, (imm_shift2)} : {{14{1'b0}}, (imm_shift2)} ;
    assign jmp_addr1_o = { pc_plus4_i[31:28] , (instr_index_shift2) };
    assign jmp_addr2_o = (jmp_addr2_offset) + (pc_plus4_i); 
    assign jmp_addr3_o = src1_temp;
    assign equ_in = (src1_temp == src2_temp);
    */

    //assign MUX_rtsel =  (DCU_rtsel == 1) ?  rt :  rd;

    assign inst1_wa_o = (inst1_DCU_jal | inst1_DCU_branchal) ? 5'b11111 : 
                        (inst1_DCU_rtsel == 1              ) ?  rt1 : rd1;
    assign inst2_wa_o = (inst2_DCU_jal | inst2_DCU_branchal) ? 5'b11111 : 
                        (inst2_DCU_rtsel == 1              ) ?  rt2 : rd2;

// src1:
    assign inst1_src1_o =   (inst1_DCU_shift == 1    ) ?  {{27{1'b0}},sa1}   :  
                            (inst1_DCU_fwrd1 == 2'b01) ?  inst1_exe2id_w2regdata   :
                            (inst1_DCU_fwrd1 == 2'b10) ?  inst1_mem2id_w2regdata   :
                            (inst1_DCU_fwrd1 == 2'b11) ?  regfile_inst1_rd1       : `ZERO_WORD ;

    assign inst2_src1_o =   (inst2_DCU_shift == 1    ) ?  {{27{1'b0}},sa2}   :  
                            (inst2_DCU_fwrd1 == 2'b01) ?  inst2_exe2id_w2regdata   :
                            (inst2_DCU_fwrd1 == 2'b10) ?  inst2_mem2id_w2regdata   :
                            (inst2_DCU_fwrd1 == 2'b11) ?  regfile_inst2_rd1       : `ZERO_WORD ;

// src2:
    EXT EXT1(
                    .upper  (inst1_DCU_upper  ),
                    .sext   (inst1_DCU_sext   ),
                    .imm    (imm1),
                    .result (inst1_EXT_result)
    );
    EXT EXT2(
                    .upper  (inst2_DCU_upper  ),
                    .sext   (inst2_DCU_sext   ),
                    .imm    (imm2),
                    .result (inst2_EXT_result)
    );

    assign inst1_src2_o =   (inst1_DCU_immsel == 1   ) ? (inst1_EXT_result) :
                            (inst1_DCU_fwrd2 == 2'b01) ? inst1_exe2id_w2regdata :
                            (inst1_DCU_fwrd2 == 2'b10) ? inst1_mem2id_w2regdata :
                            (inst1_DCU_fwrd2 == 2'b11) ? regfile_inst1_rd2 : `ZERO_WORD ;

    assign inst2_src2_o =   (inst2_DCU_immsel == 1   ) ? (inst2_EXT_result) :
                            (inst2_DCU_fwrd2 == 2'b01) ? inst2_exe2id_w2regdata :
                            (inst2_DCU_fwrd2 == 2'b10) ? inst2_mem2id_w2regdata :
                            (inst2_DCU_fwrd2 == 2'b11) ? regfile_inst2_rd2 : `ZERO_WORD ;
    
    assign inst1_w2ramdata = (inst1_DCU_fwrd2 == 2'b01) ? inst1_exe2id_w2regdata :
                             (inst1_DCU_fwrd2 == 2'b10) ? inst1_mem2id_w2regdata :
                             (inst1_DCU_fwrd2 == 2'b11) ? regfile_inst1_rd2 : `ZERO_WORD ;

    //assign inst2_w2ramdata = (inst2_DCU_fwrd2 == 2'b01) ? inst1_exe2id_w2regdata :
    //                         (inst2_DCU_fwrd2 == 2'b10) ? inst1_mem2id_w2regdata :
    //                         (inst2_DCU_fwrd2 == 2'b11) ? regfile_inst1_rd2 : `ZERO_WORD ;


    wire [`EXC_CODE_BUS] id_exccode_tmp;
    assign id_exccode = (pc_exccode == `EXC_NONE) ? id_exccode_tmp : pc_exccode;
    assign cp0addr = rd1;


    DCU DCU1(
        .resetn             (resetn                     ),
        .exe2id_wa          (inst1_exe2id_wa            ),
        .exe2id_wreg        (inst1_exe2id_wreg          ),
        .exe2id_mreg        (inst1_exe2id_mreg          ),
        .mem2id_wa          (inst1_mem2id_wa            ),
        .mem2id_wreg        (inst1_mem2id_wreg          ),
        .mem2id_mreg        (inst1_mem2id_mreg          ),
        .reg_rs             (inst1_src1_o               ),
        .rs                 (rs1                        ),
        .rt                 (rt1                        ),
        .op                 (inst1[31:26]               ),
        .func               (inst1[5:0]                 ),
        .equ                (equ_in                     ),

        .memtype            (inst1_DCU_memtype          ),
        .fwrd2              (inst1_DCU_fwrd2            ),
        .fwrd1              (inst1_DCU_fwrd1            ),
 		.whilo              (inst1_DCU_whilo            ),
		.wreg               (inst1_DCU_wreg             ),
	    .alutype            (inst1_DCU_alutype          ),
	    .aluop              (inst1_DCU_aluop            ),
		.shift              (inst1_DCU_shift            ),
		.rreg1              (inst1_DCU_rreg1            ),
		.rreg2              (inst1_DCU_rreg2            ),
		.immsel             (inst1_DCU_immsel           ),
		.rtsel              (inst1_DCU_rtsel            ),
		.sext               (inst1_DCU_sext             ),
		.upper              (inst1_DCU_upper            ),
		.mreg               (inst1_DCU_mreg             ),
        .jal                (inst1_DCU_jal              ),
        .branchal           (inst1_DCU_branchal         ),
        .jtsel              (inst1_DCU_jtsel            ),
        .stallreq_id        (        ),
        .is_mthilo          (is_mthilo                  ),
        .rwc0               (rwc0                       ),
        .ov_enable          (ov_enable                  ),
        .id_exccode         (id_exccode_tmp             ),
        .next_delay         (next_delay                 )
	);  


    DCU DCU2(
        .resetn             (resetn                     ),
        .exe2id_wa          (inst2_exe2id_wa            ),
        .exe2id_wreg        (inst2_exe2id_wreg          ),
        .exe2id_mreg        (inst2_exe2id_mreg          ),
        .mem2id_wa          (inst2_mem2id_wa            ),
        .mem2id_wreg        (inst2_mem2id_wreg          ),
        .mem2id_mreg        (inst2_mem2id_mreg          ),
        .reg_rs             (inst2_src1_o               ),
        .rs                 (rs2                        ),
        .rt                 (rt2                        ),
        .op                 (inst2[31:26]               ),
        .func               (inst2[5:0]                 ),
        .equ                (                           ),

        .memtype            (inst2_DCU_memtype          ),
        .fwrd2              (inst2_DCU_fwrd2            ),
        .fwrd1              (inst2_DCU_fwrd1            ),
 		.whilo              (inst2_DCU_whilo            ),
		.wreg               (inst2_DCU_wreg             ),
	    .alutype            (inst2_DCU_alutype          ),
	    .aluop              (inst2_DCU_aluop            ),
		.shift              (inst2_DCU_shift            ),
		.rreg1              (inst2_DCU_rreg1            ),
		.rreg2              (inst2_DCU_rreg2            ),
		.immsel             (inst2_DCU_immsel           ),
		.rtsel              (inst2_DCU_rtsel            ),
		.sext               (inst2_DCU_sext             ),
		.upper              (inst2_DCU_upper            ),
		.mreg               (inst2_DCU_mreg             ),
        .jal                (inst2_DCU_jal              ),
        .branchal           (inst2_DCU_branchal         ),
        .jtsel              (inst2_DCU_jtsel            ),

        .stallreq_id        (                           ),
        .is_mthilo          (                           ),
        .rwc0               (                           ),
        .ov_enable          (                           ),
        .id_exccode         (                           ),
        .next_delay         (                           )
	);

    regfile regfile0(
        .clk                    (clk                    ),
        .resetn                 (resetn                 ),
        .inst1_we               (inst1_wreg_i           ),
        .inst1_wa               (inst1_wa_i             ),
        .inst1_w2regdata        (inst1_w2regdata_i      ),  
        .inst1_re1              (inst1_DCU_rreg1        ),
        .inst1_re2              (inst1_DCU_rreg2        ), 
        .inst1_ra1              (rs1                    ),
        .inst1_ra2              (rt1                    ), 
        .inst1_rd1              (regfile_inst1_rd1      ),
        .inst1_rd2              (regfile_inst1_rd2      ),

        .inst2_we               (inst2_wreg_i           ),
        .inst2_wa               (inst2_wa_i             ),
        .inst2_w2regdata        (inst2_w2regdata_i      ),  
        .inst2_re1              (inst2_DCU_rreg1        ),
        .inst2_re2              (inst2_DCU_rreg2        ), 
        .inst2_ra1              (rs2                    ),
        .inst2_ra2              (rt2                    ), 
        .inst2_rd1              (regfile_inst2_rd1      ),
        .inst2_rd2              (regfile_inst2_rd2      )
    );
endmodule
