`include "defines.v"
`timescale 1ns / 1ps
//HILO �Ĵ����ڶ�ȡ���ݵ�ʱ��������������Դ
// 1 : ����HILO�Ĵ�������
// 2 : ����mem�׶�
// 3 : ����wb�׶�
// ʹ�õ����ȼ�Ϊ mem > wb > ����
module HILO_reg(
    input wire 				clk,
    input wire 				resetn,
    input wire [1:0] 	    we,
    input wire [`REG_BUS] 	lo_i,
    input wire [`REG_BUS] 	hi_i,
	
    output wire [`DOUBLE_WORD_BUS]   hilo_o
    );
reg [`REG_BUS]  HI;
reg [`REG_BUS]  LO;

//дֻ������ ʱ��������
always @(posedge clk) begin
		if (resetn == `RST_ENABLE) begin
		      HI <= `ZERO_WORD;
		      LO <= `ZERO_WORD;
		end
		else begin
			HI <= (we[1] == `WRITE_ENABLE)? hi_i : HI;
			LO <= (we[0] == `WRITE_ENABLE)? lo_i : LO;
		end
end
assign hilo_o = {HI,LO}; 

endmodule
