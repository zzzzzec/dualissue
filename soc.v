`include "defines.v"

module soc(
    input      wire     resetn, 
    input       wire    cpu_clk
);

wire [`INST_ADDR_BUS] cpu2ram_iaddr;
wire  cpu2ram_ice;
wire [`INST_BUS]    ram2cpu_inst;

wire [31:0] cpu2ram_dout;
wire [31:0] cpu2ram_daddr;
wire [31:0] ram2cpu_din;
wire  cpu2ram_dce;
wire [3:0] cpu2ram_we;

MiniMIPS32 cpu(
    .clk(cpu_clk),
    .resetn(resetn),

    .iaddr(cpu2ram_iaddr),
    .ice(cpu2ram_ice),
    .inst(ram2cpu_inst),

    .dout(cpu2ram_dout),
    .dce(cpu2ram_dce),
    .daddr(cpu2ram_daddr),
    .we(cpu2ram_we),
    .din(ram2cpu_din)
);


inst_ram inst_ram(
    .clka  (cpu_clk            ),   
    .ena   (cpu2ram_ice       ),
    .wea   (0       ),   //3:0
    .addra (cpu2ram_iaddr[19:2]),   //17:0
    .dina  (0     ),   //31:0
    .douta (ram2cpu_inst     )    //31:0
);

//data ram
data_ram data_ram
(
    .clka  (cpu_clk            ),   
    .ena   ( cpu2ram_dce     ),
    .wea   (cpu2ram_we      ),   //3:0
    .addra (cpu2ram_daddr[17:2]),   //15:0
    .dina  (ram2cpu_din     ),   //31:0
    .douta (cpu2ram_dout     )    //31:0
);

endmodule