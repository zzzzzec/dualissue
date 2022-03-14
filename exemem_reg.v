`include "defines.v"

module exemem_reg (
    input  wire 				clk,
    input  wire 				resetn,

    // ����ִ�н׶ε���Ϣ
    input wire[7:0]                 exe_memtype,
    input wire                      exe_mreg,                     
    input wire[1:0]                 exe_whilo,
    input wire                      exe_wreg,
    input wire [`ALUOP_BUS      ]   exe_aluop,
    input wire [`REG_ADDR_BUS   ]   exe_wa,
    input wire [`DOUBLE_WORD_BUS]   exe_mulres,
    input wire [`REG_BUS 	    ]   exe_wd,
    input wire [`REG_BUS        ]   exe_din,
    input wire [`STALL_BUS      ]   stall,
	input wire   					flush,
    input wire [`INST_BUS       ]   exe_pc,
    input wire [1:0]                exe_is_mthilo,
    input wire                      exe_wc0,
	input wire [`REG_ADDR_BUS	]   exe_cp0addr,
    input wire [`WORD_BUS       ]   exe_cp0wdata,
    input wire [`EXC_CODE_BUS   ]   exe_exe_exccode, 
    input wire                      exe_exe_in_delay,
    // �͵��ô�׶ε���Ϣ 
    output reg [7:0]                mem_memtype,
    output reg                      mem_mreg,
    output reg [1:0]                mem_whilo,
    output reg                      mem_wreg,
    output reg [`ALUOP_BUS      ]   mem_aluop,
    output reg [`REG_ADDR_BUS   ]   mem_wa,
    output reg [`DOUBLE_WORD_BUS]   mem_mulres,
    output reg [`REG_BUS 	    ]   mem_wd,
    output reg [`REG_BUS        ]   mem_din,
    output reg [`INST_BUS       ]   mem_pc,
    output reg [1:0]                mem_is_mthilo,
    output reg                      mem_wc0,
	output reg [`REG_ADDR_BUS	]	mem_cp0addr,
    output reg [`WORD_BUS       ]   mem_cp0wdata,
    output reg [`EXC_CODE_BUS   ]   mem_exe_exccode,
    output reg                      mem_exe_in_delay
    );

    always @(posedge clk) begin
    if (resetn == `RST_ENABLE || flush) begin
        mem_mreg            <= `LOAD_ALU;
        mem_whilo           <= 2'b00;
        mem_wreg   		    <= `WRITE_DISABLE;
        mem_aluop           <= `MINIMIPS32_SLL;
        mem_wa 			    <= `REG_NOP;
        mem_mulres          <= `ZERO_DWORD;
        mem_wd   		    <= `ZERO_WORD;
        mem_din             <= `ZERO_WORD;
        mem_memtype         <= 8'b0000_0000;
        mem_pc              <= `ZERO_WORD;
        mem_is_mthilo       <= 2'b0;

        mem_wc0             <= 1'b0;
        mem_cp0addr         <= 5'b0;
        mem_cp0wdata        <= `ZERO_WORD;
        mem_exe_exccode     <= `EXC_NONE;    

        mem_exe_in_delay    <= 1'b0;
    end
    else if (stall[3] == `PIPELINE_STOP) begin
        mem_mreg            <= `LOAD_ALU;
        mem_whilo           <= 2'b00;
        mem_wreg   	        <= `WRITE_DISABLE;
        mem_aluop           <= `MINIMIPS32_SLL;
        mem_wa 			    <= `REG_NOP;
        mem_mulres          <= `ZERO_DWORD;
        mem_wd   		    <= `ZERO_WORD;
        mem_din             <= `ZERO_WORD;
        mem_memtype         <= 8'b0000_0000;
        mem_pc              <= `ZERO_WORD;
        mem_is_mthilo       <= 2'b0;

        mem_wc0             <= 1'b0;
        mem_cp0addr         <= 5'b0;
        mem_cp0wdata        <= `ZERO_WORD;
        mem_exe_exccode     <= `EXC_NONE;  

        mem_exe_in_delay    <= 1'b0;  
    end
    else if(stall[3] == `PIPELINE_NOSTOP)begin
        mem_mreg            <= exe_mreg;
        mem_whilo           <= exe_whilo;
        mem_wreg 			<= exe_wreg;
        mem_aluop           <= exe_aluop;
        mem_wa 				<= exe_wa;
        mem_mulres          <= exe_mulres;
        mem_wd 		    	<= exe_wd;
        mem_din             <= exe_din;
        mem_memtype         <= exe_memtype;
        mem_pc              <= exe_pc;
        mem_is_mthilo       <= exe_is_mthilo;

        mem_wc0             <= exe_wc0;
        mem_cp0addr         <= exe_cp0addr;
        mem_cp0wdata        <= exe_cp0wdata;
        mem_exe_exccode     <= exe_exe_exccode;

        mem_exe_in_delay    <= exe_exe_in_delay;    
    end
  end

endmodule