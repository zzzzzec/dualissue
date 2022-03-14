`include "defines.v"

module idexe_reg (
    input  wire 		            clk,
    input  wire 				    resetn,

    // ��������׶ε���Ϣ
    input wire[7:0]                 id_memtype, 
    input wire                      id_mreg ,
    input wire[1:0]                 id_whilo,
    input wire                      id_wreg,
    input wire [`ALUTYPE_BUS  ]     id_alutype,
    input wire [`ALUOP_BUS    ]     id_aluop,
    input wire [`REG_BUS      ]     id_src1,
    input wire [`REG_BUS      ]     id_src2,
    input wire [`REG_ADDR_BUS ]     id_wa,    //ָ��rd
    input wire [`REG_BUS      ]     id_din,
    input wire [`REG_BUS      ]     id_pcPlus8,
    input wire [`STALL_BUS    ]     stall,
	input wire   					flush,
    input wire [`INST_BUS     ]     id_pc,
    input wire [1:0]                id_is_mthilo,
    input wire [1:0]                id_rwc0,
	input wire [`REG_ADDR_BUS	]   id_cp0addr,
    input wire                      id_ov_enable,
    input wire [`EXC_CODE_BUS   ]   id_id_exccode,
    input wire                      id_next_delay,
    input wire                      loop_id_in_delay,
    // ����ִ�н׶ε���Ϣ
    output reg [7:0]                exe_memtype,
    output reg                      exe_mreg,
    output reg [1:0]                exe_whilo,
    output reg                      exe_wreg,
    output reg  [`ALUTYPE_BUS  ]    exe_alutype,
    output reg  [`ALUOP_BUS    ]    exe_aluop,
    output reg  [`REG_ADDR_BUS ]    exe_wa,
    output reg  [`REG_BUS      ]    exe_src1,
    output reg  [`REG_BUS      ]    exe_src2,
    output reg  [`REG_BUS      ]    exe_din,
    output reg  [`REG_BUS      ]    exe_pcPlus8,
    output reg  [`INST_BUS     ]    exe_pc,
    output reg  [1:0]               exe_is_mthilo,
    output reg  [1:0]               exe_rwc0,
    output reg  [`REG_ADDR_BUS	]   exe_cp0addr,
    output reg                      exe_ov_enable,
    output reg  [`EXC_CODE_BUS   ]  exe_id_exccode,
    output reg                      exe_next_delay,
    output reg                      exe_id_in_delay
    );

    always @(posedge clk) begin
        // ��λ��ʱ������ִ�н׶ε���Ϣ��0
        if (resetn == `RST_ENABLE || flush) begin
            exe_mreg        <=  `LOAD_ALU;
            exe_whilo       <=  2'b00;
            exe_wreg        <=  `WRITE_DISABLE;
            exe_alutype 	<=  `NOP;
            exe_aluop 	    <=  `MINIMIPS32_SLL;   //?����Ϊʲô��
            exe_wa 			<=  `REG_NOP;
            exe_src1 		<=  `ZERO_WORD;
            exe_src2 		<=  `ZERO_WORD;
            exe_din         <=  `ZERO_WORD;
            exe_pcPlus8     <=  `ZERO_WORD;
            exe_memtype     <=  8'b0000_0000;
            exe_pc          <=  `ZERO_WORD;
            exe_is_mthilo   <=  2'b0;

            exe_rwc0        <=  2'b0;
            exe_cp0addr     <=  5'b0;
            exe_ov_enable   <=  1'b0;
            exe_id_exccode  <=  `EXC_NONE;

            exe_next_delay  <=  1'b0;
            exe_id_in_delay <=  1'b0;
        end
        // ����׶���ͣ��
        else if (stall[2] == `PIPELINE_STOP && stall[3] == `PIPELINE_NOSTOP ) begin
            exe_mreg        <= `LOAD_ALU;
            exe_whilo       <=  2'b0;
            exe_wreg        <= `WRITE_DISABLE;
            exe_alutype 	<= `NOP;
            exe_aluop 	    <= `MINIMIPS32_SLL;   //?����Ϊʲô����Ϊ SLL��op��func�����㣬��ͬ�ڿ�ָ��
            exe_wa 			<= `REG_NOP;
            exe_src1 		<= `ZERO_WORD;
            exe_src2 		<= `ZERO_WORD;
            exe_din         <= `ZERO_WORD;
            exe_pcPlus8     <= `ZERO_WORD;
            exe_memtype     <=   8'b0000_0000;
            exe_pc          <= `ZERO_WORD;
            exe_is_mthilo   <= 2'b0;

            exe_rwc0        <= 2'b0;
            exe_cp0addr     <= 5'b0;
            exe_ov_enable   <=  1'b0;
            exe_id_exccode  <=  `EXC_NONE;

            exe_next_delay  <=  1'b0;
            exe_id_in_delay <=  1'b0;
        end
        // ����������׶ε���Ϣ�Ĵ沢����ִ�н׶�
        else if(stall[2] == `PIPELINE_NOSTOP)begin
            exe_mreg        <= id_mreg;
            exe_whilo       <= id_whilo;
            exe_wreg        <= id_wreg;
            exe_alutype     <= id_alutype;
            exe_aluop       <= id_aluop;      //?����Ϊʲô��
            exe_wa          <= id_wa;
            exe_src1        <= id_src1;
            exe_src2        <= id_src2;
            exe_din         <= id_din;
            exe_pcPlus8     <= id_pcPlus8;
            exe_memtype     <= id_memtype;
            exe_pc          <= id_pc;
            exe_is_mthilo   <= id_is_mthilo;

            exe_rwc0        <= id_rwc0;
            exe_cp0addr     <= id_cp0addr;
            exe_ov_enable   <= id_ov_enable;
            exe_id_exccode  <= id_id_exccode;

            exe_next_delay  <= id_next_delay;
            exe_id_in_delay <= loop_id_in_delay;
        end
    end

endmodule