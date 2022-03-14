`timescale 1ns / 1ps
`include "defines.v"
module SCU(
    input wire              resetn,
    input wire              stallreq_id,
    input wire              stallreq_exe,
    output wire[`STALL_BUS] stall
);
    assign stall =      (resetn         == `RST_ENABLE      ) ? 4'b0000 :
                        (stallreq_exe   == `PIPELINE_STOP   ) ? 4'b1111 :
                        (stallreq_id    == `PIPELINE_STOP   ) ? 4'b0111 : 4'b0000;
endmodule 
