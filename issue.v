`include "defines.v"
`timescale 1ns / 1ps

module issue(
    input wire[`INST_BUS    ]           inst1,
    input wire[`INST_BUS    ]           inst2,
    output wire                         issue_mode                         
);
/* 
    single issue : 1. mult, div
                   2. jmp, branch
                   3. waw, raw (we dont have war, read is earlier tan write)
                   4. load, store
*/
    wire[`REG_ADDR_BUS]          rs1;
    wire[`REG_ADDR_BUS]          rt1;
    wire[`REG_ADDR_BUS]          rd1;
    wire[5:0]                    func1;
    wire[5:0]                    op1;

    wire[`REG_ADDR_BUS]          rs2;
    wire[`REG_ADDR_BUS]          rt2;
    wire[`REG_ADDR_BUS]          rd2;
    wire[5:0]                    func2;
    wire[5:0]                    op2;

    assign rs1 = inst1[25:21];
    assign rt1 = inst1[20:16];
    assign rd1 = inst1[15:11];
    assign func1 = inst1[5:0];
    assign op1 = inst1[31:26];

    assign rs2 = inst2[25:21];
    assign rt2 = inst2[20:16];
    assign rd2 = inst2[15:11];
    assign func2 = inst2[5:0];
    assign op2  = inst2[31:26];

    wire waw_relation;
    wire raw_relation;
    assign waw_relation = (rd1 == rd2) ? 1'b1 : 1'b0;
    assign raw_relation = (rd1 == rs2 | rd1 == rt2) ? 1'b1 : 1'b0; 

    wire result1;
    wire result2;

    check_inst check_inst1(
        .op   (op1),
        .func (func1),
        .result (result1)
    );

    check_inst check_inst2(
        .op   (op2),
        .func (func2),
        .result (result2)
    );

    assign issue_mode =     (result1 | result2          ) ? `SINGLE_ISSUE :
                            (waw_relation | raw_relation) ? `SINGLE_ISSUE : `DUAL_ISSUE;


endmodule

module check_inst(
	input wire[5:0]			  op,
	input wire[5:0]			  func,

    output wire               result
);

    wire inst_reg = ~|op;

    wire inst_mult  = inst_reg & (~func[5]) & (func[4]) & (func[3]) & (~func[2]) & (~func[1]) & (~func[0]);
    wire inst_multu = inst_reg & (~func[5]) & (func[4]) & (func[3]) & (~func[2]) & (~func[1]) & (func[0]);
    wire inst_div   = inst_reg & (~func[5]) & (func[4]) & (func[3]) & (~func[2]) & (func[1]) & (~func[0]);
    wire inst_divu  = inst_reg & (~func[5]) & (func[4]) & (func[3]) & (~func[2]) & (func[1]) & (func[0]);

    wire inst_lb  = (op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (~op[1]) & (~op[0]);
    wire inst_lbu =  (op[5]) & (~op[4]) & (~op[3]) & (op[2]) & (~op[1]) & (~op[0]);
    wire inst_lh  =  (op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (~op[1]) & (op[0]);
    wire inst_lhu =  (op[5]) & (~op[4]) & (~op[3]) & (op[2]) & (~op[1]) & (op[0]);
    wire inst_lw  = (op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (op[1]) & (op[0]);
    wire inst_sb  = (op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (~op[1]) & (~op[0]);
    wire inst_sh  = (op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (~op[1]) & (op[0]);
    wire inst_sw  = (op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (op[1]) & (op[0]);

    wire inst_jal  =  (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (op[1]) & (op[0]);
    wire inst_j    =    (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (op[1]) & (~op[0]);
    wire inst_jr   = inst_reg & (~func[5]) & (~func[4]) & (func[3]) & (~func[2]) & (~func[1]) & (~func[0]);
    wire inst_jalr = inst_reg & (~func[5]) & (~func[4]) & (func[3]) & (~func[2]) & (~func[1]) & (func[0]);
    wire inst_beq  = (~op[5]) & (~op[4]) & (~op[3]) & (op[2])  & (~op[1]) & (~op[0]);
    wire inst_bne  = (~op[5]) & (~op[4]) & (~op[3]) & (op[2])  & (~op[1]) & (op[0]);	
    wire inst_bgtz = (~op[5]) & (~op[4]) & (~op[3]) & (op[2])  & (op[1])  & (op[0]);	
    wire inst_blez = (~op[5]) & (~op[4]) & (~op[3]) & (op[2])  & (op[1])  & (~op[0]);	
    wire inst_bgez_group  = (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (~op[1]) & (op[0]);	

    assign result = inst_mult | inst_multu | inst_div  | inst_divu | 
                    inst_lb | inst_lbu| inst_lh | inst_lhu| inst_lw | 
                    inst_sb | inst_sh | inst_sw| 
                    inst_jal  | inst_j | inst_jr   | inst_jalr | 
                    inst_beq  | inst_bne  | inst_bgtz | inst_blez | inst_bgez_group;
endmodule