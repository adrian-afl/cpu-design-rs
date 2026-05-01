`include "cpu.v"
`include "memory16k.v"
`include "uart/uart_mod.v"
// combine all shit together
module soc (
    input wire clk,
    input wire rst,

    input  uart_rx,
    output uart_tx,

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

  wire [2:0] dev_id = indirect_addr_bus[31:29];
  // top bits 000 means its memory being addressed
  wire mem_en = dev_id == 3'b000;
  // top bits 001 means uart
  wire uart_en = dev_id == 3'b001;
  // top bits 002 means leds, unused now
  //   wire leds_en = dev_id == 3'b001;

  //   always @(posedge uart_en) $display("dev_id %h, fulladdr %h", dev_id, indirect_addr_bus);

  (* keep = "true", syn_preserve = 1 *)
  memory16k sram (
      .clk(clk),
      .en(mem_en),
      .rdata(cpu_rdata),
      .wdata(indirect_wdata),
      .wr_en(indirect_wr_en),
      .addr(indirect_addr_bus[13:0])
  );

  (* keep = "true", syn_preserve = 1 *)
  uart_mod uart (
      .clk(clk),
      .rst(rst),
      .en(uart_en),
      .rdata(cpu_rdata),
      .wdata(indirect_wdata),
      .wr_en(indirect_wr_en),
      .addr(indirect_addr_bus[13:0]),
      .uart_rx(uart_rx),
      .uart_tx(uart_tx)
  );

  assign ext_rdata = cpu_rdata;

endmodule
;
