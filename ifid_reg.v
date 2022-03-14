`include "defines.v"
`define INST_NOP        32'h00000000
module ifid_reg (
	input wire 						clk,
	input wire 						resetn,

	// ����ȡָ�׶ε���Ϣ  
	input wire [`INST_ADDR_BUS	] 	if_pcPlus4,
	//�����ָ��
	input wire [`INST_BUS		] 	inst_in,
	input wire [`STALL_BUS		]	stall,
	input wire   					flush,
	input wire [`INST_BUS		]	pc_i,
	input wire [`EXC_CODE_BUS	]   pc_exccode_i,
	// ��������׶ε`���Ϣ  

	output wire [`INST_BUS		]   inst,
	output reg  [`INST_ADDR_BUS	]   ifid_pcPlus4,
	output reg  [`INST_BUS		]   pc_o,
	output reg  [`EXC_CODE_BUS  ]	pc_exccode_o
	);

always @(posedge clk) begin
	    // ��λ��ʱ����������׶ε���Ϣ��0
		if (resetn == `RST_ENABLE) begin
			   ifid_pcPlus4 <= `ZERO_WORD;
			   pc_o 		<= pc_i;
			   pc_exccode_o <= `EXC_NONE;
		end
		// ������ȡָ�׶ε���Ϣ�Ĵ沢��������׶�
		else if((stall[1] == `PIPELINE_STOP && stall[2] ==  `PIPELINE_NOSTOP) || flush ) begin
			   ifid_pcPlus4 <= `ZERO_WORD;
			   pc_o 		<= `ZERO_WORD;
			   pc_exccode_o <= `EXC_NONE;
	   end
	   else if(stall[1] == `PIPELINE_NOSTOP) begin
		   	   ifid_pcPlus4 <= if_pcPlus4;
			   pc_o 		<= pc_i;
			   pc_exccode_o <= pc_exccode_i;
	   end
end


reg flush_reg;
always @(posedge clk ) begin
	if(resetn == `RST_ENABLE) begin
		flush_reg <= 0;
	end
	else begin	
		flush_reg <= flush;
	end
end
assign inst = (flush_reg == 1'b1)? `INST_NOP : inst_in;
endmodule