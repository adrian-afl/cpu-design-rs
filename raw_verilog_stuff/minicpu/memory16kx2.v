module memory16kx2 (
    input clk,
    input [31:0] addr,
    output [7:0] rdata,
    input [7:0] wdata,
    input wr_en
);
  reg [15:0] ram[0:(16 * 1024)];

  assign rdata = ram[addr];

  always @(posedge clk) begin
    if (wr_en) begin
      $display("REALLY writing %h to %h", wdata, addr);
      ram[addr] = wdata;
    end
  end

endmodule
