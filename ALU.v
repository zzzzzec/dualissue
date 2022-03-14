`include "defines.v"
`timescale 1ns / 1ps
                                                                  			                            
module ALU(
	input wire 						clk,		
	input wire  					resetn,
    input wire [`ALUOP_BUS		] 	aluop,
    input wire [`REG_BUS 		] 	src1,
    input wire [`REG_BUS 		] 	src2,
	input wire 						ov_enable,
    
	output reg      				ov,
	output wire 					stallreq_exe,
    output reg [`REG_BUS       ]    logicres,
    output reg [`REG_BUS       ]    shiftres,
    output reg [`REG_BUS       ]    arithres,
    output wire[`DOUBLE_REG_BUS] 	muldiv_res
    );

wire[`DOUBLE_WORD_BUS] 		mulres;
wire[`DOUBLE_WORD_BUS] 		mulres_unsign;
wire[`DOUBLE_WORD_BUS] 		mulres_sign;
wire[`DOUBLE_WORD_BUS] 		divres;
wire						divider_end;

//���Ż�  
assign  mulres_unsign =  $unsigned(src1) * $unsigned(src2);
assign  mulres_sign	  =  $signed(src1)   * $signed(src2);
assign  mulres        = (aluop[5] == 0) ? mulres_unsign : mulres_sign ;
assign  muldiv_res    = (aluop[6] == 1) ? divres  : mulres ;
assign  stallreq_exe  = (divider_end == 1'b1 )? `PIPELINE_NOSTOP :
					    (aluop[6] == 1'b1 ) ? `PIPELINE_STOP : `PIPELINE_NOSTOP;

/*
	overFlow
			
	case1: signed   + signed   -> overflow 
			-(pos + pos = neg ) 
			-(neg + neg = pos ) 

	case2: signed   - signed   -> overflow 
			-(neg - pos = pos)   10->0
			-(pos - neg = neg)	 01->1

	only add,addi,sub will trigger IntegerOverFlow
	so we need add some pin to recognize these instruction
*/
always @(*) begin
if(ov_enable) begin
	case (aluop)
		`ALUOP_ADD: begin
			ov =	((!src1[31])&&(!src2[31])&&(arithres[31]))? 1'b1 : 
					((src1[31])&&(src2[31])&&(!arithres[31]))? 1'b1 : 1'b0 ;
		end
		`ALUOP_SUB: begin
			ov =	((src1[31])&&(!src2[31])&&(!arithres[31]))? 1'b1 : 
					((!src1[31])&&(src2[31])&&(arithres[31]))? 1'b1 : 1'b0 ; 
		end
		default: begin
			ov = 1'b0;
		end
	endcase
end

else begin
	ov = 1'b0;
end
end

//aluop[5] 0->�޷��� 1 ->�з��� 
//aluop[6] 1 -> ���� 0-> �˷�
divider divider0(
	.clk 	(clk 	),
	.resetn      (resetn   	),
	.div_start      (aluop[6]		),
	.is_signed      (aluop[5]		),
	.dividend_i     (src1			),
	.dividsor_i     (src2			),

	.div_0         	(div_0			),
	.div_end        (divider_end    ),
	.quotient       (divres[31:0]	), 
	.remainder      (divres[63:32]	)
);


//������������ֻҪһ����ʱ����ʵӦ�ò���Ҫ��Ϊ0
always@(*) begin
case (aluop)
	`ALUOP_NOR: begin
			logicres = ~(src1 | src2);
			shiftres = `ZERO_WORD;
			arithres = `ZERO_WORD;
	end 
	`ALUOP_AND: begin
			logicres = (src1 & src2);
			shiftres = `ZERO_WORD;
			arithres = `ZERO_WORD;
	end
	`ALUOP_OR:begin
			logicres = (src1 | src2);
			shiftres = `ZERO_WORD;
			arithres = `ZERO_WORD;
	end
	`ALUOP_XOR:begin
			logicres = (src1 ^ src2);
			shiftres = `ZERO_WORD;
			arithres = `ZERO_WORD;
	end
	`ALUOP_LUI: begin
			logicres = src2;
			shiftres = `ZERO_WORD;
			arithres = `ZERO_WORD;
	end 
	`ALUOP_MTHI: begin
			logicres = 	src1;
			shiftres = `ZERO_WORD;
			arithres = `ZERO_WORD;
	end
	`ALUOP_ADD:begin
			logicres = `ZERO_WORD;
			shiftres = `ZERO_WORD;
			arithres = src1 + src2;
	end
	`ALUOP_SUB:begin
			logicres = `ZERO_WORD;
			shiftres = `ZERO_WORD;
			arithres = src1 + (~src2) + 1;
	end
	`ALUOP_UNSLT:begin
			logicres = `ZERO_WORD;
			shiftres = `ZERO_WORD;
			arithres =  ((src1) < (src2))? 1 : 0;
	end
	`ALUOP_SLT:begin
			logicres = `ZERO_WORD;
			shiftres = `ZERO_WORD;
			arithres = ($signed(src1) < $signed(src2))? 1 : 0;
	end
	`ALUOP_SLL:begin  //�߼�����
		    logicres = `ZERO_WORD;
            shiftres =  src2 << src1;
            arithres = `ZERO_WORD;
	end
	// The bit-shift amount is specified by the low-order 5 bits of GPR rs
	`ALUOP_SRA:begin  //��������
			logicres = `ZERO_WORD;
            shiftres =   ($signed(src2)) >>> (src1[4:0]) ;
            arithres = `ZERO_WORD;
	end
	//The bit-shift amount is specified by the low-order 5 bits of GPR rs.
	`ALUOP_SRL:begin //�߼�����
			logicres = `ZERO_WORD;
            shiftres =   src2 >> (src1[4:0]) ;
            arithres = `ZERO_WORD;
	end
	default: begin		
		 	logicres = `ZERO_WORD;
			shiftres = `ZERO_WORD;
			arithres = `ZERO_WORD;
	end
endcase

end
endmodule
