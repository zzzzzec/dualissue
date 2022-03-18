`include "defines.v"

module exe_stage (
    input wire                      clk,
    input wire                      resetn,

    input wire [`ALUTYPE_BUS	] 	inst1_alutype_i,
    input wire [`ALUOP_BUS	    ] 	inst1_aluop_i,
    input wire [`REG_BUS 		] 	inst1_src1_i,
    input wire [`REG_BUS 		] 	inst1_src2_i,
    input wire [`REG_BUS        ]   iaddr1_p8,
    
    input wire                      ov_enable,
    input wire [`EXC_CODE_BUS   ]   id_exccode,

    input wire [`ALUTYPE_BUS	] 	inst2_alutype_i,
    input wire [`ALUOP_BUS	    ] 	inst2_aluop_i,
    input wire [`REG_BUS 		] 	inst2_src1_i,
    input wire [`REG_BUS 		] 	inst2_src2_i,   
// HILO FWARD
    input wire [`DOUBLE_WORD_BUS]   hilo, 
    input wire [1:0]                mem2exe_whilo,
    input wire [`DOUBLE_WORD_BUS]   mem2exe_hilo,
    input wire [1:0]                wb2exe_whilo,
    input wire [`DOUBLE_WORD_BUS]   wb2exe_hilo,
    input wire [1:0]                mem2exe_is_mthilo,
    input wire [1:0]                wb2exe_is_mthilo, 
    input wire [`WORD_BUS       ]   mem2exe_mthilo,   
    input wire [`WORD_BUS       ]   wb2exe_mthilo,

// CP0 FWARD
    input wire                      cp0_re,
    input wire[`REG_ADDR_BUS    ]   cp0_addr,                  
    input wire[`WORD_BUS        ]   cp0_data_i,
    input wire                      mem2exe_wc0,
    input wire[`REG_ADDR_BUS    ]   mem2exe_cp0addr,
    input wire[`WORD_BUS        ]   mem2exe_cp0wdata,
    input wire                      wb2exe_wc0,
    input wire[`REG_ADDR_BUS    ]   wb2exe_cp0addr,
    input wire[`WORD_BUS        ]   wb2exe_cp0wdata,                    


    output reg  [`WORD_BUS      ]   ALU_inst1_result,
    output reg  [`WORD_BUS      ]   ALU_inst2_result,

    output wire                     stallreq_exe_o,
    output wire [`ALUOP_BUS	    ] 	aluop_o,
    output wire [`DOUBLE_WORD_BUS]  mulres_o,
    output wire [`EXC_CODE_BUS  ]   exe_exccode,

    // not use, fall through 
    input wire [7:0]                inst1_memtype_i,
    input wire                      inst1_mreg_i,
    input wire [1:0]                inst1_whilo_i,
    input wire 					    inst1_wreg_i,
    input wire [`REG_ADDR_BUS 	] 	inst1_wa_i,
    input wire [`REG_BUS        ]   inst1_w2ramdata_i,
    input wire [7:0]                inst2_memtype_i,
    input wire                      inst2_mreg_i,
    input wire [1:0]                inst2_whilo_i,
    input wire 					    inst2_wreg_i,
    input wire [`REG_ADDR_BUS 	] 	inst2_wa_i,
    input wire [`REG_BUS        ]   inst2_w2ramdata_i,

    output wire [7:0]               inst1_memtype_o,
    output wire                     inst1_mreg_o,
    output wire [1:0]               inst1_whilo_o,
    output wire                     inst1_wreg_o,
    output wire [`REG_ADDR_BUS 	] 	inst1_wa_o,
    output wire [`REG_BUS       ]   inst1_w2ramdata_o,
    output wire [7:0]               inst2_memtype_o,
    output wire                     inst2_mreg_o,
    output wire [1:0]               inst2_whilo_o,
    output wire                     inst2_wreg_o,
    output wire [`REG_ADDR_BUS 	] 	inst2_wa_o,
    output wire [`REG_BUS       ]   inst2_w2ramdata_o
    );

    wire [`WORD_BUS]    ALU_inst1_logicres;
    wire [`WORD_BUS]    ALU_inst1_arithres;
    wire [`WORD_BUS]    ALU_inst1_shiftres;
    wire [`WORD_BUS]    ALU_inst2_logicres;
    wire [`WORD_BUS]    ALU_inst2_arithres;
    wire [`WORD_BUS]    ALU_inst2_shiftres;

    wire [`REG_BUS]     hilo_out;
    wire [`WORD_BUS]    cp0_rdata;
    wire                ov;

    assign inst1_memtype_o  = inst1_memtype_i;
    assign inst1_mreg_o     = inst1_mreg_i;
    assign inst1_whilo_o    = inst1_whilo_i;
    assign inst1_wreg_o     = inst1_wreg_i;
    assign inst1_aluop_o    = inst1_aluop_i;
    assign inst1_wa_o       = inst1_wa_i;
    assign inst1_w2ramdata_o      = inst1_w2ramdata_i;
    assign inst2_memtype_o  = inst2_memtype_i;
    assign inst2_mreg_o     = inst2_mreg_i;
    assign inst2_whilo_o    = inst2_whilo_i;
    assign inst2_wreg_o     = inst2_wreg_i;
    assign inst2_aluop_o    = inst2_aluop_i;
    assign inst2_wa_o       = inst2_wa_i;
    assign inst2_w2ramdata_o      = inst2_w2ramdata_i;

    HILOFward HILOFward0(
        .moveres           (inst1_aluop_i[7]  ),
        .hi                (hilo[63:32]       ),
        .lo                (hilo[31:0]        ),
        .mem2exe_whilo     (mem2exe_whilo     ),
        .mem2exe_hilo      (mem2exe_hilo      ),
        .wb2exe_whilo      (wb2exe_whilo      ),
        .wb2exe_hilo       (wb2exe_hilo       ),
        .mem2exe_is_mthilo (mem2exe_is_mthilo ),
        .wb2exe_is_mthilo  (wb2exe_is_mthilo  ),
        .mem2exe_mthilo    (mem2exe_mthilo    ),
        .wb2exe_mthilo     (wb2exe_mthilo     ),
        .hilo_out          (hilo_out          )
    );

    CP0Fward CP0Fward0(
    	.cp0_addr          (cp0_addr         ),
        .cp0_data_i        (cp0_data_i       ),
        .mem2exe_wc0       (mem2exe_wc0      ),
        .mem2exe_cp0addr   (mem2exe_cp0addr  ),
        .mem2exe_cp0wdata  (mem2exe_cp0wdata ),
        .wb2exe_wc0        (wb2exe_wc0       ),
        .wb2exe_cp0addr    (wb2exe_cp0addr   ),
        .wb2exe_cp0wdata   (wb2exe_cp0wdata  ),
        .cp0rdata          (cp0_rdata         )
    );
    

   ALU ALU1(
        .clk                (clk            ),
        .resetn             (resetn         ),
        .aluop              (inst1_aluop_i  ),
        .src1               (inst1_src1_i   ),
        .src2               (inst1_src2_i   ),
        .ov_enable          (ov_enable      ),

        .ov                 (ov             ),
        .stallreq_exe       (stallreq_exe_o ),
        .logicres           (ALU_inst1_logicres   ),
        .shiftres           (ALU_inst1_shiftres   ),
        .arithres           (ALU_inst1_arithres   ),
        .muldiv_res         (mulres_o       )
    );

   ALU ALU2(
        .clk                (clk            ),
        .resetn             (resetn         ),
        .aluop              (inst2_aluop_i  ),
        .src1               (inst2_src1_i   ),
        .src2               (inst2_src2_i   ),
        .ov_enable          (ov_enable      ),

        .ov                 (ov             ),
        .stallreq_exe       (stallreq_exe_o ),
        .logicres           (ALU_inst2_logicres   ),
        .shiftres           (ALU_inst2_shiftres   ),
        .arithres           (ALU_inst2_arithres   ),
        .muldiv_res         (mulres_o       )
    );


    always @(*) begin
        case (inst1_alutype_i)
        `LOGIC: begin
           ALU_inst1_result = ALU_inst1_logicres;
        end 
        `ARITH: begin
           ALU_inst1_result = ALU_inst1_arithres;
        end
        `SHIFT: begin
           ALU_inst1_result = ALU_inst1_shiftres;
        end
        `MOVE: begin
            ALU_inst1_result = (cp0_re)? cp0_rdata : hilo_out;
        end
        `JUMP:begin
            ALU_inst1_result = iaddr1_p8; 
        end
        default: begin
            ALU_inst1_result = `ZERO_WORD;
        end
        endcase
    end

    always @(*) begin
        case (inst2_alutype_i)
        `LOGIC: begin
           ALU_inst2_result = ALU_inst2_logicres;
        end 
        `ARITH: begin
           ALU_inst2_result = ALU_inst2_arithres;
        end
        `SHIFT: begin
           ALU_inst2_result = ALU_inst2_shiftres;
        end
        `MOVE: begin
            ALU_inst2_result = 0;
        end
        `JUMP:begin
            ALU_inst2_result = 0;
        end
        default: begin
            ALU_inst2_result = `ZERO_WORD;
        end
        endcase
    end


assign exe_exccode = (ov)? `EXC_OV : id_exccode;
endmodule