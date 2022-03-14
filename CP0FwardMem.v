`timescale 1ns / 1ps
`include "defines.v"
/*
    we read casue and status register only
*/
module CP0FwardMem(
    input wire[`WORD_BUS    ]       casue_i,
    input wire[`WORD_BUS    ]       status_i,
    input wire                      wb2mem_cp0we,
    input wire[`CP0_ADDR_BUS]       wb2mem_cp0waddr,
    input wire[`WORD_BUS    ]       wb2mem_cp0wdata,

    output reg[`WORD_BUS    ]       cause_o,
    output reg[`WORD_BUS    ]       status_o 
    );
always @(*) begin
    if(wb2mem_cp0we && wb2mem_cp0waddr == `Cause ) begin
        cause_o  = wb2mem_cp0wdata;
        status_o = status_i;
    end
    else begin
        if(wb2mem_cp0we && wb2mem_cp0waddr == `Status ) begin
            cause_o  = casue_i;
            status_o = wb2mem_cp0wdata;
        end
        else begin
            cause_o  = casue_i;
            status_o = status_i;
        end
    end
end

endmodule
