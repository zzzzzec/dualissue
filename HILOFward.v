`include "defines.v"
`timescale 1ns / 1ps
/* 
    ?????????????HILO?????????
    ??????HILO??????????????????????
    1.??????????????
    2.????MULT????DIV??????????mem????wb??¦Å???????????????64bit??
    3.????MTLO??MTHI???????????????MEM????WB??????????????32bit??
    
    mem phrase has more priority than wb phrase
*/
module HILOFward(
    input wire                      moveres,
    input wire[`WORD_BUS]           hi,
    input wire[`WORD_BUS]           lo, 
    input wire[1:0]                 mem2exe_whilo,
    input wire[`DOUBLE_WORD_BUS]    mem2exe_hilo,
    input wire[1:0 ]                wb2exe_whilo,
    input wire[`DOUBLE_WORD_BUS]    wb2exe_hilo,
    input wire[1:0]                 mem2exe_is_mthilo,
    input wire[1:0]                 wb2exe_is_mthilo,
    input wire[`REG_BUS]            mem2exe_mthilo,
    input wire[`REG_BUS]            wb2exe_mthilo,    
    output wire[`REG_BUS]           hilo_out                      
    );
reg[`REG_BUS] hi_fward;
reg[`REG_BUS] lo_fward;

always @(*) begin
    if(mem2exe_whilo[1] == 1'b1) begin
        hi_fward = (mem2exe_is_mthilo[1] == 1)? mem2exe_mthilo : mem2exe_hilo[63:32];
    end
    else begin
        if(wb2exe_whilo[1] == 1'b1) begin
            hi_fward = (wb2exe_is_mthilo[1] == 1)? wb2exe_mthilo : wb2exe_hilo[63:32];
        end
        else begin
            hi_fward = hi;    
        end
    end  
end

always @(*) begin
    if(mem2exe_whilo[0] == 1'b1) begin
        lo_fward = (mem2exe_is_mthilo[0] == 1)? mem2exe_mthilo : mem2exe_hilo[31:0];
    end
    else begin
        if(wb2exe_whilo[0] == 1'b1) begin
            lo_fward = (wb2exe_is_mthilo[0] == 1)? wb2exe_mthilo : wb2exe_hilo[31:0];
        end
        else begin
            lo_fward = lo;
        end
    end
  
end
assign hilo_out = (moveres == 1) ? hi_fward : lo_fward; 
endmodule
