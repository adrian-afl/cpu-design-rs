module memory16kx2 (
    input clk,
    input [15:0] addr,
    output [15:0] rdata,
    input [15:0] wdata,
    input wr_en
);
  reg [15:0] ram[0:(16 * 1024)];

  assign rdata = ram[addr];

  always @(posedge clk) begin
    if (wr_en) begin
      // $display ("REALLY writing %h to %h", memory_writeout, address_bus);	
      ram[addr] = wdata;
    end
  end

endmodule
