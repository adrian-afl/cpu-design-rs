`define USE_RAW_REGISTERS_SRAM 1
`include "../src/memory16k copy.v"
`include "../src/bus_orchestrator.v"
`include "../src/uart_bootloader.v"
module uart_bootloader_test ();
  reg clk = 0;

  always #5 clk = ~clk;

  reg rst = 1;

  wire [31:0] bus_addr;
  wire [7:0] bus_rdata;
  wire [7:0] bus_wdata;
  wire bus_wr_en;

  reg [31:0] cpu_addr;
  reg [7:0] cpu_rdata;
  reg [7:0] cpu_wdata;
  reg cpu_wr_en;
  reg cpu_en = 1;

  wire [31:0] bldr_addr;
  wire [7:0] bldr_rdata;
  wire [7:0] bldr_wdata;
  wire bldr_wr_en;
  reg bldr_en = 0;

  wire [7:0] sram_rdata;
  reg [7:0] uart_rdata;
  reg uart_rdata_ready = 0;
  wire [7:0] uart_rdata_combined = bus_addr[0] == 1 ? ({7'b0000000, uart_rdata_ready}) : uart_rdata;

  (* keep = "true", syn_preserve = 1 *)
  bus_orchestrator bus_orchestrator1 (
      .clk(clk),
      .cpu_addr(cpu_addr),
      .cpu_rdata(cpu_rdata),
      .cpu_wdata(cpu_wdata),
      .cpu_wr_en(cpu_wr_en),
      .cpu_en(cpu_en),
      .bldr_addr(bldr_addr),
      .bldr_rdata(bldr_rdata),
      .bldr_wdata(bldr_wdata),
      .bldr_wr_en(bldr_wr_en),
      .bldr_en(bldr_en),
      .sram_rdata(sram_rdata),
      .uart_rdata(uart_rdata_combined),
      .bus_addr(bus_addr),
      .bus_rdata(bus_rdata),
      .bus_wdata(bus_wdata),
      .bus_wr_en(bus_wr_en)
  );

  (* keep = "true", syn_preserve = 1 *)
  memory16k sram (
      .clk(clk),
      .bus_raddr(bus_addr),
      .bus_rdata(sram_rdata),
      .bus_wdata(bus_wdata),
      .bus_data_wr_en(bus_wr_en)
  );

  reg  uart_bldr_en = 0;
  wire switch_to_cpu = 0;

  (* keep = "true", syn_preserve = 1 *)
  uart_bootloader bldr (
      .clk(clk),
      .rst(rst),
      .en(bldr_en),
      .bus_waddr(bldr_addr),
      .bus_rdata(bus_rdata),
      .bus_wdata(bldr_wdata),
      .bus_data_wr_en(bldr_wr_en),
      .switch_to_cpu(switch_to_cpu)
  );

  integer i = 0;

  initial begin

    // $monitor("bus_addr %h, bus_rdata %h, uart_data_combined %h", bus_addr, bus_rdata,
    //          uart_data_combined);

    #5 rst = 0;

    #10 cpu_addr = 32'd0;
    #10 cpu_wdata = 8'h55;
    #10 cpu_wr_en = 1;
    #10 cpu_wr_en = 0;

    #10 cpu_addr = 32'd1;
    #10 cpu_wdata = 8'h66;
    #10 cpu_wr_en = 1;
    #10 cpu_wr_en = 0;

    for (i = 0; i < 64; i = i + 1) begin
      #5 cpu_addr = i;
      #5 clk = 1;
      #5 clk = 0;
      //   $write("\n%h: ", i);
      #10 if (i % 16 == 0) $write("\n%h: ", i);
      $write("%h ", bus_rdata);
      #5 clk = 1;
      #5 clk = 0;
    end
    $write("\n");

    #5000 cpu_addr = {32{1'bz}};
    #5 cpu_en = 0;

    #5 bldr_en = 1;
    #50 uart_rdata <= 8'hFE;  // uart data
    #5 uart_rdata_ready = 1;
    #5 uart_rdata_ready = 0;
    #50 uart_rdata <= 8'hFB;  // uart data
    #5 uart_rdata_ready = 1;
    #5 uart_rdata_ready = 0;
    #50 uart_rdata <= 8'h00;  // uart data
    #5 uart_rdata_ready = 1;
    #5 uart_rdata_ready = 0;
    #50 uart_rdata <= 8'h00;  // uart data
    #5 uart_rdata_ready = 1;
    #5 uart_rdata_ready = 0;
    #50 uart_rdata <= 8'h00;  // uart data
    #5 uart_rdata_ready = 1;
    #5 uart_rdata_ready = 0;
    #50 uart_rdata <= 8'h05;  // uart data
    #5 uart_rdata_ready = 1;
    #5 uart_rdata_ready = 0;
    #50 uart_rdata <= 8'h88;  // uart data
    #5 uart_rdata_ready = 1;
    #5 uart_rdata_ready = 0;


    #500 bldr_en = 0;
    #500 cpu_en = 1;
    for (i = 0; i < 64; i = i + 1) begin
      #5 cpu_addr = i;
      #5 clk = 1;
      #5 clk = 0;
      //   $write("\n%h: ", i);
      #10 if (i % 16 == 0) $write("\n%h: ", i);
      $write("%h ", bus_rdata);
      #5 clk = 1;
      #5 clk = 0;
    end
    $write("\n");

    #500 $finish;
  end
endmodule
