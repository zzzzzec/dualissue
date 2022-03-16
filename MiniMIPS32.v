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
/*                                        id_stage                   */    
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
/*===========================       idexe              ========*/

    wire [7:0]                  idexe_inst1_memtype;
    wire                       	idexe_inst1_mreg;
    wire [1:0]                  idexe_inst1_whilo;
    wire                        idexe_inst1_wreg;
    wire [`ALUTYPE_BUS]     	idexe_inst1_alutype;
    wire [`ALUOP_BUS]        	idexe_inst1_aluop;
    wire [`REG_ADDR_BUS]        idexe_inst1_wa;
    wire [`REG_BUS]        		idexe_inst1_src1;
    wire [`REG_BUS]        		idexe_inst1_src2;
    wire [`REG_BUS]             idexe_inst1_din;
    wire [`INST_BUS]            idexe_iaddr1;
    wire [`INST_BUS]            idexe_iaddr1_p8;
    wire [1:0]                  idexe_inst1_is_mthilo;

    wire [`INST_BUS]            idexe_iaddr2;
    wire [7:0]                  idexe_inst2_memtype;
    wire                       	idexe_inst2_mreg;
    wire [1:0]                  idexe_inst2_whilo;
    wire                        idexe_inst2_wreg;
    wire [`ALUTYPE_BUS]     	idexe_inst2_alutype;
    wire [`ALUOP_BUS]        	idexe_inst2_aluop;
    wire [`REG_ADDR_BUS]        idexe_inst2_wa;
    wire [`REG_BUS]        		idexe_inst2_src1;
    wire [`REG_BUS]        		idexe_inst2_src2;
    wire [`REG_BUS]             idexe_inst2_din;
    wire [`INST_BUS]            idexe_iaddr2_p8;
    wire [1:0]                  idexe_inst2_is_mthilo;

    wire [1:0]                  idexe_rwc0;
    wire [`REG_ADDR_BUS]        idexe_cp0addr;
    wire                        idexe_ov_enable;
    wire [`EXC_CODE_BUS]        idexe_id_exccode;
    wire                        idexe_next_delay;
    wire                        idexe_id_in_delay;

/*=========================         exe         ==========          */
    wire [`ALUOP_BUS	    ] 	exe_inst1_aluop;
    wire [`DOUBLE_WORD_BUS] 	exe_inst1_mulres;

    wire [`WORD_BUS]            exe_inst1_alu_result;
    wire [`WORD_BUS]            exe_inst2_alu_result;
    wire                        exe_inst1_stallreq_exe;
    wire [`EXC_CODE_BUS]        exe_inst1_exccode;

    wire [7:0]                  exe_inst1_memtype; 
    wire                        exe_inst1_mreg;
    wire [1:0]                  exe_inst1_whilo;
    wire                        exe_inst1_wreg;
    wire [`REG_ADDR_BUS 	] 	exe_inst1_wa;    
    wire [`REG_BUS]             exe_inst1_din;
    wire [7:0]                  exe_inst2_memtype; 
    wire                        exe_inst2_mreg;
    wire [1:0]                  exe_inst2_whilo;
    wire                        exe_inst2_wreg;
    wire [`REG_ADDR_BUS 	] 	exe_inst2_wa;    
    wire [`REG_BUS]             exe_inst2_din;


/*===================================*/
/*                        exemem_reg                            */
    wire[7:0]                   exemem_inst1_memtype;
    wire                        exemem_inst1_mreg;
    wire [1:0]                  exemem_inst1_whilo;
    wire                        exemem_inst1_wreg;
    wire [`ALUOP_BUS]   		exemem_inst1_aluop;
    wire [`REG_ADDR_BUS]    	exemem_inst1_wa;
    wire [`WORD_BUS]    		exemem_inst1_wd;
    wire [`REG_BUS]           	exemem_inst1_din;
    wire [`INST_BUS]            exemem_iaddr1;

    wire[7:0]                   exemem_inst2_memtype;
    wire                        exemem_inst2_mreg;
    wire [1:0]                  exemem_inst2_whilo;
    wire                        exemem_inst2_wreg;
    wire [`ALUOP_BUS]   		exemem_inst2_aluop;
    wire [`REG_ADDR_BUS]    	exemem_inst2_wa;
    wire [`WORD_BUS]    		exemem_inst2_wd;
    wire [`REG_BUS]           	exemem_inst2_din;
    wire [`INST_BUS]            exemem_iaddr2;

    wire [`DOUBLE_WORD_BUS] 	exemem_mulres;
    wire [1:0]                  exemem_is_mthilo;
    wire                        exemem_wc0;
    wire [`REG_ADDR_BUS]        exemem_cp0addr;
    wire [`WORD_BUS     ]       exemem_cp0wdata;
    wire [`EXC_CODE_BUS ]       exemem_exe_exccode;
    wire                        exemem_exe_in_delay;

/*===================================*/
/*                           memstage                                        */
    wire [7:0]                  mem_inst1_memtype;
    wire                      	mem_inst1_mreg;
    wire [1:0]                  mem_inst1_whilo;
    wire                      	mem_inst1_wreg;
    wire [`REG_ADDR_BUS  ]      mem_inst1_wa;
    wire [`DOUBLE_REG_BUS ]     mem_inst1_hilo;
    wire [`REG_BUS ]           	mem_inst1_w2regdata;
    wire [`REG_BUS]             mem_inst1_w2ramdata;

    wire [7:0]                  mem_inst2_memtype;
    wire                      	mem_inst2_mreg;
    wire [1:0]                  mem_inst2_whilo;
    wire                      	mem_inst2_wreg;
    wire [`REG_ADDR_BUS  ]      mem_inst2_wa;
    wire [`DOUBLE_REG_BUS ]     mem_inst2_hilo;
    wire [`REG_BUS ]           	mem_inst2_w2regdata;
    wire [`REG_BUS]             mem_inst2_w2ramdata;

	wire [`BSEL_BUS]			mem_we;
    wire [`EXC_CODE_BUS  ]      mem_cp0exccode;
    wire [`WORD_BUS      ]      mem_badaddr;
    wire [`WORD_BUS      ]      mem_daddr;
    wire [`BSEL_BUS ]      		mem_dre;
    assign daddr = mem_daddr; 
/*===================================*/
/*                        memwb_reg                               */
    wire [7:0]                  memwb_inst1_memtype;
    wire                        memwb_inst1_mreg;
    wire [1:0]                  memwb_inst1_whilo;
    wire                        memwb_inst1_wreg;
    wire [`REG_ADDR_BUS]     	memwb_inst1_wa;
    wire [`DOUBLE_WORD_BUS] 	memwb_inst1_hilo;
    wire [`WORD_BUS]            memwb_inst1_w2regdata;
    wire [`INST_BUS]            memwb_iaddr1;

    wire [7:0]                  memwb_inst2_memtype;
    wire                        memwb_inst2_mreg;
    wire [1:0]                  memwb_inst2_whilo;
    wire                        memwb_inst2_wreg;
    wire [`REG_ADDR_BUS]     	memwb_inst2_wa;
    wire [`DOUBLE_WORD_BUS] 	memwb_inst2_hilo;
    wire [`WORD_BUS]            memwb_inst2_w2regdata;
    wire [`INST_BUS]            memwb_iaddr2;

    wire [`BSEL_BUS]            memwb_dre;
	wire [`BSEL_BUS]			memwb_we;
    wire [1:0]                  memwb_is_mthilo;
    wire                        memwb_wc0;
    wire [`REG_ADDR_BUS]        memwb_cp0addr;
    wire [`WORD_BUS     ]       memwb_cp0wdata;
    wire [`WORD_BUS     ]       memwb_daddr;
/*===================================*/
/*                        wb_stage                               */
    wire                        wb_inst1_wreg;
    wire [`REG_ADDR_BUS  ] 		wb_inst1_wa;
    wire [`WORD_BUS      ]    	wb_inst1_inst1_w2regdata;
    wire                        wb_inst2_wreg;
    wire [`REG_ADDR_BUS  ] 		wb_inst2_wa;
    wire [`WORD_BUS      ]    	wb_inst2_inst1_w2regdata;


    wire [`DOUBLE_REG_BUS] 		wb_hilo;
    wire [1:0]                  wb_whilo;

/*==================================*/
/*                       HILO                                          */
    wire [`DOUBLE_WORD_BUS]     HILO_hilo_o;
/*==================================*/
/*                          SCU                                         */
    wire [`STALL_BUS]           SCU_stall;
/*==================================*/
/*                          CP0                                                     */
    wire [`REG_BUS]             cp0_rdata;
    wire [`REG_BUS]             cp0_cause_o;    
    wire [`REG_BUS]             cp0_status_o;
    wire                        cp0_flush;
    wire [`WORD_BUS]            cp0_excaddr;

	//assign debug_wb_pc = memwb_pc;
	//assign debug_wb_rf_wdata = wb_inst1_w2regdata;
	//assign debug_wb_rf_wnum = wb_wa;
	//assign debug_wb_rf_wen = (wb_wreg == 1)?{4'b1111}:{4'b0000};

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

        .inst1_wreg_i               (wb_inst1_wreg        ),
        .inst1_wa_i                 (wb_inst1_wa          ),
        .inst1_w2regdata_i            (wb_inst1_w2regdata     ),

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

        .inst2_wreg_i               (wb_inst2_wreg),
        .inst2_wa_i                 (wb_inst2_wa),
        .inst2_w2regdata_i            (wb_inst2_w2regdata),

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
        .clk		        (clk                    ),
        .resetn			    (resetn                 ), 

        .id_inst1_memtype			(id_inst1_DCU_memtype   ),
        .id_inst1_mreg			    (id_inst1_DCU_mreg      ),
        .id_inst1_whilo			    (id_inst1_DCU_whilo     ),
        .id_inst1_wreg			    (id_inst1_DCU_wreg      ),
        .id_inst1_alutype			(id_inst1_DCU_alutype   ),
        .id_inst1_aluop			    (id_inst1_DCU_aluop     ),
        .id_inst1_src1			    (id_MUX_shift_o         ),
        .id_inst1_src2			    (id_MUX_immsel_o        ),
        .id_inst1_wa   			    (id_MUX_writeaddr_o     ),
        .id_inst1_din 			    (id_din                 ),
        .id_iaddr1				    (ifid_pc        ), 
        .id_iaddr1_p8			    (id_pc_plus8_o  ),            

        .id_inst2_memtype			(id_inst2_DCU_memtype   ),
        .id_inst2_mreg			    (id_inst2_DCU_mreg      ),
        .id_inst2_whilo			    (id_inst2_DCU_whilo     ),
        .id_inst2_wreg			    (id_inst2_DCU_wreg      ),
        .id_inst2_alutype			(id_inst2_DCU_alutype   ),
        .id_inst2_aluop			    (id_inst2_DCU_aluop     ),
        .id_inst2_src1			    (),
        .id_inst2_src2			    (),
        .id_inst2_wa   			    (wb_inst2_wa),
        .id_inst2_din 			    (),
        .id_iaddr2				    (), 
        .id_iaddr2_p8			    (),       


        .stall				(SCU_stall      ),
        .flush              (cp0_flush      ),
 
        .id_is_mthilo       (id_is_mthilo   ),
        .id_rwc0            (id_rwc0        ),
        .id_cp0addr         (id_cp0addr     ),
        .id_ov_enable       (id_ov_enable   ),
        .id_id_exccode      (id_exccode     ),
        .id_next_delay      (id_next_delay  ),
        .loop_id_in_delay   (idexe_next_delay),
//======================out=======================================

        .exe_inst1_memtype		    (idexe_inst1_memtype  ),
        .exe_inst1_mreg			    (idexe_inst1_mreg     ),
        .exe_inst1_whilo			(idexe_inst1_whilo    ),
        .exe_inst1_wreg			    (idexe_inst1_wreg     ),
        .exe_inst1_alutype		    (idexe_inst1_alutype  ),
        .exe_inst1_aluop			(idexe_inst1_aluop    ),
        .exe_inst1_wa				(idexe_inst1_wa       ),
        .exe_inst1_src1			    (idexe_inst1_src1     ),
        .exe_inst1_src2			    (idexe_inst1_src2     ),
        .exe_inst1_din			    (idexe_inst1_din      ),
        .exe_iaddr1				    (idexe_iaddr1         ),
        .exe_iaddr1_p8		        (idexe_iaddr1_p8      ),

        .exe_inst2_memtype		    (idexe_inst2_memtype  ),
        .exe_inst2_mreg			    (idexe_inst2_mreg     ),
        .exe_inst2_whilo			(idexe_inst2_whilo    ),
        .exe_inst2_wreg			    (idexe_inst2_wreg     ),
        .exe_inst2_alutype		    (idexe_inst2_alutype  ),
        .exe_inst2_aluop			(idexe_inst2_aluop    ),
        .exe_inst2_wa				(idexe_inst2_wa       ),
        .exe_inst2_src1			    (idexe_inst2_src1     ),
        .exe_inst2_src2			    (idexe_inst2_src2     ),
        .exe_inst2_din			    (idexe_inst2_din      ),
        .exe_iaddr2				    (idexe_iaddr2         ),
        .exe_iaddr2_p8		        (idexe_iaddr2_p8  ),


        .exe_is_mthilo      (idexe_is_mthilo),
        .exe_rwc0           (idexe_rwc0     ),
        .exe_cp0addr        (idexe_cp0addr  ),
        .exe_ov_enable      (idexe_ov_enable),
        .exe_id_exccode     (idexe_id_exccode),
        .exe_next_delay     (idexe_next_delay),
        .exe_id_in_delay    (idexe_id_in_delay)

    );
    exe_stage exe_stage0(
        .clk 		        (clk      ),
        .resetn 			(resetn      ),

        .inst1_alutype_i    		(idexe_inst1_alutype  ),
        .inst1_aluop_i      		(idexe_inst1_aluop    ),
        .inst1_src1_i       		(idexe_inst1_src1     ),
        .inst1_src2_i       		(idexe_inst1_src2     ),
        .inst2_alutype_i    		(idexe_inst2_alutype  ),
        .inst2_aluop_i      		(idexe_inst2_aluop    ),
        .inst2_src1_i       		(idexe_inst2_src1     ),
        .inst2_src2_i       		(idexe_inst2_src2     ),

        .iaddr1_p8         	(idexe_pcPlus8  ),
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
        .stallreq_exe_o 	(exe_stallreq_exe),
        .aluop_o           	(exe_inst1_aluop      ),
        .mulres_o        	(exe_inst1_mulres     ),
        .ALU_inst1_result    	(exe_inst1_alu_result ),
        .ALU_inst2_result    	(exe_inst2_alu_result ),
        .exe_exccode            (exe_inst1_exccode    ),

// pass 
        .inst1_memtype_i      	    (idexe_inst1_memtype),
        .inst1_mreg_i           	(idexe_inst1_mreg   ),
        .inst1_whilo_i           	(idexe_inst1_whilo  ),
        .inst1_wreg_i            	(idexe_inst1_wreg   ),
        .inst1_wa_i                 (idexe_inst1_wa     ),
        .inst1_din_i                (idexe_inst1_din    ),

        .inst2_memtype_i      	    (idexe_inst2_memtype),
        .inst2_mreg_i           	(idexe_inst2_mreg   ),
        .inst2_whilo_i           	(idexe_inst2_whilo  ),
        .inst2_wreg_i            	(idexe_inst2_wreg   ),
        .inst2_wa_i                 (idexe_inst2_wa     ),
        .inst2_din_i                (idexe_inst2_din    ),

        .inst1_memtype_o      	    (exe_inst1_memtype      ),
        .inst1_mreg_o           	(exe_inst1_mreg         ),
        .inst1_whilo_o           	(exe_inst1_whilo        ),
        .inst1_wreg_o            	(exe_inst1_wreg         ),
        .inst1_wa_o                 (exe_inst1_wa           ),
        .inst1_din_o                (exe_inst1_din          ),

        .inst2_memtype_o      	    (exe_inst2_memtype      ),
        .inst2_mreg_o           	(exe_inst2_mreg         ),
        .inst2_whilo_o           	(exe_inst2_whilo        ),
        .inst2_wreg_o            	(exe_inst2_wreg         ),
        .inst2_wa_o                 (exe_inst2_wa           ),
        .inst2_din_o                (exe_inst2_din          )
    );
    
    exemem_reg exemem_reg0(
        .clk		        (clk            ),
        .resetn			    (resetn         ),
        .stall				(SCU_stall      ),
        .flush              (cp0_flush      ),

        .exe_inst1_memtype		(exe_inst1_memtype      ),
        .exe_inst1_mreg			(exe_inst1_mreg         ),
        .exe_inst1_whilo		(exe_inst1_whilo        ),
        .exe_inst1_wreg			(exe_inst1_wreg         ),
        .exe_inst1_aluop		(exe_inst1_aluop        ),
        .exe_inst1_wa			(exe_inst1_wa           ),
        .exe_inst1_wd			(exe_inst1_alu_result   ),
        .exe_inst1_din			(exe_inst1_din          ),
        .exe_iaddr1			    (idexe_iaddr1           ),


        .exe_inst2_memtype		(exe_inst2_memtype      ),
        .exe_inst2_mreg			(exe_inst2_mreg         ),
        .exe_inst2_whilo		(exe_inst2_whilo        ),
        .exe_inst2_wreg			(exe_inst2_wreg         ),
        .exe_inst2_aluop		(exe_inst2_aluop        ),
        .exe_inst2_wa			(exe_inst2_wa           ),
        .exe_inst2_wd			(exe_inst2_alu_result   ),
        .exe_inst2_din			(exe_inst2_din          ),
        .exe_iaddr2			    (idexe_iaddr2           ),

        .exe_mulres			(exe_mulres     ),
        .exe_is_mthilo      (idexe_is_mthilo),
        .exe_wc0            (idexe_rwc0[1]  ),
        .exe_cp0addr        (idexe_cp0addr  ),
        .exe_cp0wdata       (idexe_src2     ),
        .exe_exe_exccode    (exe_exccode    ),
        .exe_exe_in_delay   (idexe_id_in_delay),

//       out 
        .mem_inst1_memtype		    (exemem_inst1_memtype ),
        .mem_inst1_mreg			    (exemem_inst1_mreg    ),
        .mem_inst1_whilo			(exemem_inst1_whilo   ),
        .mem_inst1_wreg			    (exemem_inst1_wreg    ),
        .mem_inst1_aluop			(exemem_inst1_aluop   ),
        .mem_inst1_wa				(exemem_inst1_wa      ),
        .mem_inst1_wd				(exemem_inst1_wd      ),
        .mem_inst1_din			    (exemem_inst1_din     ),
        .mem_iaddr1				    (exemem_iaddr1          ),

        .mem_inst2_memtype		    (exemem_inst2_memtype ),
        .mem_inst2_mreg			    (exemem_inst2_mreg    ),
        .mem_inst2_whilo			(exemem_inst2_whilo   ),
        .mem_inst2_wreg			    (exemem_inst2_wreg    ),
        .mem_inst2_aluop			(exemem_inst2_aluop   ),
        .mem_inst2_wa				(exemem_inst2_wa      ),
        .mem_inst2_wd				(exemem_inst2_wd      ),
        .mem_inst2_din			    (exemem_inst2_din     ),
        .mem_iaddr2				    (exemem_iaddr2       ),

        .mem_mulres			(exemem_mulres  ),
        .mem_is_mthilo      (exemem_is_mthilo),
        .mem_wc0            (exemem_wc0     ),
        .mem_cp0addr        (exemem_cp0addr ),
        .mem_cp0wdata       (exemem_cp0wdata),
        .mem_exe_exccode    (exemem_exe_exccode),
        .mem_exe_in_delay   (exemem_exe_in_delay)
    );


    mem_stage mem_stage0(
        .resetn             (resetn      ),

        .mem_iaddr1_i       (),
        .mem_iaddr2_i       (),
        .mem_inst1_w2ramdata_i  (),
        .mem_aluop_i        (exemem_aluop   ),
        .mem_exe_exccode    (exemem_exe_exccode),
        
        .casue_i            (cp0_cause_o    ),
        .status_i           (cp0_status_o   ),
        .wb2mem_cp0we       (memwb_wc0      ),
        .wb2mem_cp0waddr    (memwb_cp0addr  ),
        .wb2mem_cp0wdata    (memwb_cp0wdata ),

        .dre_o              (mem_dre        ),
        .dce                (dce            ),
        .daddr              (mem_daddr      ),
        .we_o               (we             ),
        .din                (din            ),

        .cp0_exccode        (mem_cp0exccode ),
        .mem_badaddr        (mem_badaddr    ),


        .mem_inst1_memtype_i    (exemem_inst1_memtype),
        .mem_inst1_mreg_i       (exemem_inst1_mreg),
        .mem_inst1_whilo_i      (exemem_inst1_whilo),
        .mem_inst1_wreg_i       (exemem_inst1_wreg),
        .mem_inst1_wa_i         (exemem_inst1_wa),
        .mem_inst1_hilo_i       (),
        .mem_inst1_w2regdata_i  (exemem_inst1_wd),

        .mem_inst2_memtype_i    (exemem_inst2_memtype),
        .mem_inst2_mreg_i       (exemem_inst2_mreg),
        .mem_inst2_whilo_i      (exemem_inst2_whilo),
        .mem_inst2_wreg_i       (exemem_inst2_wreg),
        .mem_inst2_wa_i         (exemem_inst2_wa),
        .mem_inst2_hilo_i       (),
        .mem_inst2_w2regdata_i  (exemem_inst2_wd),

        .mem_inst1_memtype_o    (mem_inst1_memtype),
        .mem_inst1_mreg_o       (mem_inst1_mreg),
        .mem_inst1_whilo_o      (mem_inst1_whilo),
        .mem_inst1_wreg_o       (mem_inst1_wreg),
        .mem_inst1_wa_o         (mem_inst1_wa),
        .mem_inst1_hilo_o       (),
        .mem_inst1_w2regdata_o  (mem_inst1_wd),

        .mem_inst2_memtype_o    (mem_inst2_memtype),
        .mem_inst2_mreg_o       (mem_inst2_mreg),
        .mem_inst2_whilo_o      (mem_inst2_whilo),
        .mem_inst2_wreg_o       (mem_inst2_wreg),
        .mem_inst2_wa_o         (mem_inst2_wa),
        .mem_inst2_hilo_o       (),
        .mem_inst2_w2regdata_o  (mem_inst2_wd)
    );

    memwb_reg memwb_reg0(
        .clk                    (clk         ),
        .resetn                 (resetn      ),

        .mem_inst1_memtype        (mem_inst1_memtype    ),
        .mem_inst1_mreg           (mem_inst1_mreg      ),
        .mem_inst1_whilo          (mem_inst1_whilo      ),
        .mem_inst1_wreg           (mem_inst1_wreg       ),
        .mem_inst1_wa             (mem_inst1_wa         ),
        .mem_inst1_hilo           (mem_inst1_hilo       ),
        .mem_inst1_w2regdata      (mem_inst1_w2regdata  ),
        .mem_iaddr1               (exemem_iaddr1  ),

        .mem_inst2_memtype        (mem_inst2_memtype    ),
        .mem_inst2_mreg           (mem_inst2_mreg      ),
        .mem_inst2_whilo          (mem_inst2_whilo      ),
        .mem_inst2_wreg           (mem_inst2_wreg       ),
        .mem_inst2_wa             (mem_inst2_wa         ),
        .mem_inst2_hilo           (mem_inst2_hilo       ),
        .mem_inst2_w2regdata      (mem_inst2_w2regdata  ),
        .mem_iaddr2               (exemem_iaddr2  ),

        .mem_dre            (mem_dre        ),
        .mem_is_mthilo      (exemem_is_mthilo),
        .mem_wc0            (exemem_wc0     ),
        .mem_cp0addr        (exemem_cp0addr ),
        .mem_cp0wdata       (exemem_cp0wdata),
        .flush              (cp0_flush      ),
        .mem_daddr          (mem_daddr      ),

        .wb_inst1_memtype        (memwb_inst1_memtype    ),
        .wb_inst1_mreg           (memwb_inst1_mreg      ),
        .wb_inst1_whilo          (memwb_inst1_whilo      ),
        .wb_inst1_wreg           (memwb_inst1_wreg       ),
        .wb_inst1_wa             (memwb_inst1_wa         ),
        .wb_inst1_hilo           (memwb_inst1_hilo       ),
        .wb_inst1_w2regdata      (memwb_inst1_w2regdata  ),
        .wb_iaddr1              (memwb_iaddr1  ),

        .wb_inst2_memtype        (memwb_inst2_memtype    ),
        .wb_inst2_mreg           (memwb_inst2_mreg      ),
        .wb_inst2_whilo          (memwb_inst2_whilo      ),
        .wb_inst2_wreg           (memwb_inst2_wreg       ),
        .wb_inst2_wa             (memwb_inst2_wa         ),
        .wb_inst2_hilo           (memwb_inst2_hilo       ),
        .wb_inst2_w2regdata      (memwb_inst2_w2regdata  ),
        .wb_iaddr2               (memwb_iaddr2  ),

        .wb_dre             (memwb_dre      ),
        .wb_is_mthilo       (memwb_is_mthilo),
        .wb_wc0             (memwb_wc0      ),
        .wb_cp0addr         (memwb_cp0addr  ),
        .wb_cp0wdata        (memwb_cp0wdata ),
        .wb_daddr           (memwb_daddr    )
);

    wb_stage wb_stage0 (
    	.resetn             (resetn         ),

        .wb_inst1_memtype_i         (memwb_inst1_memtype  ),
        .wb_inst1_mreg_i          (memwb_inst1_mreg     ),
        .wb_inst1_whilo_i         (memwb_inst1_whilo    ),
        .wb_inst1_wreg_i          (memwb_inst1_wreg     ),
        .wb_inst1_wa_i            (memwb_inst1_wa       ),
        .wb_inst1_w2regdata_i     (memwb_inst1_w2regdata),

        .wb_inst2_memtype_i         (memwb_inst2_memtype  ),
        .wb_inst2_mreg_i          (memwb_inst2_mreg     ),
        .wb_inst2_whilo_i         (memwb_inst2_whilo    ),
        .wb_inst2_wreg_i          (memwb_inst2_wreg     ),
        .wb_inst2_wa_i            (memwb_inst2_wa       ),
        .wb_inst2_w2regdata_i     (memwb_inst2_w2regdata),

        .wb_dre_i                 (memwb_dre      ),
        .wb_hilo_i                (memwb_hilo     ),

        .rdata_from_ram           (dout           ),
        .wb_is_mthilo             (memwb_is_mthilo),
        .wb_daddr                 (memwb_daddr    ),


        .wb_inst1_wreg_o            (wb_inst1_wreg      ),
        .wb_inst1_wa_o              (wb_inst1_wa        ),
        .wb_inst1_w2regdata_o       (wb_inst1_w2regdata ),

        .wb_inst2_wreg_o            (wb_inst2_wreg      ),
        .wb_inst2_wa_o              (wb_inst2_wa        ),
        .wb_inst2_w2regdata_o       (wb_inst2_w2regdata ),
        

        .wb_whilo_o         (wb_whilo       ),
        .wb_hilo_o          (wb_hilo        )
        
    );
    

    HILO_reg HILO_reg0(
    	.clk                (clk    ),
        .resetn             (resetn      ),
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

    CP0 CP00(
    	.clk                (clk    ),
        .resetn                 (resetn      ),
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
    



`ifdef  USE_LOG
    log log0(
    	.clk        (clk    ),
        .resetn          (resetn      ),
        .inst               (ifid_inst      )
    );
`endif 
endmodule
