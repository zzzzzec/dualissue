`include "defines.v"

module memwb_reg (
    input wire                       	clk,
	input wire                       	resetn,

	input wire [7:0]					mem_inst1_memtype,
	input wire                          mem_inst1_mreg,
    input wire [1:0]                    mem_inst1_whilo,
	input wire                          mem_inst1_wreg,
    input wire [`REG_ADDR_BUS  	]     	mem_inst1_wa,
    input wire [`DOUBLE_REG_BUS	]   	mem_inst1_hilo,
    input wire [`REG_BUS       	] 	    mem_inst1_w2regdata,
	input wire [`INST_BUS		]		mem_iaddr1,

	input wire [7:0]					mem_inst2_memtype,
	input wire                          mem_inst2_mreg,
    input wire [1:0]                    mem_inst2_whilo,
	input wire                          mem_inst2_wreg,
    input wire [`REG_ADDR_BUS  	]     	mem_inst2_wa,
    input wire [`DOUBLE_REG_BUS	]   	mem_inst2_hilo,
    input wire [`REG_BUS       	] 	    mem_inst2_w2regdata,
	input wire [`INST_BUS		]		mem_iaddr2,

	input wire [`BSEL_BUS		]       mem_dre,
	input wire [1:0]					mem_is_mthilo,
	input wire  						mem_wc0,
	input wire [`REG_ADDR_BUS	]		mem_cp0addr,
    input wire [`WORD_BUS       ]   	mem_cp0wdata,	
	input wire   						flush,
	input wire [`WORD_BUS		]		mem_daddr,

	output reg [7:0]					wb_inst1_memtype,
    output reg                          wb_inst1_mreg,
    output reg [1:0]                    wb_inst1_whilo,
    output reg                       	wb_inst1_wreg,
	output reg [`REG_ADDR_BUS  	]     	wb_inst1_wa,
	output reg [`DOUBLE_REG_BUS	]       wb_inst1_hilo,
	output reg [`REG_BUS       	]       wb_inst1_w2regdata,
	output reg [`INST_BUS		]		wb_iaddr1,

	output reg [7:0]					wb_inst2_memtype,
    output reg                          wb_inst2_mreg,
    output reg [1:0]                    wb_inst2_whilo,
    output reg                       	wb_inst2_wreg,
	output reg [`REG_ADDR_BUS  	]     	wb_inst2_wa,
	output reg [`DOUBLE_REG_BUS	]       wb_inst2_hilo,
	output reg [`REG_BUS       	]       wb_inst2_w2regdata,
	output reg [`INST_BUS		]		wb_iaddr2,

    output reg [`BSEL_BUS		]       wb_dre,
	output reg [1:0]					wb_is_mthilo,
	output reg  						wb_wc0,
	output reg [`REG_ADDR_BUS	]		wb_cp0addr,
    output reg [`WORD_BUS       ]   	wb_cp0wdata,
	output reg [`WORD_BUS		]		wb_daddr
    );

    always @(posedge clk) begin
		if (resetn == `RST_ENABLE || flush) begin
			wb_inst1_memtype 			<= 	8'b0000_0000;
			wb_inst1_mreg     			<= 	`WRITE_DISABLE;
		    wb_inst1_whilo     			<=	2'b00;
		    wb_inst1_wreg      			<= 	`WRITE_DISABLE;
			wb_inst1_wa 	      		<= 	`REG_NOP;
			wb_inst1_hilo        		<=  `ZERO_DWORD;	
			wb_inst1_w2regdata      	<= 	`ZERO_WORD;
			wb_iaddr1 					<= 	`ZERO_WORD;
	    
			wb_inst2_memtype 			<= 	8'b0000_0000;
			wb_inst2_mreg     			<= 	`WRITE_DISABLE;
		    wb_inst2_whilo     			<=	2'b00;
		    wb_inst2_wreg      			<= 	`WRITE_DISABLE;
			wb_inst2_wa 	      		<= 	`REG_NOP;
			wb_inst2_hilo        		<=  `ZERO_DWORD;	
			wb_inst2_w2regdata      	<= 	`ZERO_WORD;
			wb_iaddr2 					<= 	`ZERO_WORD;
	    
			wb_dre        				<=  4'b0;
			wb_is_mthilo 				<=	2'b0;
			wb_wc0						<= 	1'b0;
			wb_cp0addr					<=	5'b0;
			wb_cp0wdata					<=	`ZERO_WORD;
			wb_daddr 					<=  `ZERO_WORD;
		end
		else begin
			wb_inst1_memtype 		<=	mem_inst1_memtype;
		    wb_inst1_mreg     		<=	mem_inst1_mreg;
		    wb_inst1_whilo    		<=	mem_inst1_whilo;
		    wb_inst1_wreg     		<=	mem_inst1_wreg;
			wb_inst1_wa 	      	<=	mem_inst1_wa;
			wb_inst1_hilo      		<=	mem_inst1_hilo;
			wb_inst1_w2regdata     	<=	mem_inst1_w2regdata;
			wb_iaddr1 				<=	mem_iaddr1;

			wb_inst2_memtype 		<=	mem_inst2_memtype;
		    wb_inst2_mreg     		<=	mem_inst2_mreg;
		    wb_inst2_whilo    		<=	mem_inst2_whilo;
		    wb_inst2_wreg     		<=	mem_inst2_wreg;
			wb_inst2_wa 	      	<=	mem_inst2_wa;
			wb_inst2_hilo      		<=	mem_inst2_hilo;
			wb_inst2_w2regdata     	<=	mem_inst2_w2regdata;
			wb_iaddr2 				<=	mem_iaddr2;

            wb_dre       	<=	mem_dre;
			wb_is_mthilo 	<=	mem_is_mthilo;
			wb_wc0			<=	mem_wc0;
			wb_cp0addr		<=  mem_cp0addr;
			wb_cp0wdata		<= 	mem_cp0wdata;
			wb_daddr 		<=  mem_daddr; 
		end
	end

endmodule