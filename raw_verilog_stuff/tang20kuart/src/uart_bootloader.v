
module uart_bootloader (
    input clk,
    input rst,

    input en,

    output reg [31:0] bus_waddr,  // if addr W

    input [7:0] bus_rdata,  // if data R
    output bus_data_wr_en,  // if data W
    output [7:0] bus_wdata,  // if data W

    output reg switch_to_cpu
);

  reg  [55:0] uart_cmd = 56'h0;
  reg  [15:0] uart_cmd_head = 0;

  wire [ 7:0] uart_cmd_header = uart_cmd[8*7-1 : 8*6];
  wire [ 7:0] uart_cmd_opcode = uart_cmd[8*6-1 : 8*5];
  wire [31:0] uart_cmd_address = uart_cmd[8*5-1 : 8];
  wire [ 7:0] uart_cmd_write_value = uart_cmd[7:0];
  wire [ 7:0] uart_cmd_read_count_remaining = uart_cmd[7:0];

  localparam [7:0] uart_cmd_expected_header = 8'hFE;
  localparam [7:0] uart_cmd_opcode_write = 8'hFB;
  localparam [7:0] uart_cmd_opcode_read = 8'hFA;
  localparam [7:0] uart_cmd_opcode_run = 8'hF0;

  localparam [2:0] state_read_uart_scan_for_start = 3'h00;
  localparam [2:0] state_read_uart_read_command = 3'h01;
  localparam [2:0] state_read_uart_command_execute = 3'h02;
  localparam [2:0] state_read_uart_command_finalize = 3'h03;

  reg [2:0] current_state = state_read_uart_scan_for_start;

  localparam [31:0] uart_addr_write = 32'b0010_0000_0000_0000_0000_0000_0000_0000;
  localparam [31:0] uart_addr_read_data = 32'b0010_0000_0000_0000_0000_0000_0000_0000;
  localparam [31:0] uart_addr_read_data_ready = 32'b0010_0000_0000_0000_0000_0000_0000_0001;

  reg waiting_for_uart_read_ready = 0;
  reg reading_from_uart = 0;
  reg [7:0] uart_io = 0;
  reg writing_to_uart = 0;

  reg [3:0] readout_cycle = 0;

  always @(posedge clk) begin
    // defaults
    bus_waddr <= uart_addr_read_data_ready;
    bus_data_wr_en <= 0;
    bus_wdata <= 8'bzzzzzzzz;

    if (waiting_for_uart_read_ready) begin
      if (bus_rdata[0]) begin
        // data ready, can continue, automatically read the byte too
        waiting_for_uart_read_ready <= 0;
        reading_from_uart <= 1;
        bus_waddr <= uart_addr_read_data;
      end
    end else if (reading_from_uart) begin
      uart_io <= bus_rdata;
      reading_from_uart <= 0;
    end else if (writing_to_uart) begin
      bus_waddr <= uart_addr_write;
      bus_data_wr_en <= 1;
      bus_wdata <= uart_io;
      writing_to_uart <= 0;
    end else begin

      case (current_state)
        state_read_uart_scan_for_start: begin
          if (uart_io == uart_cmd_expected_header) begin
            uart_cmd[7:0] = uart_cmd_expected_header;
            uart_cmd_head <= 1;

            current_state <= state_read_uart_read_command;
            waiting_for_uart_read_ready <= 1;
          end
        end
        state_read_uart_read_command: begin
          if (uart_cmd_head == 7) begin
            readout_cycle <= 0;  // reset cycler readout state
            current_state <= state_read_uart_command_execute;
          end else begin
            uart_cmd <= {uart_cmd[47:0], uart_io};
            uart_cmd_head <= uart_cmd_head + 16'd1;
            waiting_for_uart_read_ready <= 1;
          end
        end
        state_read_uart_command_execute: begin
          case (uart_cmd_opcode)
            uart_cmd_opcode_write: begin
              bus_waddr <= uart_cmd_address;
              bus_data_wr_en <= 1;
              bus_wdata <= uart_cmd_write_value;

              current_state <= state_read_uart_command_finalize;
            end
            uart_cmd_opcode_read: begin
              case (readout_cycle)
                0: begin
                  // initial setup
                  bus_waddr <= uart_cmd_address;
                  readout_cycle <= 1;
                end
                1: begin
                  // setup readout from memory
                  bus_waddr <= bus_waddr + 32'd1;
                  readout_cycle <= 2;
                end
                2: begin
                  // read from memory to uart io and request to send it
                  uart_io <= bus_rdata;
                  // write from uart_io to uart
                  writing_to_uart <= 1;

                  if (uart_cmd[7:0] == 8'd0) begin
                    readout_cycle <= 3;
                  end else begin
                    uart_cmd[7:0] <= uart_cmd[7:0] - 8'd1;
                    readout_cycle <= 1;
                  end
                end
                3: begin
                  current_state <= state_read_uart_command_finalize;
                  readout_cycle <= 3;
                end
                default: readout_cycle <= 3;
              endcase
              bus_waddr <= uart_cmd_address;
            end
            uart_cmd_opcode_run: begin
              switch_to_cpu <= 1;
            end
            default: bus_wdata <= 8'bzzzzzzzz;
          endcase
        end
        state_read_uart_command_finalize: begin
          current_state <= state_read_uart_read_command;
          waiting_for_uart_read_ready <= 1;
        end
        default: bus_wdata <= 8'bzzzzzzzz;
      endcase

    end
  end
endmodule
