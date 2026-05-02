`define USE_RAW_REGISTERS_SRAM 1
`include "../src/memory16k copy.v"
module memory_test ();
  reg clk = 0;

  always #5 clk = ~clk;

  reg rst = 1;

  reg [31:0] addr = 0;
  wire [7:0] rdata;
  reg [7:0] wdata = 0;
  reg wr_en = 0;
  reg re_en = 1;

  (* keep = "true", syn_preserve = 1 *)
  memory16k sram (
      .clk(clk),
      .bus_data_re_en(re_en),
      .bus_rdata(rdata),
      .bus_wdata(wdata),
      .bus_data_wr_en(wr_en),
      .bus_raddr(addr)
  );

  integer i = 0;

  initial begin
    #5 rst = 0;

    #5 addr = 32'd0;
    #5 wdata = 8'h55;
    #5 wr_en = 1;
    #10 wr_en = 0;

    #5 addr = 32'd1;
    #5 wdata = 8'h66;
    #5 wr_en = 1;
    #10 wr_en = 0;

    for (i = 0; i < 64; i = i + 1) begin
      #5 rst = 0;
      #5 addr = i;
      #5 clk = 1;
      #5 clk = 0;
      if (i % 16 == 0) $write("\n%h: ", i);
      $write("%h ", rdata);
    end
    $write("\n");

    $finish;
  end
endmodule
