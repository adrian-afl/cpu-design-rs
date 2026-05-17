module top (
    input  clock,
    input  n_reset,
    input  uart_rx_async,
    output uart_tx,

    output [5:0] leds
);

  wire uart_can_read;
  wire uart_can_write;
  wire [7:0] uart_data_out;
  reg uart_read_next;
  reg uart_write_enable;
  reg [7:0] uart_data_in;

  uart_component #(
      .CLK_FREQ_MHZ(27),
      .BAUD_RATE(9600)
  ) uart_component (
      .clock(clock),
      .n_reset(n_reset),
      .uart_rx_async(uart_rx_async),
      .uart_tx(uart_tx),
      .can_read(uart_can_read),
      .data_out(uart_data_out),
      .read_next(uart_read_next),
      .can_write(uart_can_write),
      .data_in(uart_data_in),
      .write_enable(uart_write_enable),
      .leds(leds)
  );

  // assign leds[0] = uart_can_read;
  // assign leds[1] = uart_can_write;
  // assign leds[2] = uart_read_next;
  // assign leds[3] = uart_write_enable;
  // assign leds[4] = uart_data_out[0];
  // assign leds[5] = uart_data_out[1];

  // assign leds = uart_data_out[5:0];

  always_ff @(posedge clock or negedge n_reset) begin
    if (!n_reset) begin
      uart_data_in <= 8'b0;
      uart_write_enable <= 0;
      uart_read_next <= 0;
    end else begin
      uart_data_in <= 8'b0;
      uart_write_enable <= 0;
      uart_read_next <= 0;

      if (uart_can_read && uart_can_write) begin
        uart_write_enable <= 1;
        uart_data_in <= uart_data_out;
        uart_read_next <= 1;
      end
    end
  end

endmodule
