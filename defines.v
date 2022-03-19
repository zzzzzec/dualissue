`timescale 1ns / 1ps

/*------------------- ȫ�ֲ��� -------------------*/
`define RST_ENABLE      1'b0                
`define RST_DISABLE     1'b1                
`define ZERO_WORD       32'h00000000        
`define ZERO_DWORD      64'b0               
`define WRITE_ENABLE    1'b1                
`define WRITE_DISABLE   1'b0                
`define READ_ENABLE     1'b1                
`define READ_DISABLE    1'b0                
`define ALUOP_BUS       7 : 0               
`define SHIFT_ENABLE    1'b1                
`define ALUTYPE_BUS     2 : 0               
`define TRUE_V          1'b1                
`define FALSE_V         1'b0                
`define CHIP_ENABLE     1'b1                
`define CHIP_DISABLE    1'b0                
`define WORD_BUS        31: 0               
`define DOUBLE_REG_BUS  63: 0               
`define RT_ENABLE       1'b1                
`define SIGNED_EXT      1'b1                
`define IMM_ENABLE      1'b1                
`define UPPER_ENABLE    1'b1                
`define MREG_ENABLE     1'b1                
`define BSEL_BUS        3 : 0               
//`define PC_INIT         32'hBFC00000        
`define PC_INIT         32'hBFBF_FFFC       
//`define PC_INIT              32'h00000000
//`define PC_INIT                 32'hffff_fffc       
`define DOUBLE_WORD_BUS 63:0
`define HALF_WORD_BUS   15:0
`define INST_INDEX_BUS  25:0

`define LOAD_RAM        1'b1
`define LOAD_ALU        1'b0

`define ALU_INST_BUS    2:0

`define INST_ADDR_BUS   31: 0            
`define INST_BUS        31: 0            
`define INST_INIT       32'h00000000     



/*------------------- ָinstBuffer -------------------*/
`define INST_BUFFER_SIZE 8
`define ISNT_BUFFER_SIZElog2 3

`define INIT_ISSUE 2'b00
`define DUAL_ISSUE 2'b11
`define SINGLE_ISSUE 2'b10


`define NOP             3'b000
`define ARITH           3'b001
`define LOGIC           3'b010
`define SHIFT           3'b100
`define MOVE            3'b011
`define JUMP            3'b101
/*----------------------------DCU------------------------------------*/
`define ALL_and_INST 		(inst_and | inst_andi)
`define ALL_or_INST       	(inst_or | inst_ori )
`define ALL_xor_INST 	  	(inst_xor | inst_xori )
`define ALL_add_INST     	(inst_add  | inst_addi | inst_addu | inst_addiu)
`define ALL_sub_INST 	  	(inst_sub | inst_subu )
`define ALL_slt_INST 		(inst_slt | inst_slti | inst_sltu | inst_sltiu)
`define ALL_jmp_INST	  	(inst_j | inst_jal | inst_jr | inst_jalr) 
`define ALL_bne_INST 	  	(inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez |\
							 inst_bltz | inst_bgezal | inst_bltzal)

`define ALL_ARITH_INST  	(`ALL_add_INST | `ALL_sub_INST | `ALL_slt_INST )
`define ALL_LOGIC_INST 		(inst_and | inst_andi | inst_nor | inst_or | inst_ori | inst_xor | inst_xori)
`define ALL_SHIFT_INST  	(inst_sll | inst_sllv | inst_sra | inst_srav | inst_srl | inst_srlv )
`define ALL_LMEM_INST 		(inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw )
`define ALL_SMEM_INST 		(inst_sb | inst_sh | inst_sw)
`define ALL_MEM_INST   		(`ALL_LMEM_INST | `ALL_SMEM_INST) 
`define ALL_IMM_INST    	(inst_addi | inst_addiu | inst_slti | inst_sltiu | inst_andi | inst_lui | inst_ori | inst_xori )
`define ALL_INST 			(inst_add    |inst_addi  |inst_addu |inst_addiu | \
							inst_sub    |inst_subu  |		\
							inst_slt    |inst_slti  |inst_sltu |inst_sltiu |\
							inst_mult   |inst_multu |inst_div  |inst_divu |\
							inst_and    |inst_andi  |inst_lui  |\
							inst_nor    |inst_or    |inst_ori  |inst_xor  |inst_xori    |\
							inst_sll    |inst_sllv  |inst_sra  |inst_srav   |inst_srl  |inst_srlv    |\
							inst_mfhi   |inst_mflo  |inst_mthi |inst_mtlo |\
							inst_lb     |inst_lbu   |inst_lh   |inst_lhu   |inst_lw   |\
							inst_sb     |inst_sh    |inst_sw   |\
							inst_jal    |inst_j     |inst_jr   |inst_jalr   |\
							inst_beq    |inst_bne   |inst_bgez |inst_bgtz   |\
							inst_blez   |inst_bltz  |inst_bgezal |inst_bltzal |\
							inst_mfc0   |inst_mtc0  |inst_syscall|inst_eret   |inst_break)

`define ALUOP_NOR       8'b0000_0111
`define ALUOP_AND       8'b0000_1011
`define ALUOP_OR        8'b0000_1111
`define ALUOP_XOR       8'b0001_0011

`define ALUOP_MTHI      8'b0001_1111     
`define ALUOP_LUI       8'b0001_0111

`define ALUOP_ADD       8'b0000_0101
`define ALUOP_SUB       8'b0000_1001
`define ALUOP_UNSLT     8'b0000_1101
`define ALUOP_SLT       8'b0001_0001

`define ALUOP_SLL       8'b0000_0110 
`define ALUOP_SRA       8'b0000_1010 
`define ALUOP_SRL       8'b0000_1110 

`define ALUOP_UNMUL     8'b0000_0100
`define ALUOP_MUL       8'b0000_1000
`define ALUOP_UNDIV     8'b0000_1100
`define ALUOP_DIV       8'b0001_0000

`define MINIMIPS32_SLL     `ALUOP_SLL  

`define HALFWORD_NOT_ALIGN(daddr)       (daddr[0])
`define WORD_NOT_ALIGN(daddr)           (daddr[1]|daddr[0])     

`define REG_BUS         31: 0               
`define REG_ADDR_BUS    4 : 0               
`define REG_NUM         32                  
`define REG_NOP         5'b00000            


`define STALL_BUS       3:0        
`define PIPELINE_STOP   1'b1
`define PIPELINE_NOSTOP 1'b0

`define DUC_fwrd_BUS	   4:0
`define DCU_fwrd_inst1_exe 5'b00001
`define DCU_fwrd_inst2_exe 5'b00010
`define DCU_fwrd_inst1_mem 5'b00100
`define DCU_fwrd_inst2_mem 5'b01000
`define DCU_fwrd_no 	   5'b10000

/*---------------------CP0----------------------------------------*/
`define CP0_ADDR_BUS 4:0
/*--------------CP0 reg-----------*/
`define BadVaddr    8
`define Status      12
`define Cause       13
`define EPC         14

`define CAUSE_EXCCODE 6:2
`define STATUS_EXL  1
`define STATUS_IE   0
`define CAUSE_BD 	31
/*---------------ExcCode-----------*/

`define EXC_CODE_BUS    4:0
`define EXC_INT         5'h00
`define EXC_SYS         5'h08
`define EXC_OV          5'h0c
`define EXC_NONE        5'h10
`define EXC_ERET        5'h11
`define EXC_BREAK       5'h09
`define EXC_AdEL        5'h04
`define EXC_AdES        5'h05
`define EXC_RI          5'h0a

`define EXC_ADDR        32'hbfc0_0380
`define EXC_INT_ADDR    32'hbfc0_0380
/*----------------------log---------------------------*/
`define LOG_INST1        32'h34001111
`define LOG_INST2        32'h34002222
`define LOG_INST3        32'h34003333
`define LOG_INST4        32'h34004444

`define BAD_INST        32'h34007777
`define GOOD_INST       32'h34008888


`define CONF_CONVERT_CONDITION 32'hbfaf_0000
`define CONF_CONVERT_CONDITION_WB 32'h1faf_0000
`define CONF_ADDR_MASK 32'hffff_0000


//`define USE_LOG
/* 
    if not define CONVERSE_WRITEDATA , data will be wiretten to DARA RAM directly  -> little endian
    default LITTLE_ENDIAN
	confreg now is not coupled with dataram
*/
`define TESTASM
//`define TESTC 

`ifdef TESTC
//`define CONVERSE_CONFREG 
//`define CONVERSE_READ_DATA
//`define CONVERSE_WRITEDATA
`endif 

`ifdef TESTASM
    `define CONVERSE_INST
    //`define CONVERSE_CONFREG 
    `define BIG_ENDIAN
`endif 

`ifdef BIG_ENDIAN
    `define CONVERSE_READ_DATA
    `define CONVERSE_WRITEDATA
`endif




//misc 

            
