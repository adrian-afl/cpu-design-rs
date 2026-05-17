/* what will be driven here
- bus address
- bus rdata
- bus wdata
- bus wr_en
- bus re_en - needed? no, selection itself drives the rdata always

*/
module bus_orchestrator (
    input clk,

    // cpu is master
    input [31:0] cpu_addr,
    input [7:0] cpu_rdata,
    input [7:0] cpu_wdata,
    input cpu_wr_en,
    input cpu_en,

    // bootloader is also master
    input [31:0] bldr_addr,
    input [7:0] bldr_rdata,
    input [7:0] bldr_wdata,
    input bldr_wr_en,
    input bldr_en,

    // sram is slave
    input [7:0] sram_rdata,

    // uart mem mapped io is slave
    input [7:0] uart_rdata,

    // return the mapped stuff
    output [31:0] bus_addr,
    output [7:0] bus_rdata,
    output [7:0] bus_wdata,
    output bus_wr_en
);
  reg [31:0] addr;
  reg [7:0] wdata;
  reg wr_en;

  assign bus_addr  = addr;
  assign bus_wdata = wdata;
  assign bus_wr_en = wr_en;

  wire [2:0] read_dev_id = addr[31:29];
  // top bits 000 means its memory being addressed
  localparam [2:0] sram_range = 3'b000;
  // top bits 001 means uart
  localparam [2:0] uart_range = 3'b001;

  assign bus_rdata = read_dev_id == sram_range ? sram_rdata : uart_rdata;

  always @(posedge clk) begin
    if (bldr_en) begin
      addr  <= bldr_addr;
      wdata <= bldr_wdata;
      wr_en <= bldr_wr_en;
    end else if (cpu_en) begin
      addr  <= cpu_addr;
      wdata <= cpu_wdata;
      wr_en <= cpu_wr_en;
    end else begin
      addr  <= 32'h00000000;
      wdata <= 8'h00;
      wr_en <= 0;
    end

  end

endmodule
