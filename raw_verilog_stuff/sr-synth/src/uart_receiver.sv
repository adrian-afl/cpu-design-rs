module uart_receiver #(
    parameter integer CLK_FREQ_MHZ = 27,
    parameter integer BAUD_RATE = 9600
) (
    input        clock,
    input        n_reset,
    input        uart_rx,
    output       data_ready,
    output [7:0] data_out
);

  localparam integer CLOCK_TICKS_PER_BAUDRATE_TICK = CLK_FREQ_MHZ * 1000000 / BAUD_RATE;
  localparam integer HALF_CLOCK_TICKS_PER_BAUDRATE_TICK = CLOCK_TICKS_PER_BAUDRATE_TICK / 2;

  reg [31:0] wait_counter;  // maybe too big
  reg [3:0] bit_counter;

  reg is_data_ready;  // should be up for only 1 clk as this feeds into fifo directly
  reg [7:0] last_read_value;

  assign data_ready = is_data_ready;
  assign data_out   = last_read_value;

  reg is_reading = 0;

  always_ff @(posedge clock or negedge n_reset) begin
    if (!n_reset) begin
      last_read_value <= 8'b0;
      is_data_ready <= 0;
      is_reading <= 0;
      bit_counter <= 0;
      wait_counter <= 0;
    end else begin
      is_data_ready <= 0;

      if (wait_counter > 0) begin
        wait_counter <= wait_counter - 32'd1;
      end else if (!is_reading) begin
        // idle state, waiting for start
        if (!uart_rx) begin  // marking start, as input went low
          is_reading <= 1;
          bit_counter <= 0;
          last_read_value <= 8'b0;
          wait_counter <= HALF_CLOCK_TICKS_PER_BAUDRATE_TICK * 3;  // i think... first one after half is always down so need to wait 3 times
        end
      end else if (is_reading) begin
        last_read_value <= {uart_rx, last_read_value[7:1]};
        if (bit_counter == 7) begin
          is_data_ready <= 1;
          is_reading <= 0;
          wait_counter <= CLOCK_TICKS_PER_BAUDRATE_TICK;
        end else begin
          wait_counter <= CLOCK_TICKS_PER_BAUDRATE_TICK;
          bit_counter  <= bit_counter + 1'b1;
        end
      end
    end
  end

endmodule
