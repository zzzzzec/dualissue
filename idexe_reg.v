`include "defines.v"

module idexe_reg (
    input  wire 		            clk,
    input  wire 				    resetn,

    input wire[7:0]                 id_inst1_memtype, 
    input wire                      id_inst1_mreg ,
    input wire[1:0]                 id_inst1_whilo,
    input wire                      id_inst1_wreg,
    input wire [`ALUTYPE_BUS  ]     id_inst1_alutype,
    input wire [`ALUOP_BUS    ]     id_inst1_aluop,
    input wire [`REG_BUS      ]     id_inst1_src1,
    input wire [`REG_BUS      ]     id_inst1_src2,
    input wire [`REG_ADDR_BUS ]     id_inst1_wa,    
    input wire [`REG_BUS      ]     id_inst1_din,
    input wire [`INST_BUS     ]     id_iaddr1,
    input wire [`REG_BUS      ]     id_iaddr1_p8,

    input wire[7:0]                 id_inst2_memtype, 
    input wire                      id_inst2_mreg ,
    input wire[1:0]                 id_inst2_whilo,
    input wire                      id_inst2_wreg,
    input wire [`ALUTYPE_BUS  ]     id_inst2_alutype,
    input wire [`ALUOP_BUS    ]     id_inst2_aluop,
    input wire [`REG_BUS      ]     id_inst2_src1,
    input wire [`REG_BUS      ]     id_inst2_src2,
    input wire [`REG_ADDR_BUS ]     id_inst2_wa,    
    input wire [`REG_BUS      ]     id_inst2_din,
    input wire [`INST_BUS     ]     id_iaddr2,
    input wire [`REG_BUS      ]     id_iaddr2_p8,

    input wire [`STALL_BUS    ]     stall,
	input wire   					flush,
 
    input wire [1:0]                id_is_mthilo,
    input wire [1:0]                id_rwc0,
	input wire [`REG_ADDR_BUS	]   id_cp0addr,
    input wire                      id_ov_enable,
    input wire [`EXC_CODE_BUS   ]   id_id_exccode,
    input wire                      id_next_delay,
    input wire                      loop_id_in_delay,


    output reg [7:0]                exe_inst1_memtype,
    output reg                      exe_inst1_mreg,
    output reg [1:0]                exe_inst1_whilo,
    output reg                      exe_inst1_wreg,
    output reg  [`ALUTYPE_BUS  ]    exe_inst1_alutype,
    output reg  [`ALUOP_BUS    ]    exe_inst1_aluop,
    output reg  [`REG_ADDR_BUS ]    exe_inst1_wa,
    output reg  [`REG_BUS      ]    exe_inst1_src1,
    output reg  [`REG_BUS      ]    exe_inst1_src2,
    output reg  [`REG_BUS      ]    exe_inst1_din,
    output reg  [`INST_BUS     ]    exe_iaddr1,
    output reg  [`REG_BUS      ]    exe_iaddr1_p8,

    output reg [7:0]                exe_inst2_memtype,
    output reg                      exe_inst2_mreg,
    output reg [1:0]                exe_inst2_whilo,
    output reg                      exe_inst2_wreg,
    output reg  [`ALUTYPE_BUS  ]    exe_inst2_alutype,
    output reg  [`ALUOP_BUS    ]    exe_inst2_aluop,
    output reg  [`REG_ADDR_BUS ]    exe_inst2_wa,
    output reg  [`REG_BUS      ]    exe_inst2_src1,
    output reg  [`REG_BUS      ]    exe_inst2_src2,
    output reg  [`REG_BUS      ]    exe_inst2_din,
    output reg  [`INST_BUS     ]    exe_iaddr2,
    output reg  [`REG_BUS      ]    exe_iaddr2_p8,



    output reg  [1:0]               exe_is_mthilo,
    output reg  [1:0]               exe_rwc0,
    output reg  [`REG_ADDR_BUS	]   exe_cp0addr,
    output reg                      exe_ov_enable,
    output reg  [`EXC_CODE_BUS   ]  exe_id_exccode,
    output reg                      exe_next_delay,
    output reg                      exe_id_in_delay
    );

    wire cond;
    assign cond =   (resetn == `RST_ENABLE) || 
                    flush || 
                    (stall[2] == `PIPELINE_STOP && stall[3] == `PIPELINE_NOSTOP); 

    always @(posedge clk) begin
        if (cond) begin
            exe_inst1_mreg          <=  `LOAD_ALU;
            exe_inst1_whilo         <=  2'b00;
            exe_inst1_wreg          <=  `WRITE_DISABLE;
            exe_inst1_alutype 	    <=  `NOP;
            exe_inst1_aluop 	    <=  `MINIMIPS32_SLL;  
            exe_inst1_wa 			<=  `REG_NOP;
            exe_inst1_src1 		    <=  `ZERO_WORD;
            exe_inst1_src2 		    <=  `ZERO_WORD;
            exe_inst1_din           <=  `ZERO_WORD;
            exe_inst1_memtype       <=  8'b0000_0000;
            exe_iaddr1              <=  `ZERO_WORD;
            exe_iaddr1_p8           <=  `ZERO_WORD;

            exe_is_mthilo   <=  2'b0;
            exe_rwc0        <=  2'b0;
            exe_cp0addr     <=  5'b0;
            exe_ov_enable   <=  1'b0;
            exe_id_exccode  <=  `EXC_NONE;
            exe_next_delay  <=  1'b0;
            exe_id_in_delay <=  1'b0;

            exe_inst2_mreg          <=  `LOAD_ALU;
            exe_inst2_whilo         <=  2'b00;
            exe_inst2_wreg          <=  `WRITE_DISABLE;
            exe_inst2_alutype 	    <=  `NOP;
            exe_inst2_aluop 	    <=  `MINIMIPS32_SLL;  
            exe_inst2_wa 			<=  `REG_NOP;
            exe_inst2_src1 		    <=  `ZERO_WORD;
            exe_inst2_src2 		    <=  `ZERO_WORD;
            exe_inst2_din           <=  `ZERO_WORD;
            exe_inst2_memtype       <=  8'b0000_0000;
            exe_iaddr2              <=  `ZERO_WORD;
            exe_iaddr2_p8           <=  `ZERO_WORD;
        end

        else if(stall[2] == `PIPELINE_NOSTOP)begin
            exe_inst1_mreg        <= id_inst1_mreg;
            exe_inst1_whilo       <= id_inst1_whilo;
            exe_inst1_wreg        <= id_inst1_wreg;
            exe_inst1_alutype     <= id_inst1_alutype;
            exe_inst1_aluop       <= id_inst1_aluop;
            exe_inst1_wa          <= id_inst1_wa;
            exe_inst1_src1        <= id_inst1_src1;
            exe_inst1_src2        <= id_inst1_src2;
            exe_inst1_din         <= id_inst1_din;
            exe_inst1_memtype     <= id_inst1_memtype;

            exe_iaddr1               <= id_iaddr1;
            exe_iaddr1_p8     <= id_iaddr1_p8;
            exe_is_mthilo   <= id_is_mthilo;
            exe_rwc0        <= id_rwc0;
            exe_cp0addr     <= id_cp0addr;
            exe_ov_enable   <= id_ov_enable;
            exe_id_exccode  <= id_id_exccode;
            exe_next_delay  <= id_next_delay;
            exe_id_in_delay <= loop_id_in_delay;

            exe_iaddr2            <= id_iaddr2;
            exe_iaddr2_p8         <= id_iaddr2_p8;
            exe_inst2_mreg        <= id_inst2_mreg;
            exe_inst2_whilo       <= id_inst2_whilo;
            exe_inst2_wreg        <= id_inst2_wreg;
            exe_inst2_alutype     <= id_inst2_alutype;
            exe_inst2_aluop       <= id_inst2_aluop;
            exe_inst2_wa          <= id_inst2_wa;
            exe_inst2_src1        <= id_inst2_src1;
            exe_inst2_src2        <= id_inst2_src2;
            exe_inst2_din         <= id_inst2_din;
            exe_inst2_memtype     <= id_inst2_memtype;
        end
    end

endmodule