`include "defines.v"
module wb_stage(
    input  wire                         sys_rst_n,
    input  wire[7:0]                    wb_memtype,
	input  wire                         wb_mreg_i,
    input  wire[1:0]                    wb_whilo_i,
    input  wire                         wb_wreg_i,
    input  wire [`BSEL_BUS      ]       wb_dre_i,
	input  wire [`REG_ADDR_BUS  ]       wb_wa_i,
    input  wire [`DOUBLE_REG_BUS]       wb_hilo_i,
	input  wire [`REG_BUS       ]       wb_dreg_i,
    input  wire [`WORD_BUS      ]       dm_i,   // д��Ŀ�ļĴ���������
    input  wire [1:0]                   wb_is_mthilo,
    input  wire [`WORD_BUS      ]       wb_daddr,
    
    output wire[1:0]                    wb_whilo_o,
    output wire                         wb_wreg_o,
    output wire [`REG_ADDR_BUS  ]       wb_wa_o,
    output wire [`DOUBLE_REG_BUS]       wb_hilo_o,
    output wire [`WORD_BUS      ]       wb_wd_o
    );
    assign wb_whilo_o   =   (sys_rst_n == `RST_ENABLE )? 2'b00  : wb_whilo_i;
    assign wb_wreg_o    =   (sys_rst_n == `RST_ENABLE )? 1'b0   : wb_wreg_i;
    assign wb_wa_o      =   (sys_rst_n == `RST_ENABLE )? 5'b0   : wb_wa_i;
    assign wb_hilo_o    =   (sys_rst_n == `RST_ENABLE )? 64'b0                      :
                            (wb_is_mthilo == 2'b01    )? {{32{1'b0}} , wb_dreg_i}   :
                            (wb_is_mthilo == 2'b10    )? {wb_dreg_i  , {32{1'b0}}}  :
                            (wb_is_mthilo == 2'b00    )? wb_hilo_i                  : 64'b0;

    wire     is_sign_extend;
    assign is_sign_extend = (wb_memtype[0]) | (wb_memtype[2]); 

    reg [`WORD_BUS] data;
    reg [`WORD_BUS] dm;

// wb_daddr only used for the fucking bit endian
always @(*) begin
    // data from confreg
    if( ((wb_daddr) & (`CONF_ADDR_MASK)) == (`CONF_CONVERT_CONDITION_WB)) begin
        `ifdef CONVERSE_CONFREG
            dm = {dm_i[7:0],dm_i[15:8],dm_i[23:16],dm_i[31:24]};
        `else
            dm = dm_i;
        `endif 
    end
    // data from data ram
    else begin
        `ifdef CONVERSE_READ_DATA
            dm = {dm_i[7:0],dm_i[15:8],dm_i[23:16],dm_i[31:24]};
        `else
            dm = dm_i;
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
    assign wb_wd_o =    (sys_rst_n == `RST_ENABLE) ?  `ZERO_WORD :   
                        (wb_mreg_i== `MREG_ENABLE) ? data : wb_dreg_i;

endmodule