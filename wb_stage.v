`include "defines.v"
// WRITE DATA TO DATA RAM
module wb_stage(
    input  wire                         resetn,

    input  wire[7:0]                    wb_inst1_memtype_i,
	input  wire                         wb_inst1_mreg_i,
    input  wire[1:0]                    wb_inst1_whilo_i,
    input  wire                         wb_inst1_wreg_i,
	input  wire [`REG_ADDR_BUS  ]       wb_inst1_wa_i,
	input  wire [`REG_BUS       ]       wb_inst1_w2regdata_i,

    input  wire[7:0]                    wb_inst2_memtype_i,
	input  wire                         wb_inst2_mreg_i,
    input  wire[1:0]                    wb_inst2_whilo_i,
    input  wire                         wb_inst2_wreg_i,
	input  wire [`REG_ADDR_BUS  ]       wb_inst2_wa_i,
	input  wire [`REG_BUS       ]       wb_inst2_w2regdata_i,

    input  wire [`BSEL_BUS      ]       wb_dre_i,
    input  wire [`DOUBLE_REG_BUS]       wb_hilo_i,


    input  wire [`WORD_BUS      ]       rdata_from_ram,  
    input  wire [1:0]                   wb_is_mthilo,
    input  wire [`WORD_BUS      ]       wb_daddr,
    
    output wire                         wb_inst1_wreg_o,
    output wire [`REG_ADDR_BUS  ]       wb_inst1_wa_o,
    output wire [`WORD_BUS      ]       wb_inst1_w2regdata_o,

    output wire                         wb_inst2_wreg_o,
    output wire [`REG_ADDR_BUS  ]       wb_inst2_wa_o,
    output wire [`WORD_BUS      ]       wb_inst2_w2regdata_o,

    output wire[1:0]                    wb_whilo_o,
    output wire [`DOUBLE_REG_BUS]       wb_hilo_o

    );
    reg [`WORD_BUS] data;
    reg [`WORD_BUS] dm;

    assign wb_inst1_wreg_o      =   (resetn == `RST_ENABLE      )? 1'b0   : wb_inst1_wreg_i;
    assign wb_inst1_wa_o        =   (resetn == `RST_ENABLE      )? 5'b0   : wb_inst1_wa_i;
    assign wb_inst1_w2regdata_o =   (resetn == `RST_ENABLE          )       ?  `ZERO_WORD   :   
                                    (wb_inst1_mreg_i == `MREG_ENABLE )       ?   data        : wb_inst1_w2regdata_i;

    assign wb_inst2_wreg_o      =   (resetn == `RST_ENABLE      )? 1'b0   : wb_inst2_wreg_i;
    assign wb_inst2_wa_o        =   (resetn == `RST_ENABLE      )? 5'b0   : wb_inst2_wa_i;
    assign wb_inst2_w2regdata_o =   (resetn == `RST_ENABLE          )       ?  `ZERO_WORD   :   
                                    (wb_inst1_mreg_i == `MREG_ENABLE )       ?   data        : wb_inst2_w2regdata_i;


    assign wb_whilo_o   =   (resetn == `RST_ENABLE      )? 2'b00  : wb_inst1_whilo_i;
    assign wb_hilo_o    =   (resetn == `RST_ENABLE      )? 64'b0                            :
                            (wb_is_mthilo == 2'b01      )? {{32{1'b0}} , wb_inst1_w2regdata_i}    :
                            (wb_is_mthilo == 2'b10      )? {wb_inst1_w2regdata_i  , {32{1'b0}}}   :
                            (wb_is_mthilo == 2'b00      )? wb_hilo_i                        : 64'b0;

    wire        is_sign_extend;
    assign      is_sign_extend = (wb_inst1_memtype_i[0]) | (wb_inst1_memtype_i[2]); 



// wb_daddr only used for the fucking bit endian
always @(*) begin
    // data from confreg
    if( ((wb_daddr) & (`CONF_ADDR_MASK)) == (`CONF_CONVERT_CONDITION_WB)) begin
        `ifdef CONVERSE_CONFREG
            dm = {rdata_from_ram[7:0],rdata_from_ram[15:8],rdata_from_ram[23:16],rdata_from_ram[31:24]};
        `else
            dm = rdata_from_ram;
        `endif 
    end
    // data from data ram
    else begin
        `ifdef CONVERSE_READ_DATA
            dm = {rdata_from_ram[7:0],rdata_from_ram[15:8],rdata_from_ram[23:16],rdata_from_ram[31:24]};
        `else
            dm = rdata_from_ram;
        `endif 
    end
end


always @(*) begin
        case (wb_dre_i)
            4'b1111:  begin
                data =  dm;
            end
            4'b0011:begin
                data = (is_sign_extend == 1) ? { {16{dm[15]}} , dm[15:0] }  :  { {16{1'b0}} , dm[15:0]};
            end
            4'b1100:begin
                data = (is_sign_extend == 1) ? { {16{dm[31]}} , dm[31:16] }  :  { {16{1'b0}} , dm[31:16] };
            end
            4'b0001:begin
                data = (is_sign_extend == 1) ? { {24{dm[7]}} , dm[7:0] } :  { {24{1'b0}} , dm[7:0] } ;
            end
            4'b0010:begin
                data = (is_sign_extend == 1) ? { {24{dm[15]}} , dm[15:8] } :  { {24{1'b0}} , dm[15:8]} ;
            end
            4'b0100:begin
                data = (is_sign_extend == 1) ? { {24{dm[23]}} , dm[23:16] } :  { {24{1'b0}} , dm[23:16]} ;
            end
            4'b1000:begin
                data = (is_sign_extend == 1) ? { {24{dm[31]}} , dm[31:24] } :  { {24{1'b0}} , dm[31:24] } ;
            end
            default: begin
                data = `ZERO_WORD;
            end 
        endcase
end


endmodule