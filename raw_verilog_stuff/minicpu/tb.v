`include "soc.v"
module cpu_tb ();
  reg clk = 0;
  reg rst = 1;

  reg [31:0] ext_addr = 0;
  wire [7:0] ext_rdata;
  reg [7:0] ext_wdata = 0;
  reg ext_wr_en = 0;
  reg force_ext_mem = 0;

  reg uart_rx;
  wire uart_tx;

  (* keep = "true", syn_preserve = 1 *)
  soc soc1 (
      .clk(clk),
      .rst(rst),
      .ext_addr(ext_addr),
      .ext_rdata(ext_rdata),
      .ext_wdata(ext_wdata),
      .ext_wr_en(ext_wr_en),
      .force_ext_mem(force_ext_mem),
      .uart_rx(uart_rx),
      .uart_tx(uart_tx)
  );


  integer i = 0;

  initial begin

    //$dumpfile("test.vcd");
    //$dumpvars(0,run_signal);
    //$dumpvars(1,instr);

    force_ext_mem = 1;
    #5 rst = 0;

    $monitor("[UART] time=%0t rx=%h tx=%h", $time, uart_rx, uart_tx);

    // opcode
    #5 ext_addr = 32'd0;
    #5 ext_wdata = `INSTR_PUT;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // addressing
    #5 ext_addr = 32'd1;
    #5 ext_wdata = 8'b00_00_00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd2;
    #5 ext_wdata = 8'b00100000;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd3;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd4;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd5;
    #5 ext_wdata = 8'h30;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // 8 bit value

    #5 ext_addr = 32'd6;
    #5 ext_wdata = 8'd36;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // opcode
    #5 ext_addr = 32'd7;
    #5 ext_wdata = `INSTR_MOV;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // addressing
    #5 ext_addr = 32'd8;
    #5 ext_wdata = 8'b00_00_00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd9;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd10;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd11;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd12;
    #5 ext_wdata = 8'h30;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd13;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd14;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd15;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd16;
    #5 ext_wdata = 8'h35;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // opcode
    #5 ext_addr = 32'd17;
    #5 ext_wdata = `INSTR_ADD;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // addressing
    #5 ext_addr = 32'd18;
    #5 ext_wdata = 8'b00_00_00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd19;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd20;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd21;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd22;
    #5 ext_wdata = 8'h30;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd23;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd24;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd25;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd26;
    #5 ext_wdata = 8'h05;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd27;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd28;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd29;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'd30;
    #5 ext_wdata = 8'h37;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // opcode
    #5 ext_addr = 32'd31;
    #5 ext_wdata = `INSTR_HALT;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;


    #5 force_ext_mem = 1;
    for (i = 0; i < 64; i = i + 1) begin
      #5 rst = 0;
      #5 ext_addr = i;
      #5 clk = 1;
      #5 clk = 0;
      if (i % 16 == 0) $write("\n%h: ", i);
      $write("%h ", ext_rdata);
    end
    $write("\n");
    #5 force_ext_mem = 0;

    // // x = 0x6
    // ram[0]  = `INSTR_STX_DIRECT;
    // ram[1]  = 16'h6;

    // // y = 0x3
    // ram[2]  = `INSTR_STY_DIRECT;
    // ram[3]  = 16'h3;

    // // accu = x/y = 2
    // ram[4]  = `INSTR_DIV;
    // ram[5]  = 16'h0;

    // // x = 0x32
    // ram[6]  = `INSTR_STX_DIRECT;
    // ram[7]  = 16'h32;

    // // ram[0x0102] = x = 0x32
    // ram[8]  = `INSTR_MEM_SX_DIRECT;
    // ram[9]  = 16'h0102;

    // // x = 0x36
    // ram[10] = `INSTR_STX_DIRECT;
    // ram[11] = 16'h36;

    // // ram[0x0103] = x = 0x36
    // ram[12] = `INSTR_MEM_SX_DIRECT;
    // ram[13] = 16'h0103;

    // // x = ram[0x0102] = 0x32 
    // ram[14] = `INSTR_MEM_LX_DIRECT;
    // ram[15] = 16'h0102;

    // // halt so the last registers get printed
    // ram[16] = `INSTR_HALT;
    // ram[17] = 16'h0102;

    for (i = 0; i < 1320000000; i = i + 1) begin
      #1 clk = 1;
      #1 clk = 0;
    end



    #5 force_ext_mem = 1;
    for (i = 0; i < 64; i = i + 1) begin
      #5 rst = 0;
      #5 ext_addr = i;
      #5 clk = 1;
      #5 clk = 0;
      if (i % 16 == 0) $write("\n%h: ", i);
      $write("%h ", ext_rdata);
    end
    $write("\n");
    #5 force_ext_mem = 0;

    #50 $finish;
  end
endmodule
