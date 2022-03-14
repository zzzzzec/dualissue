`include "defines.v"

module if_stage (
    input 	wire 					clk,
    input 	wire 					resetn,
    input   wire [1:0]              jtsel_i,
    input   wire [`INST_BUS ]       jmp_addr1_i,
    input   wire [`INST_BUS ]       jmp_addr2_i,
    input   wire [`INST_BUS ]       jmp_addr3_i,
    input   wire [`STALL_BUS]       stall,
    input   wire                    flush,
    input   wire [`WORD_BUS]        cp0_excaddr,

    input   wire                    instBufferFull,

    output  wire                    ice,
    output  reg  [`INST_ADDR_BUS]   pc_plus4_o,             
    output 	wire [`INST_ADDR_BUS]	iaddr,
    output  wire [`INST_BUS     ]   pc_o,
    output  wire [`EXC_CODE_BUS ]   pc_exccode
);

    reg  [`INST_ADDR_BUS] 	    pc;
    reg  [`INST_ADDR_BUS]       pc_next; 
    wire [`INST_ADDR_BUS]       pc_plus4 = pc + 4;
    assign pc_o = pc;
    always @(*) begin
        pc_plus4_o = pc_plus4;
        case(jtsel_i)
            2'b00 : pc_next = pc_plus4;
            2'b01:  pc_next = jmp_addr1_i;
            2'b10:  pc_next = jmp_addr3_i;
            2'b11:  pc_next = jmp_addr2_i;
        endcase
    end

    reg ce;
    always @(posedge clk) begin
		if (resetn == `RST_ENABLE) begin
			ce <= `CHIP_DISABLE;		
		end 
        else begin
			ce <= `CHIP_ENABLE; 
		end
	end
    assign ice = (  stall[1] == `PIPELINE_NOSTOP && 
                    flush == 1'b0 && 
                    (~`WORD_NOT_ALIGN(pc)) &&
                    (~instBufferFull)) ? ce : 1'b0;
    
    always @(posedge clk) begin
        if (resetn == `RST_ENABLE ) begin
            pc <= `PC_INIT;                 
        end
        else begin
            if(flush) begin
                pc <= cp0_excaddr;
            end
            else if(stall[0] == `PIPELINE_NOSTOP) begin
                pc <= pc_next;                 
            end
        end
    end
    
    assign  iaddr  = pc;
    assign  pc_exccode = (`WORD_NOT_ALIGN(pc)) ? `EXC_AdEL : `EXC_NONE;
endmodule