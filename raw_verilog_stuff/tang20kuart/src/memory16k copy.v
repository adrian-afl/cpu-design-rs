module memory16k (
    input clk,
    input [31:0] bus_raddr,  // if addr R

    input bus_data_re_en,  // if data R
    output [7:0] bus_rdata,  // if data R
    input bus_data_wr_en,  // if data W
    input [7:0] bus_wdata  // if data W
);


  //    assign rdata = rdatabus;

`ifdef USE_GOWIN_SRAM

  wire [7:0] rdatabus;
  assign rdata = re_en ? rdatabus : 8'bzzzzzzzz;

  Gowin_SRAM my_gowin_propertiary_memory_ehhhh (
      .dout(rdatabus),  //output [7:0] dout
      .clk(clk),  //input clk
      .oce(re_en),  //input oce
      .ce(re_en || wr_en),  //input ce
      .reset(1'b0),  //input reset
      .wre(wr_en),  //input wre
      .ad(addr),  //input [15:0] ad
      .din(wdata)  //input [7:0] din
  );

`elsif USE_RAW_REGISTERS_SRAM

  reg [7:0] ram[0:16 * 1024];

  assign bus_rdata = bus_data_re_en ? ram[bus_raddr[12:0]] : 8'bzzzzzzzz;

  always @(posedge clk) begin
    if (bus_data_wr_en) begin
      $display("REALLY writing %h to %h", bus_wdata, bus_raddr[12:0]);
      ram[bus_raddr[12:0]] = bus_wdata;
    end
  end
`endif


endmodule
