module uart_transmitter #(
    parameter integer CLK_FREQ_MHZ = 27,
    parameter integer BAUD_RATE = 9600
) (
    input        clock,
    input        n_reset,
    output       uart_tx,
    output       can_write,
    input        write_enable,
    input  [7:0] data_in
);

  localparam integer CLOCK_TICKS_PER_BAUDRATE_TICK = CLK_FREQ_MHZ * 1000000 / BAUD_RATE;
  localparam integer HALF_CLOCK_TICKS_PER_BAUDRATE_TICK = CLOCK_TICKS_PER_BAUDRATE_TICK / 2;

  reg [31:0] wait_counter;  // maybe too big
  reg [3:0] bit_counter;  // 0 to 15 bounds, currently up to 10

  reg [7:0] writing_value;
  reg current_bit;
  reg is_writing = 0;

  assign uart_tx   = current_bit;
  assign can_write = !is_writing && wait_counter == 0;

  always_ff @(posedge clock or negedge n_reset) begin
    if (!n_reset) begin
      writing_value <= 8'b0;
      is_writing <= 0;
      bit_counter <= 0;
      wait_counter <= 0;
      current_bit <= 0;
    end else begin
      if (wait_counter > 0) begin
        wait_counter <= wait_counter - 1;
      end else if (!is_writing) begin
        // idle state, waiting for start
        if (write_enable) begin  // marking start, as write_enable went high
          is_writing <= 1;
          current_bit <= 1'b0;  // start bit
          bit_counter <= 0;
          writing_value <= data_in;
          wait_counter <= CLOCK_TICKS_PER_BAUDRATE_TICK;
        end
      end else if (is_writing) begin
        if (bit_counter < 8) begin
          current_bit   <= writing_value[0];
          writing_value <= {1'b0, writing_value[7:1]};
        end else if (bit_counter == 8) begin
          current_bit <= 1'b1;  // stop bit, for 1 cycle
        end else if (bit_counter == 9) begin
          is_writing <= 0;
        end
        bit_counter  <= bit_counter + 1'b1;
        wait_counter <= CLOCK_TICKS_PER_BAUDRATE_TICK;
      end
    end
  end

endmodule
