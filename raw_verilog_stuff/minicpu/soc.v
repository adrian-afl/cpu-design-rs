`include "cpu.v"
`include "memory16kx2.v"
// combine all shit together
module soc (
    input wire clk,
    input wire rst,

    input [31:0] ext_addr,
    output [7:0] ext_rdata,
    input [7:0] ext_wdata,
    input ext_wr_en,
    input force_ext_mem
);

  wire [7:0] cpu_rdata;
  wire [7:0] cpu_wdata;
  wire cpu_wr_en;
  wire [31:0] addr_bus;

  (* keep = "true", syn_preserve = 1 *)
  cpu i_cpu1 (
      .clk  (clk && !force_ext_mem),
      .rst  (rst),
      .rdata(cpu_rdata),
      .wdata(cpu_wdata),
      .wr_en(cpu_wr_en),
      .addr (addr_bus)
  );

  wire [31:0] indirect_addr_bus = force_ext_mem ? ext_addr : addr_bus;
  wire [7:0] indirect_wdata = force_ext_mem ? ext_wdata : cpu_wdata;
  wire indirect_wr_en = force_ext_mem ? ext_wr_en : cpu_wr_en;

  (* keep = "true", syn_preserve = 1 *)
  memory16kx2 sram (
      .clk  (clk),
      .rdata(cpu_rdata),
      .wdata(indirect_wdata),
      .wr_en(indirect_wr_en),
      .addr (indirect_addr_bus)
  );

  assign ext_rdata = cpu_rdata;

endmodule
;
