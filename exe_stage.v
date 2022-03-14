`include "defines.v"

module exe_stage (
    input wire                      clk,
    input wire                      resetn,
    input wire [7:0]                memtype_i,
    input wire                      mreg_i,
    input wire [1:0]                whilo_i,
    input wire 					    wreg_i,
    input wire [`ALUTYPE_BUS	] 	alutype_i,
    input wire [`ALUOP_BUS	    ] 	aluop_i,
    input wire [`REG_ADDR_BUS 	] 	wa_i,
    input wire [`REG_BUS 		] 	src1_i,
    input wire [`REG_BUS 		] 	src2_i,
    input wire [`REG_BUS        ]   din_i,
    input wire [`REG_BUS        ]   pcPlus8,
    input wire                      ov_enable,
    input wire [`EXC_CODE_BUS   ]   id_exccode,   
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

    output wire [7:0]               memtype_o,
    output wire                     stallreq_exe_o,
    output wire                     mreg_o,
    output wire [1:0]               whilo_o,
    output wire                     wreg_o,
    output wire [`ALUOP_BUS	    ] 	aluop_o,
    output wire [`REG_ADDR_BUS 	] 	wa_o,
    output wire [`DOUBLE_WORD_BUS]  mulres_o,
    output reg  [`WORD_BUS      ]   alu_result_o,
    output wire [`REG_BUS       ]   din_o,
    output wire [`EXC_CODE_BUS  ]   exe_exccode
    );
/*===================================*/
/*                         ALU����ź�                                          */
    wire [`WORD_BUS]    ALU_logicres;
    wire [`WORD_BUS]    ALU_arithres;
    wire [`WORD_BUS]    ALU_shiftres;
/*===================================*/
    wire [`REG_BUS]     hilo_out;
    wire [`WORD_BUS]    cp0_rdata;
    wire                ov;

    assign memtype_o = memtype_i;
    assign mreg_o = mreg_i;
    assign whilo_o = whilo_i;
    assign wreg_o = wreg_i;
    assign aluop_o = aluop_i;
    assign wa_o  = wa_i;
    assign din_o = din_i;

    HILOFward HILOFward0(
        .moveres           (aluop_i[7]        ),
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
    

   ALU ALU0(
        .clk        (clk    ),
        .resetn          (resetn      ),
        .aluop              (aluop_i        ),
        .src1               (src1_i         ),
        .src2               (src2_i         ),
        .ov_enable          (ov_enable      ),

        .ov                 (ov             ),
        .stallreq_exe       (stallreq_exe_o ),
        .logicres           (ALU_logicres   ),
        .shiftres           (ALU_shiftres   ),
        .arithres           (ALU_arithres   ),
        .muldiv_res         (mulres_o       )
    );

    always @(*) begin
        case (alutype_i)
        `LOGIC: begin
           alu_result_o = ALU_logicres;
        end 
        `ARITH: begin
           alu_result_o = ALU_arithres;
        end
        `SHIFT: begin
           alu_result_o = ALU_shiftres;
        end
        `MOVE: begin
            alu_result_o = (cp0_re)? cp0_rdata : hilo_out;
        end
        `JUMP:begin
            alu_result_o = pcPlus8; 
        end
        default: begin
            alu_result_o = `ZERO_WORD;
        end
        endcase
    end
assign exe_exccode = (ov)? `EXC_OV : id_exccode;
endmodule