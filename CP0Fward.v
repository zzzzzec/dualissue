`include "defines.v"
`timescale 1ns / 1ps

module CP0Fward(
    input wire[`REG_ADDR_BUS]   cp0_addr,                  
    input wire[`WORD_BUS    ]   cp0_data_i,

    input wire                  mem2exe_wc0,
    input wire[`REG_ADDR_BUS]   mem2exe_cp0addr,
    input wire[`WORD_BUS    ]   mem2exe_cp0wdata,
    input wire                  wb2exe_wc0,
    input wire[`REG_ADDR_BUS]   wb2exe_cp0addr,
    input wire[`WORD_BUS    ]   wb2exe_cp0wdata,

    output reg[`WORD_BUS    ]   cp0rdata
    );

always @(*) begin
    if(mem2exe_wc0 && mem2exe_cp0addr == cp0_addr) begin
        cp0rdata = mem2exe_cp0wdata;
    end
    else begin
        if(wb2exe_wc0 && wb2exe_cp0addr == cp0_addr) begin
            cp0rdata = wb2exe_cp0wdata;
        end
        else begin
            cp0rdata = cp0_data_i;
        end
    end
end

endmodule
