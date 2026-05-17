module uart_component #(
    parameter integer CLK_FREQ_MHZ = 27,
    parameter integer BAUD_RATE = 9600
) (
    input  clock,
    input  n_reset,
    input  uart_rx_async,
    output uart_tx,

    output       can_read,
    output [7:0] data_out,
    input        read_next,

    output       can_write,
    input  [7:0] data_in,
    input        write_enable,

    output [5:0] leds
);

  wire uart_rx;

  sync_2ff uart_rx_sync_2ff (
      .clock(clock),
      .n_reset(n_reset),
      .unstable_async_signal(uart_rx_async),
      .stable_signal(uart_rx)
  );

  wire receive_fifo_enqueue_enable;
  wire [7:0] receive_fifo_data_in;
  wire receive_fifo_is_empty;
  wire receive_fifo_is_full;
  wire [7:0] receive_fifo_data_out;
  assign can_read = ~receive_fifo_is_empty;
  assign data_out = receive_fifo_data_out;

  fifo_sync #(
      .WIDTH(8),
      .DEPTH(16)
  ) receive_fifo (
      .clock(clock),
      .n_reset(n_reset),
      .enqueue_enable(receive_fifo_enqueue_enable),
      .dequeue_enable(read_next),
      .data_in(receive_fifo_data_in),
      .is_empty(receive_fifo_is_empty),
      .is_full(receive_fifo_is_full),
      .data_out(receive_fifo_data_out)
  );

  uart_receiver #(
      .CLK_FREQ_MHZ(CLK_FREQ_MHZ),
      .BAUD_RATE(BAUD_RATE)
  ) uart_receiver (
      .clock(clock),
      .n_reset(n_reset),
      .uart_rx(uart_rx),
      .data_ready(receive_fifo_enqueue_enable),
      .data_out(receive_fifo_data_in)
  );


  //   assign leds = receive_fifo_data_in[5:0];

  wire transmit_fifo_is_empty;
  wire transmit_fifo_is_full;
  wire [7:0] transmit_fifo_data_out;
  assign can_write = ~transmit_fifo_is_full;

  wire uart_transmitter_can_write;
  wire uart_transmitter_write_enable = uart_transmitter_can_write && ~transmit_fifo_is_empty;

  fifo_sync #(
      .WIDTH(8),
      .DEPTH(16)
  ) transmit_fifo (
      .clock(clock),
      .n_reset(n_reset),
      .enqueue_enable(write_enable),
      .dequeue_enable(uart_transmitter_write_enable),
      .data_in(data_in),
      .is_empty(transmit_fifo_is_empty),
      .is_full(transmit_fifo_is_full),
      .data_out(transmit_fifo_data_out)
  );

  uart_transmitter #(
      .CLK_FREQ_MHZ(CLK_FREQ_MHZ),
      .BAUD_RATE(BAUD_RATE)
  ) uart_transmitter (
      .clock(clock),
      .n_reset(n_reset),
      .uart_tx(uart_tx),
      .can_write(uart_transmitter_can_write),
      .write_enable(uart_transmitter_write_enable),
      .data_in(transmit_fifo_data_out)
  );

  //   assign leds = ~(receive_fifo_enqueue_enable ? receive_fifo_data_out[5:0] : 6'd0);
  assign leds[0] = ~receive_fifo_is_empty;
  assign leds[1] = ~receive_fifo_is_full;

endmodule
