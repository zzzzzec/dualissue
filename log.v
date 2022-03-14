`include "defines.v"
`timescale 1ns / 1ps

module log(
    input  wire                  clk,
    input  wire                  resetn,
    input wire[`REG_BUS]         inst
    );
reg [31:0]  log1;
reg [31:0]  log2;
reg [31:0]  log3;
reg [31:0]  log4;
reg [31:0]  inst_count;

reg [`REG_BUS] inst_save;
reg  good;
reg  bad;

always @(posedge clk) begin
    if(resetn == `RST_ENABLE) begin
        log1 <= 0;
        log2 <= 0;
        log3 <= 0;
        log4 <= 0;
        inst_save <= 0;
        inst_count <= 0;
        good <= 0;
        bad <= 0;
    end
    else begin
        case (inst)
            `LOG_INST1: begin
                log1 <= log1 + 1;
            end
            `LOG_INST2: begin
                log2 <= log2 + 1;
            end 
            `LOG_INST3: begin
                log3 <= log3 + 1;
            end 
            `LOG_INST4: begin
                log4 <= log4 + 1;
            end  
            `BAD_INST: begin
                bad <= 1;
            end
            `GOOD_INST: begin
                good <= 1;
            end
            default: begin
            end
        endcase
        inst_count <= inst_count + 1;
    end
end

endmodule