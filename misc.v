`include "defines.v"
`timescale 1ns / 1ps
module EXT(
    input wire        upper,
    input wire        sext,   // 0 -> unsigned 1-> signed
    input wire[`HALF_WORD_BUS]  imm,         
    output  reg[`WORD_BUS] result
);
    reg [`WORD_BUS]     ext_result;
    wire [`WORD_BUS]     shift_result;
   always@(*)   begin
        if(sext)    begin
            ext_result = (imm[15] == 1'b1)? {{16{1'b1}},imm} : {{16{1'b0}},imm};
        end
        else    begin
            ext_result =  {{16{1'b0}},imm};
        end
   end  
    assign shift_result = imm << 16;
    // 0-> ʹ����չ  1-> LUIָ����ظ�λ
  always @(*)   begin
        result = (upper == 1)? shift_result : ext_result;
  end   
endmodule