
module uart_bootloader (
    input clk,
    input rst,

    input en,

    output reg [31:0] bus_waddr,  // if addr W

    input [7:0] bus_rdata,  // if data R
    output reg bus_data_wr_en,  // if data W
    output [7:0] bus_wdata,  // if data W

    output reg switch_to_cpu
);
  reg [7:0] bus_wdata_reg = 0;
  assign bus_wdata = en ? bus_wdata_reg : 8'bzzzzzzzz;

  localparam [31:0] uart_addr_write = 32'b0010_0000_0000_0000_0000_0000_0000_0000;
  localparam [31:0] uart_addr_read_data = 32'b0010_0000_0000_0000_0000_0000_0000_0000;
  localparam [31:0] uart_addr_read_data_ready = 32'b0010_0000_0000_0000_0000_0000_0000_0001;

  reg waiting_for_uart_read_ready = 1;
  reg reading_from_uart = 0;
  reg [7:0] uart_io = 0;
  reg writing_to_uart = 0;
  reg delay_1_cycle = 0;

  reg [3:0] readout_cycle = 0;


  reg is_writing = 0;

  // it starts writing at address 0
  // protocol is:
  // 0xDEADCODE header
  // 256 bytes of data
  // then the bootloader shifts to initial state, but address is not reset

  /*
  how would it look in simplest code?

  let addr = 0;
  let magic_seq_counter = 0;
  let magic_seq = 0xDEAD;
  let is_writing = false;
  let write_counter = 0;
  while(true){
    if(!is_writing){
      let read_byte = read_uart_byte(); // blocking
      if(magic_seq[magic_seq_counter] == read_byte){
        magic_seq_counter++;
        if(magic_seq_counter == 4){
          magic_seq_counter = 0;
          write_counter = 256;
        }
      } else {
        magic_seq_counter = 0;
      }
    } else {
    
      
    }
  }
  */

  always @(posedge clk) begin
    if (en) begin
      // defaults
      // bus_waddr <= uart_addr_read_data_ready;
      bus_data_wr_en <= 0;
      bus_wdata_reg  <= 8'bzzzzzzzz;

      if (delay_1_cycle) begin
        delay_1_cycle <= 0;
      end else if (waiting_for_uart_read_ready) begin

        $display("BLDR: waiting for uart data at addr %h, currently %h", bus_waddr, bus_rdata);
        if (bus_waddr[0] == 1 && bus_rdata == 8'h01) begin
          // data ready, can continue, automatically read the byte too
          waiting_for_uart_read_ready <= 0;
          reading_from_uart <= 1;
          bus_waddr <= uart_addr_read_data;
          delay_1_cycle <= 1;

          $display("BLDR: DONE waiting for uart data");
        end else begin
          bus_waddr <= uart_addr_read_data_ready;
        end
      end else if (reading_from_uart) begin
        if (bus_waddr[0] == 0) begin
          uart_io <= bus_rdata;
          reading_from_uart <= 0;
          $display("BLDR: DONE READING!!! for uart data: %h from %h", bus_rdata, bus_waddr);
        end
      end else if (writing_to_uart) begin
        bus_waddr <= uart_addr_write;
        bus_data_wr_en <= 1;
        bus_wdata_reg <= uart_io;
        writing_to_uart <= 0;
      end else begin

        case (current_state)
          state_read_uart_scan_for_start: begin
            if (uart_io == uart_cmd_expected_header) begin
              uart_cmd[7:0] = uart_cmd_expected_header;
              uart_cmd_head <= 1;

              current_state <= state_read_uart_read_command;
              waiting_for_uart_read_ready <= 1;

              $display("BLDR: found initial header");
            end
          end
          state_read_uart_read_command: begin
            if (uart_cmd_head == 7) begin
              readout_cycle <= 0;  // reset cycler readout state
              current_state <= state_read_uart_command_execute;
              $display("BLDR: DONE reading command");
            end else begin
              uart_cmd <= {uart_cmd[47:0], uart_io};
              uart_cmd_head <= uart_cmd_head + 16'd1;
              if (uart_cmd_head != 6) begin
                waiting_for_uart_read_ready <= 1;
              end

              $display("BLDR: reading command, currently %h, head will be %d", {
                       uart_cmd[47:0], uart_io}, uart_cmd_head + 16'd1);
            end
          end
          state_read_uart_command_execute: begin
            $display("BLDR: EXECUTING command %h", uart_cmd_opcode);
            case (uart_cmd_opcode)
              uart_cmd_opcode_write: begin
                bus_waddr <= uart_cmd_address;
                bus_data_wr_en <= 1;
                bus_wdata_reg <= uart_cmd_write_value;

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
              default: bus_wdata_reg <= 8'bzzzzzzzz;
            endcase
          end
          state_read_uart_command_finalize: begin
            current_state <= state_read_uart_read_command;
            waiting_for_uart_read_ready <= 1;
          end
          default: bus_wdata_reg <= 8'bzzzzzzzz;
        endcase

      end
    end
  end
endmodule
