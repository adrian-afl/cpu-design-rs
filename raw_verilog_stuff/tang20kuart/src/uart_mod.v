
module uart_mod (
    input clk,
    input rst,

    input  uart_rx,
    output uart_tx,

    input en,
    input [13:0] addr,
    output [7:0] rdata,
    input [7:0] wdata,
    input wr_en
);

  parameter integer FIFO_DEPTH = 64;  // Bit
  parameter integer CLK_FRE = 27;  // Megahertz
  parameter integer BAUD_RATE = 9600;  // Baud

  // -----------------------------
  // UART RX interface
  // -----------------------------
  wire [7:0] rx_data;
  wire       rx_data_valid;
  wire       rx_data_ready;

  // -----------------------------
  // UART TX interface
  // -----------------------------
  reg  [7:0] tx_data;
  reg        tx_data_valid;
  wire       tx_data_ready;
  wire       tx_busy;

  // -----------------------------
  // TX FIFO
  // -----------------------------
  wire [7:0] fifo_dout;
  wire       fifo_full;
  wire       fifo_empty;
  wire       fifo_rd_en;
  reg        fifo_wr_en;
  reg  [7:0] fifo_din;

  assign rx_data_ready = ~fifo_full;

  reg [7:0] output_reg = 0;
  assign rdata = en ? output_reg : 8'bzzzzzzzz;

  // addressing here is:
  // write to 0x0 triggers push to fifo
  // read from 0x0 read rx_data directly AND clears it

  always @(posedge clk) begin
    fifo_wr_en <= 1'b0;
    fifo_din   <= 8'h00;

    if (wr_en) begin
      case (addr[1:0])
        2'b00: begin
          fifo_wr_en <= 1'b1;
          fifo_din   <= wdata;
          $display("Uart enqueued %c", wdata);
        end
        default: fifo_wr_en <= 0;
      endcase
    end else begin
      case (addr[1:0])
        2'b00:   output_reg <= rx_data;
        default: output_reg <= 0;
      endcase
    end
  end

  wire deq = tx_data_ready && !tx_data_valid && !fifo_empty;
  assign fifo_rd_en = deq;

  always @(posedge clk) begin
    if (rst) begin
      tx_data       <= 8'd0;
      tx_data_valid <= 1'b0;
    end else begin
      if (tx_data_valid && tx_data_ready) tx_data_valid <= 1'b0;
      if (deq) begin
        $display("Uart sending %c", fifo_dout);
        tx_data       <= fifo_dout;
        tx_data_valid <= 1'b1;
      end
    end
  end

  sync_fifo #(
      .WIDTH(8),
      .DEPTH(FIFO_DEPTH)
  ) out_fifo (
      .clk  (clk),
      .rst_n(~rst),
      .wr_en(fifo_wr_en),
      .din  (fifo_din),
      .rd_en(fifo_rd_en),
      .dout (fifo_dout),
      .full (fifo_full),
      .empty(fifo_empty)
  );

  uart_rx #(
      .CLK_FRE  (CLK_FRE),
      .BAUD_RATE(BAUD_RATE)
  ) rx (
      .clk          (clk),
      .rst_n        (~rst),
      .rx_data      (rx_data),
      .rx_data_valid(rx_data_valid),
      .rx_data_ready(rx_data_ready),
      .rx_pin       (uart_rx)
  );

  uart_tx #(
      .CLK_FRE  (CLK_FRE),
      .BAUD_RATE(BAUD_RATE)
  ) tx (
      .clk          (clk),
      .rst_n        (~rst),
      .tx_data      (tx_data),
      .tx_data_valid(tx_data_valid),
      .tx_data_ready(tx_data_ready),
      .tx_pin       (uart_tx),
      .tx_busy      (tx_busy)
  );

endmodule
