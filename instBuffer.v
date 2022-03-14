`include "defines.v"


module instBuffer(
    input wire clk,
    input wire resetn,
    input wire flush,
    input wire[`INST_BUS] inst_i,
    input wire[`INST_ADDR_BUS] iaddr_i,

    input re,
    input we,


    output reg[`INST_BUS] inst1,
    output reg[`INST_BUS] inst2,
    output reg[`INST_BUS] iaddr1,
    output reg[`INST_BUS] iaddr2,
    
    output wire instBufferFull
);


reg[`INST_BUS] instBuffer[ `INST_BUFFER_SIZE - 1 : 0 ];
reg[`INST_ADDR_BUS] addrBuffer[ `INST_BUFFER_SIZE - 1 : 0];

reg[`ISNT_BUFFER_SIZElog2 - 1 : 0] head;
reg[`ISNT_BUFFER_SIZElog2 - 1 : 0] tail;

wire[`ISNT_BUFFER_SIZElog2 - 1 : 0] headp1;

// one more bit 
reg[`ISNT_BUFFER_SIZElog2 : 0] bufferContentLen;
wire bufferFull;
wire bufferEmpty;
wire instNumberMoreThan2;

assign bufferFull = bufferContentLen == `INST_BUFFER_SIZE ? 1'b1 : 1'b0;
assign bufferEmpty = bufferContentLen == 0 ? 1'b1 : 1'b0;
assign instNumberMoreThan2 = bufferContentLen >= 2 ? 1'b1 : 1'b0 ;
assign headp1 = head + 1;

wire writeEnable;
wire readEnable;
assign writeEnable = we & ~(bufferFull);
assign readEnable = re & instNumberMoreThan2;
assign instBufferFull = bufferFull;

integer i;
always@(posedge clk) begin
    if(resetn == `RST_ENABLE | flush ) begin
        for(i = 0; i < `INST_BUFFER_SIZE; i = i + 1) begin
            instBuffer[i] <= `ZERO_DWORD;
            addrBuffer[i] <= `ZERO_WORD;
        end
        bufferContentLen <= 0;
        head <= 0;
        tail <= 0;
    end
    else begin

        if(writeEnable) begin   
            instBuffer[tail] <= inst_i;
            addrBuffer[tail] <= iaddr_i; 
            tail <= tail + 1;
        end

        if(readEnable) begin
            inst1 <= instBuffer[head];
            inst2 <= instBuffer[headp1];
            iaddr1 <= addrBuffer[head];
            iaddr2 <= addrBuffer[headp1];
            head <= head + 2;
        end 
        else begin
            inst1 <= 0;
            inst2 <= 0;
            iaddr1 <= 0;
            iaddr2 <= 0;
        end

        // count logic 
        case({writeEnable, readEnable}) 
            2'b01: begin
                bufferContentLen <= bufferContentLen - 2;
            end
            2'b10: begin
                bufferContentLen <= bufferContentLen + 1;
            end
            2'b11: begin
                bufferContentLen <= bufferContentLen - 1;
            end
            default: begin end
        endcase
    end

end

endmodule
