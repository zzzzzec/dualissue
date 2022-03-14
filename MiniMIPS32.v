`include "defines.v"


module MiniMIPS32(
    input wire    clk,
    input wire    resetn,

    output wire [`INST_ADDR_BUS]    iaddr, 
    output wire                     ice,
    input  wire [`INST_BUS]         inst,

    input  wire [`WORD_BUS]         dout,
    output wire                     dce,
    output wire [`INST_ADDR_BUS]    daddr,
    output wire [`BSEL_BUS]         we,
    output wire [`WORD_BUS]         din,


    input wire                      int,

    output wire [`INST_BUS]         debug_wb_pc,
    output wire [`BSEL_BUS]         debug_wb_rf_wen,
    output wire [`REG_ADDR_BUS]     debug_wb_rf_wnum,
    output wire [`WORD_BUS]         debug_wb_rf_wdata
);

 /*===================================*/
 /*                  if                                                    */
    wire [`INST_BUS]          if_pcplus4;
    wire [`INST_BUS]          if_pc;
    wire [`EXC_CODE_BUS]      if_pc_exccode;
 /*===================================
    wire [`INST_BUS]            ifid_inst_o;

`ifdef CONVERSE_INST
    wire [`INST_BUS]            ifid_inst = {ifid_inst_o[7:0],
                                            ifid_inst_o[15:8], 
                                            ifid_inst_o[23:16], 
                                            ifid_inst_o[31:24]};
`else 
    wire [`INST_BUS]            ifid_inst = ifid_inst_o;
`endif 

    wire [`INST_BUS]            ifid_pcplus4;
    wire [`INST_BUS]            ifid_pc;
    wire [`EXC_CODE_BUS]        ifid_pc_exccode; 
*/

/*===================    instBuffer   ================*/
    wire [`INST_BUS]            instBuffer_inst1;
    wire [`INST_BUS]            instBuffer_inst2;
    wire [`INST_ADDR_BUS]       instBuffer_iaddr1;
    wire [`INST_ADDR_BUS]       instBuffer_iaddr2;

    wire                        instBuffer_bufferFull;
/*===================================*/
/*                                        id_stage����ź�                     */    
    wire[7:0]                   id_inst1_DCU_memtype;
    wire                        id_inst1_DCU_mreg;
    wire[1:0]                   id_inst1_DCU_whilo;
    wire                        id_inst1_DCU_wreg;
    wire [`ALUTYPE_BUS]         id_inst1_DCU_alutype;
    wire [`ALUOP_BUS]           id_inst1_DCU_aluop;

    wire[7:0]                   id_inst2_DCU_memtype;
    wire                        id_inst2_DCU_mreg;
    wire[1:0]                   id_inst2_DCU_whilo;
    wire                        id_inst2_DCU_wreg;
    wire [`ALUTYPE_BUS]         id_inst2_DCU_alutype;
    wire [`ALUOP_BUS]           id_inst2_DCU_aluop;

    wire [`REG_ADDR_BUS]        id_MUX_writeaddr;
    wire [`WORD_BUS]            id_MUX_shift_o;
    wire [`WORD_BUS]            id_MUX_immsel_o;
    wire [`REG_BUS]             id_din;
    wire [`INST_BUS]            id_pc_plus8_o;
    wire [1:0]                  id_jtsel;
    wire [`INST_BUS]            id_jmp_addr1_o;
    wire [`INST_BUS]            id_jmp_addr2_o;
    wire [`INST_BUS]            id_jmp_addr3_o;
    wire                        id_stallreq_id;
    wire [1:0]                  id_is_mthilo;
    wire [1:0]                  id_rwc0;
    wire [`REG_ADDR_BUS]        id_cp0addr;
    wire                        id_ov_enable;
    wire [`EXC_CODE_BUS]        id_exccode;
    wire                        id_next_delay;
/*===================================*/
/*                         idexe_reg����ź�                                  */
    wire [`INST_BUS]            idexe_pc;
    wire [7:0]                  idexe_memtype;
    wire                       	idexe_mreg;
    wire [1:0]                  idexe_whilo;
    wire                        idexe_wreg;
    wire [`ALUTYPE_BUS]     	idexe_alutype;
    wire [`ALUOP_BUS]        	idexe_aluop;
    wire [`REG_ADDR_BUS]        idexe_wa;
    wire [`REG_BUS]        		idexe_src1;
    wire [`REG_BUS]        		idexe_src2;
    wire [`REG_BUS]             idexe_din;
    wire [`INST_BUS]            idexe_pcPlus8;
    wire [1:0]                  idexe_is_mthilo;
    wire [1:0]                  idexe_rwc0;
    wire [`REG_ADDR_BUS]        idexe_cp0addr;
    wire                        idexe_ov_enable;
    wire [`EXC_CODE_BUS]        idexe_id_exccode;
    wire                        idexe_next_delay;
    wire                        idexe_id_in_delay;
/*===================================*/
/*                         exe_stage ����ź�                                 */
    wire [7:0]                  exe_memtype; 
    wire                        exe_mreg;
    wire [1:0]                  exe_whilo;
    wire                        exe_wreg;
    wire [`ALUOP_BUS	    ] 	exe_aluop;
    wire [`REG_ADDR_BUS 	] 	exe_wa;
    wire [`DOUBLE_WORD_BUS] 	exe_mulres;
    wire [`WORD_BUS]            exe_alu_result;
    wire [`REG_BUS]             exe_din;
    wire                        exe_stallreq_exe;
    wire [`EXC_CODE_BUS]        exe_exccode;

/*===================================*/
/*                        exemem_reg����ź�                               */
    wire [`INST_BUS]            exemem_pc;
    wire[7:0]                   exemem_memtype;
    wire                        exemem_mreg;
    wire [1:0]                  exemem_whilo;
    wire                        exemem_wreg;
    wire [`ALUOP_BUS]   		exemem_aluop;
    wire [`REG_ADDR_BUS]    	exemem_wa;
    wire [`DOUBLE_WORD_BUS] 	exemem_mulres;
    wire [`WORD_BUS]    		exemem_wd;
    wire [`REG_BUS]           	exemem_din;
    wire [1:0]                  exemem_is_mthilo;
    wire                        exemem_wc0;
    wire [`REG_ADDR_BUS]        exemem_cp0addr;
    wire [`WORD_BUS     ]       exemem_cp0wdata;
    wire [`EXC_CODE_BUS ]       exemem_exe_exccode;
    wire                        exemem_exe_in_delay;

/*===================================*/
/*                           memstage����ź�                               */
    wire [7:0]                  mem_memtype;
    wire                      	mem_mreg;
    wire [1:0]                  mem_whilo;
    wire                      	mem_wreg;
    wire [`BSEL_BUS ]      		mem_dre;
    wire [`REG_ADDR_BUS  ]      mem_wa;
    wire [`DOUBLE_REG_BUS ]     mem_hilo;
    wire [`REG_BUS ]           	mem_dreg;
    wire [`REG_BUS]             mem_din;
	wire [`BSEL_BUS]			mem_we;
    wire [`EXC_CODE_BUS  ]      mem_cp0exccode;
    wire [`WORD_BUS      ]      mem_badaddr;
    wire [`WORD_BUS      ]      mem_daddr;

    assign daddr = mem_daddr; 
/*===================================*/
/*                        memwb_reg����ź�                               */
    wire [`INST_BUS]            memwb_pc;
    wire [7:0]                  memwb_memtype;
    wire                        memwb_mreg;
    wire [1:0]                  memwb_whilo;
    wire                        memwb_wreg;
    wire [`REG_ADDR_BUS]     	memwb_wa;
    wire [`WORD_BUS]            memwb_dreg;
    wire [`DOUBLE_WORD_BUS] 	memwb_hilo;
    wire [`BSEL_BUS]            memwb_dre;
	wire [`BSEL_BUS]			memwb_we;
    wire [1:0]                  memwb_is_mthilo;
    wire                        memwb_wc0;
    wire [`REG_ADDR_BUS]        memwb_cp0addr;
    wire [`WORD_BUS     ]       memwb_cp0wdata;
    wire [`WORD_BUS     ]       memwb_daddr;
/*===================================*/
/*                        wb_stage����ź�                               */
    wire [1:0]                  wb_whilo;
    wire                        wb_wreg;
    wire [`REG_ADDR_BUS  ] 		wb_wa;
    wire [`DOUBLE_REG_BUS] 		wb_hilo;
    wire [`WORD_BUS      ]    	wb_wd;
/*==================================*/
/*                       HILO����ź�                                          */
    wire [`DOUBLE_WORD_BUS]     HILO_hilo_o;
/*==================================*/
/*                          SCU����ź�                                          */
    wire [`STALL_BUS]           SCU_stall;
/*==================================*/
/*                          CP0                                                     */
    wire [`REG_BUS]             cp0_rdata;
    wire [`REG_BUS]             cp0_cause_o;    
    wire [`REG_BUS]             cp0_status_o;
    wire                        cp0_flush;
    wire [`WORD_BUS]            cp0_excaddr;

	assign debug_wb_pc = memwb_pc;
	assign debug_wb_rf_wdata = wb_wd;
	assign debug_wb_rf_wnum = wb_wa;
	assign debug_wb_rf_wen = (wb_wreg == 1)?{4'b1111}:{4'b0000};

    if_stage if_stage0(
		.clk		        (clk    ),
        .resetn			    (resetn      ),
        .jtsel_i			(0),//(id_jtsel       ),
        .jmp_addr1_i		(0),//(id_jmp_addr1_o ),
        .jmp_addr2_i		(0),//(id_jmp_addr2_o ),
        .jmp_addr3_i		(0),//(id_jmp_addr3_o ),
        .stall				(0),//(SCU_stall      ),
        .flush              (0),//(cp0_flush      ),
        .cp0_excaddr        (0),//(cp0_excaddr    ),

        .instBufferFull     (instBuffer_bufferFull),

        .ice				(ice            ),
        .pc_plus4_o			(if_pcplus4     ),
        .iaddr				(iaddr          ),
        .pc_o				(if_pc          ),
        .pc_exccode         (if_pc_exccode  )
     );
 
    //  ifid_reg ifid_reg0(
	//  	.clk		(clk    ),	
    //      .resetn			(resetn      ),
    //      .if_pcPlus4			(if_pcplus4     ),
    //      .inst_in			(inst           ),
    //      .stall				(SCU_stall      ),
    //      .flush              (cp0_flush      ),
    //      .pc_i				(if_pc          ),
    //      .pc_exccode_i       (if_pc_exccode  ),
    //  
    //    .inst				(ifid_inst_o    ),
    //    .ifid_pcPlus4		(ifid_pcplus4   ),
    //    .pc_o				(ifid_pc        ),
    //    .pc_exccode_o       (ifid_pc_exccode)
    //);


    // addr must wait for addr one cycle
    reg [31:0] wait_iaddr;
    always@(posedge clk) begin
        if(resetn == `RST_ENABLE) begin
            wait_iaddr <= 0;
        end
        else begin
            wait_iaddr <= iaddr;
        end
    end
    instBuffer instBuffer0(
        .clk                    (clk),
        .resetn                 (resetn),
        .flush                  (0),
        .inst_i                  (inst),
        .iaddr_i                 (wait_iaddr),
        
        .re                     (1),
        .we                     (1),

        .inst1                  (instBuffer_inst1),
        .inst2                  (instBuffer_inst2),
        .iaddr1                 (instBuffer_iaddr1),
        .iaddr2                 (instBuffer_iaddr2),

        .instBufferFull         (instBuffer_bufferFull)
    );

    id_stage id_stage0(
    	.clk   	                    (clk            ),
        .resetn         	        (resetn         ),

        .iaddr1        	            (instBuffer_iaddr1   ),
        .inst1                      (instBuffer_inst1    ),
        .inst1_exe2id_wa        	(idexe_wa       ),
	    .inst1_exe2id_wreg          (idexe_wreg     ),
        .inst1_exe2id_mreg          (idexe_mreg     ),
	    .inst1_mem2id_wa      	    (exemem_wa      ),
	    .inst1_mem2id_wreg    	    (exemem_wreg    ),
        .inst1_mem2id_mreg    	    (exemem_mreg    ),
        .inst1_wreg_i               (wb_wreg        ),
        .inst1_wa_i                 (wb_wa          ),
        .inst1_wd_i                 (wb_wd          ),
        .inst1_exe2id_wd            (exe_alu_result ),
        .inst1_mem2id_wd            (exemem_wd      ),

        .iaddr2        	            (instBuffer_iaddr2   ),
        .inst2                      (instBuffer_inst2     ),
        .inst2_exe2id_wa        	(),
	    .inst2_exe2id_wreg          (),
        .inst2_exe2id_mreg          (),
	    .inst2_mem2id_wa      	    (),
	    .inst2_mem2id_wreg    	    (),
        .inst2_mem2id_mreg    	    (),
        .inst2_wreg_i               (),
        .inst2_wa_i                 (),
        .inst2_wd_i                 (),
        .inst2_exe2id_wd            (),
        .inst2_mem2id_wd            (),




        .pc_exccode         (ifid_pc_exccode),

        .inst1_DCU_memtype 		(id_inst1_DCU_memtype ),
        .inst1_DCU_mreg   		(id_inst1_DCU_mreg  ),
        .inst1_DCU_whilo 		(id_inst1_DCU_whilo ),
        .inst1_DCU_wreg  		(id_inst1_DCU_wreg),
        .inst1_DCU_alutype		(id_inst1_DCU_alutype),
        .inst1_DCU_aluop		(id_inst1_DCU_aluop ),

        .inst2_DCU_memtype 		(id_inst2_DCU_memtype ),
        .inst2_DCU_mreg   		(id_inst2_DCU_mreg  ),
        .inst2_DCU_whilo 		(id_inst2_DCU_whilo ),
        .inst2_DCU_wreg  		(id_inst2_DCU_wreg),
        .inst2_DCU_alutype		(id_inst2_DCU_alutype),
        .inst2_DCU_aluop		(id_inst2_DCU_aluop ),

        .MUX_writeaddr_o    (id_MUX_writeaddr_o),
        .MUX_shift_o        (id_MUX_shift_o ),
        .MUX_immsel_o  		(id_MUX_immsel_o),
        .id_din             (id_din         ),
        .pc_plus8_o			(id_pc_plus8_o  ),
        .DCU_jtsel			(id_jtsel       ),
        .jmp_addr1_o		(id_jmp_addr1_o ),
        .jmp_addr2_o		(id_jmp_addr2_o ),
        .jmp_addr3_o		(id_jmp_addr3_o ),
        .stallreq_id		(id_stallreq_id ),
        .is_mthilo          (id_is_mthilo   ),
        .rwc0               (id_rwc0        ),
        .cp0addr            (id_cp0addr     ),
        .ov_enable          (id_ov_enable   ),
        .id_exccode         (id_exccode     ),
        .next_delay         (id_next_delay  )
    );
    idexe_reg idexe_reg0(
        .clk		        (clk    ),
        .resetn			(resetn      ), 
        .id_memtype			(id_inst1_DCU_memtype   ),
        .id_mreg			(id_inst1_DCU_mreg      ),
        .id_whilo			(id_inst1_DCU_whilo     ),
        .id_wreg			(id_inst1_DCU_wreg      ),
        .id_alutype			(id_inst1_DCU_alutype   ),
        .id_aluop			(id_inst1_DCU_aluop     ),
        .id_src1			(id_MUX_shift_o ),
        .id_src2			(id_MUX_immsel_o),
        .id_wa   			(id_MUX_writeaddr_o),
        .id_din 			(id_din         ),
        .id_pcPlus8			(id_pc_plus8_o  ),
        .stall				(SCU_stall      ),
        .flush              (cp0_flush      ),
        .id_pc				(ifid_pc        ),  
        .id_is_mthilo       (id_is_mthilo   ),
        .id_rwc0            (id_rwc0        ),
        .id_cp0addr         (id_cp0addr     ),
        .id_ov_enable       (id_ov_enable   ),
        .id_id_exccode      (id_exccode     ),
        .id_next_delay      (id_next_delay  ),
        .loop_id_in_delay   (idexe_next_delay),
                                    
        .exe_memtype		(idexe_memtype  ),
        .exe_mreg			(idexe_mreg     ),
        .exe_whilo			(idexe_whilo    ),
        .exe_wreg			(idexe_wreg     ),
        .exe_alutype		(idexe_alutype  ),
        .exe_aluop			(idexe_aluop    ),
        .exe_wa				(idexe_wa       ),
        .exe_src1			(idexe_src1     ),
        .exe_src2			(idexe_src2     ),
        .exe_din			(idexe_din      ),
        .exe_pcPlus8		(idexe_pcPlus8  ),
        .exe_pc				(idexe_pc       ),
        .exe_is_mthilo      (idexe_is_mthilo),
        .exe_rwc0           (idexe_rwc0     ),
        .exe_cp0addr        (idexe_cp0addr  ),
        .exe_ov_enable      (idexe_ov_enable),
        .exe_id_exccode     (idexe_id_exccode),
        .exe_next_delay     (idexe_next_delay),
        .exe_id_in_delay    (idexe_id_in_delay)
    );
    exe_stage exe_stage0(
        .clk 		(clk    ),
        .resetn 			(resetn      ),
        .memtype_i 			(idexe_memtype  ),
    	.mreg_i       		(idexe_mreg     ),
        .whilo_i      		(idexe_whilo    ),
        .wreg_i       		(idexe_wreg     ),
        .alutype_i    		(idexe_alutype  ),
        .aluop_i      		(idexe_aluop    ),
        .wa_i         		(idexe_wa       ),
        .src1_i       		(idexe_src1     ),
        .src2_i       		(idexe_src2     ),
        .din_i              (idexe_din      ),
        .pcPlus8         	(idexe_pcPlus8  ),
        .ov_enable          (idexe_ov_enable),
        .id_exccode         (idexe_id_exccode),

        .hilo               (HILO_hilo_o    ),
        .mem2exe_whilo 		(exemem_whilo   ),
	    .mem2exe_hilo 		(exemem_mulres  ),
        .wb2exe_whilo 		(memwb_whilo    ),
	    .wb2exe_hilo   		(memwb_hilo     ),
        .mem2exe_is_mthilo  (exemem_is_mthilo),
        .wb2exe_is_mthilo   (memwb_is_mthilo),
        .mem2exe_mthilo     (exemem_wd      ),
        .wb2exe_mthilo      (memwb_dreg     ),

        .cp0_re             (idexe_rwc0[0]  ),
        .cp0_addr           (idexe_cp0addr  ),
        .cp0_data_i         (cp0_rdata      ),
        .mem2exe_wc0        (exemem_wc0     ),
        .mem2exe_cp0addr    (exemem_cp0addr ),
        .mem2exe_cp0wdata   (exemem_cp0wdata),
        .wb2exe_wc0         (memwb_wc0      ),
        .wb2exe_cp0addr     (memwb_cp0addr  ),
        .wb2exe_cp0wdata    (memwb_cp0wdata ),

        .memtype_o      	(exe_memtype    ),
        .stallreq_exe_o 	(exe_stallreq_exe),
        .mreg_o           	(exe_mreg       ),
        .whilo_o           	(exe_whilo      ),
        .wreg_o            	(exe_wreg       ),
        .aluop_o           	(exe_aluop      ),
        .wa_o               (exe_wa         ),
        .mulres_o        	(exe_mulres     ),
        .alu_result_o    	(exe_alu_result ),
        .din_o              (exe_din        ),
        .exe_exccode        (exe_exccode    )
    );
    
    exemem_reg exemem_reg0(
        .clk		(clk    ),
        .resetn			(resetn      ),
        .exe_memtype		(exe_memtype    ),
        .exe_mreg			(exe_mreg       ),
        .exe_whilo			(exe_whilo      ),
        .exe_wreg			(exe_wreg       ),
        .exe_aluop			(exe_aluop      ),
        .exe_wa				(exe_wa         ),
        .exe_mulres			(exe_mulres     ),
        .exe_wd				(exe_alu_result ),
        .exe_din			(exe_din        ),
        .stall				(SCU_stall      ),
        .flush              (cp0_flush      ),
        .exe_pc				(idexe_pc       ),
        .exe_is_mthilo      (idexe_is_mthilo),
        .exe_wc0            (idexe_rwc0[1]  ),
        .exe_cp0addr        (idexe_cp0addr  ),
        .exe_cp0wdata       (idexe_src2     ),
        .exe_exe_exccode    (exe_exccode    ),
        .exe_exe_in_delay   (idexe_id_in_delay),

        .mem_memtype		(exemem_memtype ),
        .mem_mreg			(exemem_mreg    ),
        .mem_whilo			(exemem_whilo   ),
        .mem_wreg			(exemem_wreg    ),
        .mem_aluop			(exemem_aluop   ),
        .mem_wa				(exemem_wa      ),
        .mem_mulres			(exemem_mulres  ),
        .mem_wd				(exemem_wd      ),
        .mem_din			(exemem_din     ),
        .mem_pc				(exemem_pc      ),
        .mem_is_mthilo      (exemem_is_mthilo),
        .mem_wc0            (exemem_wc0     ),
        .mem_cp0addr        (exemem_cp0addr ),
        .mem_cp0wdata       (exemem_cp0wdata),
        .mem_exe_exccode    (exemem_exe_exccode),
        .mem_exe_in_delay   (exemem_exe_in_delay)
    );
    mem_stage mem_stage0(
        .resetn          (resetn      ),
        .mem_memtype_i      (exemem_memtype ),
    	.mem_mreg_i         (exemem_mreg    ),
        .mem_whilo_i        (exemem_whilo   ),
        .mem_wreg_i         (exemem_wreg    ),
        .mem_aluop_i        (exemem_aluop   ),
        .mem_wa_i           (exemem_wa      ),
        .mem_hilo_i         (exemem_mulres  ),
        .mem_wd_i           (exemem_wd      ),
        .mem_din_i          (exemem_din     ),
        .mem_exe_exccode    (exemem_exe_exccode),
        .mem_pc_i           (exemem_pc      ),

        .casue_i            (cp0_cause_o    ),
        .status_i           (cp0_status_o   ),
        .wb2mem_cp0we       (memwb_wc0      ),
        .wb2mem_cp0waddr    (memwb_cp0addr  ),
        .wb2mem_cp0wdata    (memwb_cp0wdata ),

        .mem_memtype_o      (mem_memtype    ),
        .mem_mreg_o         (mem_mreg       ),
        .mem_whilo_o        (mem_whilo      ),
        .mem_wreg_o         (mem_wreg       ),
        .dre_o              (mem_dre        ),
        .mem_wa_o           (mem_wa         ),
        .mem_hilo_o         (mem_hilo       ),
        .mem_dreg_o         (mem_dreg       ),
        .dce                (dce            ),
        .daddr              (mem_daddr      ),
        .we_o               (we             ),
        .din                (din            ),

        .cp0_exccode        (mem_cp0exccode ),
        .mem_badaddr        (mem_badaddr    )
    );

    memwb_reg memwb_reg0(
        .clk        (clk    ),
        .resetn          (resetn      ),
        .mem_memtype        (mem_memtype    ),
        .mem_mreg           ( mem_mreg      ),
        .mem_whilo          (mem_whilo      ),
        .mem_wreg           (mem_wreg       ),
        .mem_wa             (mem_wa         ),
        .mem_hilo           (mem_hilo       ),
        .mem_dreg           (mem_dreg       ),
        .mem_dre            (mem_dre        ),
        .mem_pc             (exemem_pc      ),
        .mem_is_mthilo      (exemem_is_mthilo),
        .mem_wc0            (exemem_wc0     ),
        .mem_cp0addr        (exemem_cp0addr ),
        .mem_cp0wdata       (exemem_cp0wdata),
        .flush              (cp0_flush      ),
        .mem_daddr          (mem_daddr      ),

        .wb_memtype         (memwb_memtype  ),
        .wb_mreg            (memwb_mreg     ),
        .wb_whilo           (memwb_whilo    ),
        .wb_wreg            (memwb_wreg     ),
        .wb_wa              (memwb_wa       ),
        .wb_dreg            (memwb_dreg     ),
        .wb_hilo            (memwb_hilo     ),
        .wb_dre             (memwb_dre      ),
        .wb_pc              (memwb_pc       ),
        .wb_is_mthilo       (memwb_is_mthilo),
        .wb_wc0             (memwb_wc0      ),
        .wb_cp0addr         (memwb_cp0addr  ),
        .wb_cp0wdata        (memwb_cp0wdata ),
        .wb_daddr           (memwb_daddr    )
);

    wb_stage wb_stage0 (
    	.sys_rst_n          (resetn      ),
        .wb_memtype         (memwb_memtype  ),
        .wb_mreg_i          (memwb_mreg     ),
        .wb_whilo_i         (memwb_whilo    ),
        .wb_wreg_i          (memwb_wreg     ),
        .wb_dre_i           (memwb_dre      ),
        .wb_wa_i            (memwb_wa       ),
        .wb_hilo_i          (memwb_hilo     ),
        .wb_dreg_i          (memwb_dreg     ),
        .dm_i               (dout           ),
        .wb_is_mthilo       (memwb_is_mthilo),
        .wb_daddr           (memwb_daddr    ),

        .wb_whilo_o         (wb_whilo       ),
        .wb_wreg_o          (wb_wreg        ),
        .wb_wa_o            (wb_wa          ),
        .wb_hilo_o          (wb_hilo        ),
        .wb_wd_o            (wb_wd          )
    );
    

    HILO_reg HILO_reg0(
    	.clk        (clk    ),
        .resetn          (resetn      ),
        .we                 (wb_whilo       ),
        .lo_i               (wb_hilo[31:0]  ),
        .hi_i               (wb_hilo[63:32] ),
        .hilo_o             (HILO_hilo_o    )
    );

    SCU SCU0(
    	.resetn             (resetn      ),
    	.stallreq_id        (id_stallreq_id ),
    	.stallreq_exe       (exe_stallreq_exe),
    	.stall              (SCU_stall      )
    );

`ifdef  USE_LOG
    log log0(
    	.clk        (clk    ),
        .resetn          (resetn      ),
        .inst               (ifid_inst      )
    );
`endif 

    CP0 CP00(
    	.clk        (clk    ),
        .resetn          (resetn      ),
        .re                 (idexe_rwc0[0]  ),
        .raddr              (idexe_cp0addr  ),
        .waddr              (memwb_cp0addr  ),
        .we                 (memwb_wc0      ),
        .wdata              (memwb_cp0wdata ),

        .badaddr            (mem_badaddr    ),
        .pc_i               (exemem_pc      ),
        .exccode            (mem_cp0exccode ),
        .in_delay           (exemem_exe_in_delay),

        .flush              (cp0_flush      ),
        .data_o             (cp0_rdata      ),
        .cause_o            (cp0_cause_o    ),
        .status_o           (cp0_status_o   ),
        .excaddr            (cp0_excaddr    )
    );  
    

endmodule
