`include "defines.v"
// READ DATA FROM DATA RAM
/*
VirtualAddress:
    DataRam         0x8000_0000~0x8003_FFFF     256K        kseg0
    LED             0xBFAF_F000~0xBFAF_F00F     16          kseg1
    SegmentDisplay  0xBFAF_F010~0xBFAF_F01F     16          kseg1
    Switch          0xBFAF_F020~0xBFAF_F02F     16          kseg1

    the Bridge module will map vaddr to paddr

    0x1FAF_xxxx -> confreg
    others      -> dram
    
    so,we should wipe higth 3 bit if we want to read/write confreg
*/
module mem_stage (
    input  wire                         resetn,


    input  wire [`WORD_BUS      ]       mem_iaddr1_i,
    input  wire [`WORD_BUS      ]       mem_iaddr2_i,

    input  wire [`REG_BUS       ]       mem_inst1_w2ramdata_i,
    input  wire [`EXC_CODE_BUS  ]       mem_exe_exccode,
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    //CP0 data
    input wire [`WORD_BUS       ]       casue_i,
    input wire [`WORD_BUS       ]       status_i,
    input wire                          wb2mem_cp0we,
    input wire [`CP0_ADDR_BUS   ]       wb2mem_cp0waddr,
    input wire [`WORD_BUS       ]       wb2mem_cp0wdata,

//  out
    output wire [`BSEL_BUS      ]       dre_o,
    output wire                         dce,
    output wire [`INST_ADDR_BUS ]       daddr,
    output wire [`BSEL_BUS      ]       we_o,
    output reg  [`REG_BUS       ]       din,

    output wire [`EXC_CODE_BUS  ]       cp0_exccode,
    output wire [`WORD_BUS      ]       mem_badaddr,

// pass through
    input  wire [7:0]                   mem_inst1_memtype_i, 
    input  wire                         mem_inst1_mreg_i,
    input  wire [1:0]                   mem_inst1_whilo_i,
    input  wire                         mem_inst1_wreg_i,
    input  wire [`REG_ADDR_BUS  ]       mem_inst1_wa_i,
    input  wire [`DOUBLE_REG_BUS]       mem_inst1_hilo_i,
    input  wire [`REG_BUS       ]       mem_inst1_w2regdata_i,

    input  wire [7:0]                   mem_inst2_memtype_i, 
    input  wire                         mem_inst2_mreg_i,
    input  wire [1:0]                   mem_inst2_whilo_i,
    input  wire                         mem_inst2_wreg_i,
    input  wire [`REG_ADDR_BUS  ]       mem_inst2_wa_i,
    input  wire [`DOUBLE_REG_BUS]       mem_inst2_hilo_i,
    input  wire [`REG_BUS       ]       mem_inst2_w2regdata_i,

    output wire [7:0]                   mem_inst1_memtype_o,   
    output wire                         mem_inst1_mreg_o,
    output wire [1:0]                   mem_inst1_whilo_o,
    output wire                         mem_inst1_wreg_o,
    output wire [`REG_ADDR_BUS  ]       mem_inst1_wa_o,
    output wire [`DOUBLE_REG_BUS]       mem_inst1_hilo_o,
    output wire [`REG_BUS       ]       mem_inst1_w2regdata_o,

    output wire [7:0]                   mem_inst2_memtype_o,   
    output wire                         mem_inst2_mreg_o,
    output wire [1:0]                   mem_inst2_whilo_o,
    output wire                         mem_inst2_wreg_o,
    output wire [`REG_ADDR_BUS  ]       mem_inst2_wa_o,
    output wire [`DOUBLE_REG_BUS]       mem_inst2_hilo_o,
    output wire [`REG_BUS       ]       mem_inst2_w2regdata_o

    );

    assign mem_inst1_memtype_o          =   (resetn == `RST_ENABLE) ?    8'b0    :   mem_inst1_memtype_i;
    assign mem_inst1_mreg_o             =   (resetn == `RST_ENABLE) ?    1'b0    :   mem_inst1_mreg_i;
    assign mem_inst1_whilo_o            =   (resetn == `RST_ENABLE) ?    2'b00   :   mem_inst1_whilo_i;
    assign mem_inst1_wreg_o             =   (resetn == `RST_ENABLE) ?    1'b0    :   mem_inst1_wreg_i;
    assign mem_inst1_wa_o               =   (resetn == `RST_ENABLE) ?    5'b0    :   mem_inst1_wa_i;
    assign mem_inst1_hilo_o             =   (resetn == `RST_ENABLE) ?    64'b0   :   mem_inst1_hilo_i;    
    assign mem_inst1_w2regdata_o        =   (resetn == `RST_ENABLE) ?    1'b0    :   mem_inst1_w2regdata_i;
  
    assign mem_inst2_memtype_o          =   (resetn == `RST_ENABLE) ?    8'b0    :   mem_inst2_memtype_i;
    assign mem_inst2_mreg_o             =   (resetn == `RST_ENABLE) ?    1'b0    :   mem_inst2_mreg_i;
    assign mem_inst2_whilo_o            =   (resetn == `RST_ENABLE) ?    2'b00   :   mem_inst2_whilo_i;
    assign mem_inst2_wreg_o             =   (resetn == `RST_ENABLE) ?    1'b0    :   mem_inst2_wreg_i;
    assign mem_inst2_wa_o               =   (resetn == `RST_ENABLE) ?    5'b0    :   mem_inst2_wa_i;
    assign mem_inst2_hilo_o             =   (resetn == `RST_ENABLE) ?    64'b0   :   mem_inst2_hilo_i;    
    assign mem_inst2_w2regdata_o        =   (resetn == `RST_ENABLE) ?    1'b0    :   mem_inst2_w2regdata_i;
  
   

    wire inst_lb    = mem_inst1_memtype_i[0];
    wire inst_lbu   = mem_inst1_memtype_i[1];
    wire inst_lh    = mem_inst1_memtype_i[2];
    wire inst_lhu   = mem_inst1_memtype_i[3];
    wire inst_lw    = mem_inst1_memtype_i[4];

    wire inst_sb = mem_inst1_memtype_i[5];
    wire inst_sh = mem_inst1_memtype_i[6];
    wire inst_sw = mem_inst1_memtype_i[7];
    
    wire[2:0]  dre_select = {inst_lw , (inst_lh | inst_lhu) , (inst_lb | inst_lbu)} ;
    wire[2:0]  we_select  = {inst_sw , inst_sh , inst_sb};

    assign dce = (resetn == `RST_ENABLE) ? 1'b0 : (`ALL_MEM_INST);

    assign daddr =  (resetn == `RST_ENABLE) ? `ZERO_WORD :
                    (((mem_inst1_w2regdata_i) & (`CONF_ADDR_MASK)) == (`CONF_CONVERT_CONDITION))? {{3{1'b0}},mem_inst1_w2regdata_i[28:0]} : mem_inst1_w2regdata_i;
    
    wire [`WORD_BUS     ]    cause;
    wire [`WORD_BUS     ]    status;
    wire [`EXC_CODE_BUS ]    fin_exccode;

    CP0FwardMem CP0FwardMem0(
    	.casue_i         (casue_i         ),
        .status_i        (status_i        ),
        .wb2mem_cp0we    (wb2mem_cp0we    ),
        .wb2mem_cp0waddr (wb2mem_cp0waddr ),
        .wb2mem_cp0wdata (wb2mem_cp0wdata ),
        .cause_o         (cause           ),
        .status_o        (status          )
    );

    exceptionControl exceptionControl0(
    	.exccode         (fin_exccode       ),
        .cause           (cause             ),
        .status          (status            ),
        .cp0_exccode     (cp0_exccode       )
    );

reg [`BSEL_BUS] we;
reg [`BSEL_BUS] dre;
wire            exc_load_h;
wire            exc_load_w;
wire            exc_store_h;
wire            exc_store_w;

//dre_selecrt = 010 daddr[1:0] = 11 or 01
assign exc_load_h  = (inst_lh | inst_lhu ) & `HALFWORD_NOT_ALIGN(daddr);
assign exc_load_w  = (inst_lw) & `WORD_NOT_ALIGN(daddr);
assign exc_store_h = (inst_sh) & `HALFWORD_NOT_ALIGN(daddr);
assign exc_store_w = (inst_sw) & `WORD_NOT_ALIGN(daddr);

assign fin_exccode =    (exc_load_h  | exc_load_w  ) ? `EXC_AdEL :
                        (exc_store_h | exc_store_w ) ? `EXC_AdES : mem_exe_exccode;

assign mem_badaddr =    (((exc_load_h | exc_load_w | exc_store_h | exc_store_w )))? daddr : mem_iaddr1_i;                     
`ifdef CONVERSE_WRITEDATA
    assign we_o = {we[0],we[1],we[2],we[3]};
`else
    assign we_o = we;
`endif 


assign dre_o = dre;

    always @(*) begin
        case(dre_select)
            3'b001: begin // lb
                dre =   (daddr[1:0] == 2'b00) ? 4'b0001 :
                        (daddr[1:0] == 2'b01) ? 4'b0010 :
                        (daddr[1:0] == 2'b10) ? 4'b0100 :
                        (daddr[1:0] == 2'b11) ? 4'b1000 : 4'b0000;
            end
            3'b010: begin // lh
                dre =   (daddr[1:0] == 2'b00) ? 4'b0011 :
                        (daddr[1:0]== 2'b10 ) ? 4'b1100 : 4'b0000;
            end
            3'b100: begin // lw
                dre = 4'b1111;
            end
            default: begin
                dre = 4'b0000;
            end
        endcase
    end 

    reg [`WORD_BUS]     din_select;
    always @(*) begin
        case (we_select)
            3'b001: begin // sb
                we =    (daddr[1:0] == 2'b00) ? 4'b0001 :
                        (daddr[1:0] == 2'b01) ? 4'b0010 :
                        (daddr[1:0] == 2'b10) ? 4'b0100 :
                        (daddr[1:0] == 2'b11) ? 4'b1000 : 4'b0000;
                din_select = {mem_inst1_w2ramdata_i[7:0] , mem_inst1_w2ramdata_i[7:0 ] , mem_inst1_w2ramdata_i[7:0  ] , mem_inst1_w2ramdata_i[7:0] };
            end
            // addr must align to 2
            3'b010: begin // sh
                we =    (daddr[1:0] == 2'b00) ? 4'b0011 : 
                        (daddr[1:0]== 2'b10 ) ? 4'b1100 : 4'b0000;
                din_select = {mem_inst1_w2ramdata_i[15:0] , mem_inst1_w2ramdata_i[15:0]};
            end
            3'b100: begin // sw
                we =    (daddr[1:0] == 2'b00) ? 4'b1111 : 4'b0000;
                din_select = mem_inst1_w2ramdata_i;
            end
            default: begin
                we = 4'b0000;
                din_select = `ZERO_WORD;
            end
        endcase
    end


    wire[`WORD_BUS] din_reverse  = {din_select[7:0] , din_select[15:8] , din_select[23:16] , din_select[31:24]};

/*DO NOT convert bit sequence when wirte/read confrgd*/
    always @(*) begin
        if(((mem_inst1_w2regdata_i) & (`CONF_ADDR_MASK)) == (`CONF_CONVERT_CONDITION)) begin
            `ifdef CONVERSE_CONFREG
                din = din_reverse;
            `else
                din = mem_inst1_w2ramdata_i;
            `endif 
        end
        else begin
            `ifdef CONVERSE_WRITEDATA
                din = din_reverse;
            `else 
                din = mem_inst1_w2ramdata_i;
            `endif  
        end
    end

endmodule