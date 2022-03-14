`timescale 1ns / 1ps
`include "defines.v"
`define STATE_FREE 5'b0_0001
`define STATE_ZERO 5'b0_0010
`define STATE_ON 5'b0_0100
`define STATE_END 5'b0_1000
`define STATE_BIGGER 5'b1_0000

`define DIV_WITH 32
`define DOUBLE_DIV_WITH (2*`DIV_WITH)
`define DIV_BUS (`DIV_WITH - 1) : 0
`define DOUBLE_DIV_BUS (`DOUBLE_DIV_WITH - 1 ) : 0
`define DOUBLE_DIV_BUS_HIGH (`DOUBLE_DIV_WITH - 1) : `DIV_WITH
`define DOUBLE_DIV_BUS_LOW  (`DIV_WITH - 1) : 0 
`define CONVERT(x) (~(x) + 1'b1)
/*
    理论：
        1.除法和正负性
            可以发现 若 A ，B 都大于零
            A　 /　 Ｂ　＝　Ｃ．．．ｄ
            －A　 /　 Ｂ　＝　－Ｃ．．．－ｄ
            A　 /　 －Ｂ　＝　－Ｃ．．．ｄ
            －A　 /　 －Ｂ　＝　Ｃ．．．－ｄ
        2.这种做法还有一个问题
            A/B 当 A<B时，除法器会发生错误
            现在先手动解决这个问题
 */

module divider(
    input  wire 				clk,
    input  wire 				resetn,
    input  wire                   div_start,  // 代表开始除法
    input  wire                   is_signed, 
    input  wire[`DIV_BUS]   dividend_i, //被除数
    input  wire[`DIV_BUS]   dividsor_i, //除数

    output reg                     div_0,
    output reg                     div_end,
    output reg  [`DIV_BUS] quotient, //商
    output reg [`DIV_BUS] remainder //余数
    );
// 00 ++ , 01 +- , 10 -- , 11 --
reg [5:0] count;
reg [`DOUBLE_DIV_BUS]  dividend_reg;
reg [`DIV_BUS]  dividsor_reg;
reg [4:0] state; 

//ALU必须是33位才行，才可以记录上结果的正负
wire[`DIV_WITH:0] alu_result;
wire[`DOUBLE_DIV_BUS] shift;
wire[`DIV_BUS] next_remainder;
wire[`DIV_BUS] next_quotient;
reg [`DIV_BUS] dividend_unsign;
reg [`DIV_BUS] dividsor_unsign;

assign shift = dividend_reg << 1;
assign alu_result =  shift[`DOUBLE_DIV_BUS_HIGH] + (~dividsor_reg )  + 1;
assign next_remainder = (alu_result[`DIV_WITH] == 1'b1 ) ? shift[`DOUBLE_DIV_BUS_HIGH] : alu_result; 

assign next_quotient = (alu_result[`DIV_WITH] == 1'b1) ?   shift[`DOUBLE_DIV_BUS_LOW] : 
                                                            (shift[`DOUBLE_DIV_BUS_LOW] | 1'b1);

/*assign  remainder = dividend_reg[`DOUBLE_DIV_BUS_HIGH];
assign  quotient = dividend_reg[`DOUBLE_DIV_BUS_LOW];*/
always @(*) begin
    if(is_signed == 1'b1) begin
        dividend_unsign <= (dividend_i[`DIV_WITH - 1] == 1'b1) ? `CONVERT(dividend_i) : dividend_i;
        dividsor_unsign  <= (dividsor_i[`DIV_WITH - 1] == 1'b1) ? `CONVERT(dividsor_i) : dividsor_i;
    end
    else begin
        dividend_unsign <= dividend_i;
        dividsor_unsign <= dividsor_i;
    end
end

always @(*) begin
    if(is_signed == 1'b1) begin
        case ({dividend_i[`DIV_WITH - 1] , dividsor_i[`DIV_WITH - 1]})
            2'b00 : begin 
                        remainder = dividend_reg[`DOUBLE_DIV_BUS_HIGH];
                        quotient = dividend_reg[`DOUBLE_DIV_BUS_LOW];
            end
            2'b01 :begin              // A　 /　 －Ｂ　＝　－Ｃ．．．ｄ
                       remainder = dividend_reg[`DOUBLE_DIV_BUS_HIGH];
                       quotient = `CONVERT(dividend_reg[`DOUBLE_DIV_BUS_LOW]);
            end
            2'b10 :begin                       // -A　 /　 Ｂ　＝　－Ｃ．．．-ｄ
                        remainder = `CONVERT(dividend_reg[`DOUBLE_DIV_BUS_HIGH]);
                        quotient = `CONVERT(dividend_reg[`DOUBLE_DIV_BUS_LOW]);
            end
            2'b11 :begin                        //－A　 /　 －Ｂ　＝　Ｃ．．．－ｄ
                       remainder = `CONVERT(dividend_reg[`DOUBLE_DIV_BUS_HIGH]);
                       quotient =  dividend_reg[`DOUBLE_DIV_BUS_LOW];
            end
        endcase
    end
    else begin
        remainder = dividend_reg[`DOUBLE_DIV_BUS_HIGH];
        quotient = dividend_reg[`DOUBLE_DIV_BUS_LOW];
    end
end

always @(posedge clk) begin
    if (resetn == `RST_ENABLE) begin
        count <= 0;
        dividend_reg <= 0;
        dividsor_reg <= 0;
        div_0 <= 1'b0;
        div_end <= 1'b0;
        state <= `STATE_FREE;
    end

    case (state)
        `STATE_FREE:begin
                dividend_reg <= {{`DIV_WITH{1'b0}} , dividend_unsign};
                dividsor_reg <= dividsor_unsign;
                count <= 0;
                div_0 <= 1'b0;
                div_end <= 1'b0;
                if((div_start) &&  (!div_end))  begin
                    if(dividsor_unsign > dividend_unsign) begin
                        state <= `STATE_BIGGER;
                    end
                    else begin
                        state <= `STATE_ON;
                    end    
                end
        end
        `STATE_ON: begin
                count <= count  + 1;
                dividend_reg <= {next_remainder , next_quotient};
                if(count  == (`DIV_WITH - 1)) begin
                    div_end <= 1'b1; //end 信号调前一个周期
                    state <= `STATE_FREE;
                end
/*                if(dividsor_unsign == `ZERO_WORD) begin
                    div_0 <= 1'b1;
                end */
        end 
        `STATE_BIGGER: begin
                div_end <= 1'b1;
                dividend_reg <= {dividend_unsign,32'b0};
                state <= `STATE_FREE;
        end

        default: begin
                dividend_reg <= 0;
                dividsor_reg <= 0;
                div_0 <= 0;
                div_end <= 0;
        end
    endcase
    
end

endmodule
