`include "defines.v"


module instBuffer(
    input wire clk,
    input wire resetn,
    input wire flush,
    input wire[`INST_BUS] inst_i,
    input wire[`INST_ADDR_BUS] iaddr_i,

    input re,
    input we,
    input wire[1:0] issue_mode,


    output wire[`INST_BUS] inst1,
    output wire[`INST_BUS] inst2,
    output wire[`INST_BUS] iaddr1,
    output wire[`INST_BUS] iaddr2,
    
    output wire instBufferFull
);


reg[`INST_BUS] instBuffer[ `INST_BUFFER_SIZE - 1 : 0 ];
reg[`INST_ADDR_BUS] addrBuffer[ `INST_BUFFER_SIZE - 1 : 0];

reg[`ISNT_BUFFER_SIZElog2 - 1 : 0] head;
reg[`ISNT_BUFFER_SIZElog2 - 1 : 0] tail;
wire[`ISNT_BUFFER_SIZElog2 - 1 : 0] headp1 = head + 1;
wire[`ISNT_BUFFER_SIZElog2 - 1 : 0] headp2 = head + 2;
wire[`ISNT_BUFFER_SIZElog2 - 1 : 0] tailp1 = tail + 1;
// one more bit 
reg[`ISNT_BUFFER_SIZElog2 : 0] bufferContentLen;
wire bufferFull;
wire bufferEmpty;
wire instNumberMoreThan2;


assign bufferFull = bufferContentLen == `INST_BUFFER_SIZE ? 1'b1 : 1'b0;
assign bufferEmpty = bufferContentLen == 0 ? 1'b1 : 1'b0;
assign instNumberMoreThan2 = bufferContentLen >= 2 ? 1'b1 : 1'b0 ;

wire writeEnable;
wire readEnable;
assign writeEnable = we & ~(bufferFull);
assign readEnable = re & instNumberMoreThan2;
assign instBufferFull = bufferFull;



assign inst1 = readEnable ? instBuffer[head] : 0;
assign inst2 = readEnable ? instBuffer[headp1] : 0;
assign iaddr1 = readEnable ? addrBuffer[head] : 0;
assign iaddr2 = readEnable ? addrBuffer[headp1] : 0;

integer i;
always@(posedge clk) begin
    if(resetn == `RST_ENABLE | flush ) begin
        for(i = 0; i < `INST_BUFFER_SIZE; i = i + 1) begin
            instBuffer[i] <= `ZERO_DWORD;
            addrBuffer[i] <= `ZERO_WORD;
        end
        bufferContentLen <= 0;
        head <= 0 - 2;
        tail <= 0;
    end
    else begin

        if(writeEnable) begin   
            instBuffer[tail] <= inst_i;
            addrBuffer[tail] <= iaddr_i; 
            tail <= tailp1;
        end

        if(readEnable) begin
            case(issue_mode)
                `INIT_ISSUE : begin end
                `DUAL_ISSUE : head <= headp2;
                `SINGLE_ISSUE: head <= headp1;
                default: begin end
            endcase
        end 

        // count logic 
        case({writeEnable, readEnable}) 
            2'b01: begin
                if(issue_mode == `DUAL_ISSUE )
                    bufferContentLen <= bufferContentLen - 2;
                else 
                    bufferContentLen <= bufferContentLen - 1;
            end
            2'b10: begin
                bufferContentLen <= bufferContentLen + 1;
            end
            2'b11: begin
                if(issue_mode == `DUAL_ISSUE )
                    bufferContentLen <= bufferContentLen - 1;
            end
            default: begin end
        endcase
    end

end

endmodule
