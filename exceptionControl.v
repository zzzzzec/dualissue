`timescale 1ns / 1ps
`include "defines.v"
// this module will detech interuption and send exccode
module exceptionControl(
    input wire[`EXC_CODE_BUS]  exccode,
    input wire[`WORD_BUS    ]  cause,
    input wire[`WORD_BUS    ]  status,

    output reg[`EXC_CODE_BUS] cp0_exccode   
    );
always @(*) begin
    if(status[`STATUS_EXL] == 0 && status[`STATUS_IE] == 1 && (status[15:8]&cause[15:8] != 8'h00)) begin
        cp0_exccode <= `EXC_INT;
    end
    else begin
        cp0_exccode <= exccode;
    end
end
endmodule
