module memory16k (
    input clk,
    input en,
    input [13:0] addr,
    output [7:0] rdata,
    input [7:0] wdata,
    input wr_en
);
  reg [7:0] ram[16 * 1024];

  assign rdata = en ? ram[addr] : 8'bzzzzzzzz;

  always @(posedge clk) begin
    if (en && wr_en) begin
      $display("REALLY writing %h to %h", wdata, addr);
      ram[addr] = wdata;
    end
  end

endmodule
