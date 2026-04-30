`include "soc.v"
module cpu_tb ();
  reg clk = 0;
  reg rst = 1;

  reg [31:0] ext_addr = 0;
  wire [7:0] ext_rdata;
  reg [7:0] ext_wdata = 0;
  reg ext_wr_en = 0;
  reg force_ext_mem = 0;



  (* keep = "true", syn_preserve = 1 *)
  soc soc1 (
      .clk(clk),
      .rst(rst),
      .ext_addr(ext_addr),
      .ext_rdata(ext_rdata),
      .ext_wdata(ext_wdata),
      .ext_wr_en(ext_wr_en),
      .force_ext_mem(force_ext_mem)
  );


  integer i = 0;

  initial begin

    //$dumpfile("test.vcd");
    //$dumpvars(0,run_signal);
    //$dumpvars(1,instr);

    force_ext_mem = 1;
    #5 rst = 0;

    // put opcode
    #5 ext_addr = 32'h00;
    #5 ext_wdata = `INSTR_PUT;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // direct addressing
    #5 ext_addr = 32'h01;
    #5 ext_wdata = 8'b00_00_00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    // 32 bit destination which will be 0x10
    #5 ext_addr = 32'h02;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'h03;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'h04;
    #5 ext_wdata = 8'h00;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;

    #5 ext_addr = 32'h05;
    #5 ext_wdata = 8'h10;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;


    // 8 bit value which will be 0x66

    #5 ext_addr = 32'h06;
    #5 ext_wdata = 8'h66;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;


    // halt

    #5 ext_addr = 32'h07;
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

    for (i = 0; i < 32; i = i + 1) begin
      #5 clk = 1;
      #5 clk = 0;
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
