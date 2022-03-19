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
    output 	wire [`INST_ADDR_BUS]	iaddr,
    output  wire [`EXC_CODE_BUS ]   pc_exccode,
    output  wire                    we
);

    reg  [`INST_ADDR_BUS] 	    pc;
    wire [`INST_ADDR_BUS]       pc_plus4 = pc + 4;
    reg  ce;
    reg  ib_we;
    assign we = ib_we;

    wire jmp_take = jtsel_i[0] | jtsel_i[1];

    assign  iaddr  = pc;
    assign  pc_exccode = (`WORD_NOT_ALIGN(pc)) ? `EXC_AdEL : `EXC_NONE;

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
            ib_we <= 1;                 
        end
        else begin
            if(flush) begin
                pc <= cp0_excaddr;
            end
            else if(stall[0] == `PIPELINE_NOSTOP) begin
                    if(jmp_take)    ib_we <= 0;
                    else ib_we      <= 1;

                    case(jtsel_i)
                        2'b00 : pc <= pc_plus4;
                        2'b01:  pc <= jmp_addr1_i;
                        2'b10:  pc <= jmp_addr3_i;
                        2'b11:  pc <= jmp_addr2_i;
                    endcase               
            end
        end
    end

endmodule