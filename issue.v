`include "defines.v"
`timescale 1ns / 1ps

module issue(
    input wire                          resetn,
    input wire                          div_mult,
    input wire                          load_store,
    input wire                          jmp_branch,

    input wire[`REG_ADDR_BUS]         rd1,
    input wire[`REG_ADDR_BUS]         rs1,
    input wire[`REG_ADDR_BUS]         rt1,
    input wire                          inst1_wreg,

    input wire[`REG_ADDR_BUS]         rd2,
    input wire[`REG_ADDR_BUS]         rs2,
    input wire[`REG_ADDR_BUS]         rt2,
    input wire                          inst2_wreg,
    input wire                          inst2_rreg1,
    input wire                          inst2_rreg2,

    output wire[1:0]                         issue_mode                         
);

/* 
    single issue : 1. mult, div
                   2. jmp, branch
                   3. waw, raw (we dont have war, read is earlier tan write)
                   4. load, store
*/
    wire waw = ((rd1 == rd2) & (inst1_wreg == `WRITE_ENABLE) & (inst2_wreg == `WRITE_ENABLE) & rd1 != 0 & rd2 != 0) ? 1'b1 : 1'b0;
    wire raw =  ((rd1 == rs2) & (inst2_rreg1 == `READ_ENABLE) & (inst1_wreg == `WRITE_ENABLE) & rd1 != 0) ? 1'b1 :
                ((rd1 == rt2) & (inst2_rreg2 == `READ_ENABLE) & (inst1_wreg == `WRITE_ENABLE) & rd1 != 0) ? 1'b1 : 1'b0;

    assign issue_mode = (resetn == `RST_ENABLE ) ?  `DUAL_ISSUE :
                        (div_mult | jmp_branch | load_store | waw | raw ) ? `SINGLE_ISSUE : `DUAL_ISSUE;
endmodule