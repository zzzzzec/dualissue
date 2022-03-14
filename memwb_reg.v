`include "defines.v"

module memwb_reg (
    input wire                       	clk,
	input wire                       	resetn,
	input wire [7:0]					mem_memtype,
	input wire                          mem_mreg,
    input wire [1:0]                    mem_whilo,
	input wire                          mem_wreg,
    input wire [`REG_ADDR_BUS  	]     	mem_wa,
    input wire [`DOUBLE_REG_BUS	]   	mem_hilo,
    input wire [`REG_BUS       	] 	    mem_dreg,
    input wire [`BSEL_BUS		]       mem_dre,
	input wire [`INST_BUS		]		mem_pc,
	input wire [1:0]					mem_is_mthilo,
	input wire  						mem_wc0,
	input wire [`REG_ADDR_BUS	]		mem_cp0addr,
    input wire [`WORD_BUS       ]   	mem_cp0wdata,	
	input wire   						flush,
	input wire [`WORD_BUS		]		mem_daddr,

	output reg [7:0]					wb_memtype,
    output reg                          wb_mreg,
    output reg [1:0]                    wb_whilo,
    output reg                       	wb_wreg,
	output reg [`REG_ADDR_BUS  	]     	wb_wa,
	output reg [`REG_BUS       	]       wb_dreg,
	output reg [`DOUBLE_REG_BUS	]       wb_hilo,
    output reg [`BSEL_BUS		]       wb_dre,
	output reg [`INST_BUS		]		wb_pc,
	output reg [1:0]					wb_is_mthilo,
	output reg  						wb_wc0,
	output reg [`REG_ADDR_BUS	]		wb_cp0addr,
    output reg [`WORD_BUS       ]   	wb_cp0wdata,
	output reg [`WORD_BUS		]		wb_daddr
    );

    always @(posedge clk) begin
		// ��λ��ʱ������д�ؽ׶ε���Ϣ��0
		if (resetn == `RST_ENABLE || flush) begin
			wb_memtype 		<= 	8'b0000_0000;
		    wb_whilo     	<=	2'b00;
		    wb_wreg      	<= 	`WRITE_DISABLE;
			wb_wa 	      	<= 	`REG_NOP;
			wb_dreg      	<= 	`ZERO_WORD;
			wb_dre        	<=  4'b0;
			wb_hilo        	<=  `ZERO_DWORD;		    
			wb_mreg     	<= 	`WRITE_DISABLE;
			wb_pc 			<= 	`ZERO_WORD;
			wb_is_mthilo 	<=	2'b0;
			wb_wc0			<= 	1'b0;
			wb_cp0addr		<=	5'b0;
			wb_cp0wdata		<=	`ZERO_WORD;
			wb_daddr 		<=  `ZERO_WORD;
		end
		// �����Էô�׶ε���Ϣ�Ĵ沢����д�ؽ׶�
		else begin
			wb_memtype 		<=	mem_memtype;
		    wb_mreg     	<=	mem_mreg;
		    wb_whilo    	<=	mem_whilo;
		    wb_wreg     	<=	mem_wreg;
			wb_wa 	      	<=	mem_wa;
			wb_dreg     	<=	mem_dreg;
			wb_hilo      	<=	mem_hilo;
            wb_dre       	<=	mem_dre;
			wb_pc 			<=	mem_pc;
			wb_is_mthilo 	<=	mem_is_mthilo;
			wb_wc0			<=	mem_wc0;
			wb_cp0addr		<=  mem_cp0addr;
			wb_cp0wdata		<= 	mem_cp0wdata;
			wb_daddr 		<=  mem_daddr; 
		end
	end

endmodule