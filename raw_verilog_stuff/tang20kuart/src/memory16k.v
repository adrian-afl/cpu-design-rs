module memory16k (
    input clk,
    input en,
    input [14:0] addr,
    output [7:0] rdata,
    input [7:0] wdata,
    input wr_en
);

    wire [7:0] rdatabus;

//    assign rdata = rdatabus;
    assign rdata = en ? rdatabus : 8'bzzzzzzzz;

    Gowin_SRAM my_gowin_propertiary_memory_ehhhh(
        .dout(rdatabus), //output [7:0] dout
        .clk(clk), //input clk
        .oce(en), //input oce
        .ce(en), //input ce
        .reset(1'b0), //input reset
        .wre(wr_en), //input wre
        .ad(addr), //input [15:0] ad
        .din(wdata) //input [7:0] din
    );

//  reg [7:0] ram[0:16 * 1024];

//  assign rdata = en ? ram[addr[12:0]] : 8'bzzzzzzzz;

//  always @(posedge clk) begin
//    if (en && wr_en) begin
//      $display("REALLY writing %h to %h", wdata, addr);
//      ram[addr] = wdata;
//    end
//  end

endmodule
