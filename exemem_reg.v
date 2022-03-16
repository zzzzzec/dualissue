`include "defines.v"

module exemem_reg (
    input  wire 				clk,
    input  wire 				resetn,

    input wire [`STALL_BUS      ]   stall,
	input wire   					flush,

    input wire[7:0]                 exe_inst1_memtype,
    input wire                      exe_inst1_mreg,                     
    input wire[1:0]                 exe_inst1_whilo,
    input wire                      exe_inst1_wreg,
    input wire [`ALUOP_BUS      ]   exe_inst1_aluop,
    input wire [`REG_ADDR_BUS   ]   exe_inst1_wa,
    input wire [`REG_BUS 	    ]   exe_inst1_wd,
    input wire [`REG_BUS        ]   exe_inst1_din,
    input wire [`INST_BUS       ]   exe_iaddr1,

    input wire[7:0]                 exe_inst2_memtype,
    input wire                      exe_inst2_mreg,                     
    input wire[1:0]                 exe_inst2_whilo,
    input wire                      exe_inst2_wreg,
    input wire [`ALUOP_BUS      ]   exe_inst2_aluop,
    input wire [`REG_ADDR_BUS   ]   exe_inst2_wa,
    input wire [`REG_BUS 	    ]   exe_inst2_wd,
    input wire [`REG_BUS        ]   exe_inst2_din,
    input wire [`INST_BUS       ]   exe_iaddr2,

    input wire [`DOUBLE_WORD_BUS]   exe_mulres,
    input wire [1:0]                exe_is_mthilo,
    input wire                      exe_wc0,
	input wire [`REG_ADDR_BUS	]   exe_cp0addr,
    input wire [`WORD_BUS       ]   exe_cp0wdata,
    input wire [`EXC_CODE_BUS   ]   exe_exe_exccode, 
    input wire                      exe_exe_in_delay,

    output reg [7:0]                mem_inst1_memtype,
    output reg                      mem_inst1_mreg,
    output reg [1:0]                mem_inst1_whilo,
    output reg                      mem_inst1_wreg,
    output reg [`ALUOP_BUS      ]   mem_inst1_aluop,
    output reg [`REG_ADDR_BUS   ]   mem_inst1_wa,
    output reg [`REG_BUS 	    ]   mem_inst1_wd,
    output reg [`REG_BUS        ]   mem_inst1_din,
    output reg [`INST_BUS       ]   mem_iaddr1,

    output reg [7:0]                mem_inst2_memtype,
    output reg                      mem_inst2_mreg,
    output reg [1:0]                mem_inst2_whilo,
    output reg                      mem_inst2_wreg,
    output reg [`ALUOP_BUS      ]   mem_inst2_aluop,
    output reg [`REG_ADDR_BUS   ]   mem_inst2_wa,
    output reg [`REG_BUS 	    ]   mem_inst2_wd,
    output reg [`REG_BUS        ]   mem_inst2_din,
    output reg [`INST_BUS       ]   mem_iaddr2,


    output reg [`DOUBLE_WORD_BUS]   mem_mulres,
    output reg [1:0]                mem_is_mthilo,
    output reg                      mem_wc0,
	output reg [`REG_ADDR_BUS	]	mem_cp0addr,
    output reg [`WORD_BUS       ]   mem_cp0wdata,
    output reg [`EXC_CODE_BUS   ]   mem_exe_exccode,
    output reg                      mem_exe_in_delay
    );

    wire cond;
    assign cond = (resetn == `RST_ENABLE || flush) || (stall[3] == `PIPELINE_STOP);
    always @(posedge clk) begin
    if (cond) begin
        mem_inst1_memtype         <= 8'b0000_0000;
        mem_inst1_mreg            <= `LOAD_ALU;
        mem_inst1_whilo           <= 2'b00;
        mem_inst1_wreg   		    <= `WRITE_DISABLE;
        mem_inst1_aluop           <= `MINIMIPS32_SLL;
        mem_inst1_wa 			    <= `REG_NOP;
        mem_inst1_wd   		    <= `ZERO_WORD;
        mem_inst1_din             <= `ZERO_WORD;
        mem_iaddr1              <= `ZERO_WORD;

        mem_inst2_memtype         <= 8'b0000_0000;
        mem_inst2_mreg            <= `LOAD_ALU;
        mem_inst2_whilo           <= 2'b00;
        mem_inst2_wreg   		    <= `WRITE_DISABLE;
        mem_inst2_aluop           <= `MINIMIPS32_SLL;
        mem_inst2_wa 			    <= `REG_NOP;
        mem_inst2_wd   		    <= `ZERO_WORD;
        mem_inst2_din             <= `ZERO_WORD;
        mem_iaddr2              <= `ZERO_WORD;

        mem_mulres          <= `ZERO_DWORD;
        mem_is_mthilo       <= 2'b0;
        mem_wc0             <= 1'b0;
        mem_cp0addr         <= 5'b0;
        mem_cp0wdata        <= `ZERO_WORD;
        mem_exe_exccode     <= `EXC_NONE;    
        mem_exe_in_delay    <= 1'b0;
    end
    else if(stall[3] == `PIPELINE_NOSTOP)begin
        mem_inst1_mreg              <= exe_inst1_mreg;
        mem_inst1_whilo             <= exe_inst1_whilo;
        mem_inst1_wreg 			    <= exe_inst1_wreg;
        mem_inst1_aluop             <= exe_inst1_aluop;
        mem_inst1_wa 				<= exe_inst1_wa;
        mem_inst1_wd 		    	<= exe_inst1_wd;
        mem_inst1_din               <= exe_inst1_din;
        mem_inst1_memtype           <= exe_inst1_memtype;
        mem_iaddr1                  <= exe_iaddr1;
        mem_inst2_mreg              <= exe_inst2_mreg;
        mem_inst2_whilo             <= exe_inst2_whilo;
        mem_inst2_wreg 			    <= exe_inst2_wreg;
        mem_inst2_aluop             <= exe_inst2_aluop;
        mem_inst2_wa 				<= exe_inst2_wa;
        mem_inst2_wd 		    	<= exe_inst2_wd;
        mem_inst2_din               <= exe_inst2_din;
        mem_inst2_memtype           <= exe_inst2_memtype;
        mem_iaddr2                  <= exe_iaddr2;


        mem_mulres          <= exe_mulres;
        mem_is_mthilo       <= exe_is_mthilo;
        mem_wc0             <= exe_wc0;
        mem_cp0addr         <= exe_cp0addr;
        mem_cp0wdata        <= exe_cp0wdata;
        mem_exe_exccode     <= exe_exe_exccode;
        mem_exe_in_delay    <= exe_exe_in_delay;    
    end
  end

endmodule