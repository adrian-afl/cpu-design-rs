`include "cpu.v"
`include "memory16kx2.v"
// combine all shit together
module soc (
    input wire clk,
    input wire rst
);

  wire [15:0] cpu_rdata;
  wire [15:0] cpu_wdata;
  wire cpu_wr_en;
  wire [15:0] addr_bus;

  (* keep = "true", syn_preserve = 1 *)
  cpu i_cpu1 (
      .clk(clk),
      .rst(rst),  // no reset for now
      .rdata(cpu_rdata),
      .wdata(cpu_wdata),
      .wr_en(cpu_wr_en),
      .addr(addr_bus)
  );

  (* keep = "true", syn_preserve = 1 *)
  memory16kx2 sram (
      .clk(run_signal),
      .rst(1'b0),  // no reset for now
      .memory_readout(memory_readout),
      .memory_writeout(memory_writeout),
      .memory_write_enable(memory_write_enable),
      .address_bus(address_bus),
      .out_reg_x(out_reg_x),
      .out_reg_y(out_reg_y),
      .out_reg_accu(out_reg_accu),
      .out_reg_pc(out_reg_pc),
      .out_reg_sp(out_reg_sp)
  );

endmodule
;
