// combine all shit together
module soc (
    input wire clk,
    input wire rst,

    input  uart_rx,
    output uart_tx,

    input [31:0] ext_addr,
    output [7:0] ext_rdata,
    input [7:0] ext_wdata,
    input ext_wr_en,
    input force_ext_mem,

    output [5:0] leds
);
  `define SOC_MODE_UART_LOADER 2'd1
  `define SOC_MODE_CPU_RUNNING 2'd2




  reg [1:0] soc_mode = `SOC_MODE_UART_LOADER;
  wire cpu_run_enable = soc_mode == `SOC_MODE_CPU_RUNNING;
  wire uart_loader_enable = soc_mode == `SOC_MODE_UART_LOADER;

  // internal memory override
  reg [14:0] int_addr;
  reg [7:0] int_wdata;
  reg int_wr_en;
  wire force_int_mem;

  assign force_int_mem = uart_loader_enable;


  wire [7:0] cpu_rdata;
  wire [7:0] cpu_wdata;
  wire cpu_wr_en;
  wire [31:0] addr_bus;

  (* keep = "true", syn_preserve = 1 *)
  cpu i_cpu1 (
      .clk  (clk && !force_ext_mem && cpu_run_enable),
      .rst  (rst || uart_loader_enable),
      .rdata(cpu_rdata),
      .wdata(cpu_wdata),
      .wr_en(cpu_wr_en),
      .addr (addr_bus)
  );

  wire [31:0] indirect_addr_bus = force_ext_mem ? ext_addr : addr_bus;
  wire [7:0] indirect_wdata = force_ext_mem ? ext_wdata : cpu_wdata;
  wire indirect_wr_en = force_ext_mem ? ext_wr_en : cpu_wr_en;

  reg [7:0] uart_raw_write_data = 0;
  reg uart_raw_force_wr_en = 0;

  wire [2:0] dev_id = indirect_addr_bus[31:29];
  // top bits 000 means its memory being addressed
  wire mem_en = dev_id == 3'b000;
  // top bits 001 means uart
  wire uart_en = dev_id == 3'b001;
  // top bits 002 means leds, unused now
  //   wire leds_en = dev_id == 3'b001;

  //   always @(posedge uart_en) $display("dev_id %h, fulladdr %h", dev_id, indirect_addr_bus);

  (* keep = "true", syn_preserve = 1 *)
  memory16k sram (
      .clk(clk),
      .en(force_int_mem ? 1'b1 : mem_en),
      .rdata(cpu_rdata),
      .wdata(force_int_mem ? int_wdata : indirect_wdata),
      .wr_en(force_int_mem ? int_wr_en : indirect_wr_en),
      .addr(force_int_mem ? int_addr : indirect_addr_bus[13:0])
  );

  wire [7:0] raw_uart_rx_data;
  wire raw_uart_rx_data_valid;

  (* keep = "true", syn_preserve = 1 *)
  uart_mod uart (
      .clk(clk),
      .rst(rst),
      .en(uart_en),
      .rdata(cpu_rdata),
      .wdata(uart_loader_enable ? uart_raw_write_data : indirect_wdata),
      .wr_en(uart_loader_enable ? uart_raw_force_wr_en : indirect_wr_en),
      .addr(indirect_addr_bus[13:0]),
      .uart_rx(uart_rx),
      .uart_tx(uart_tx),
      .raw_uart_rx_data(raw_uart_rx_data),
      .raw_uart_rx_data_valid(raw_uart_rx_data_valid)
  );

  wire bootloader_pulse;

  (* keep = "true", syn_preserve = 1 *)
  pulse_gen #(
      .CLK_FRE(27),
      .MILISECONDS(100)
  ) bootloader_pulse_gen(
      .clk(clk),
      .rst(rst),
      .pulse_out(bootloader_pulse)
  );

  assign ext_rdata = cpu_rdata;

/*
SET
FE FB ll ll ll ll vv
ll location
vv value
outputs < char when instruction is decoded
outputs "vv"

GET
FE FA st st st st cc
st start
cc count
outputs > char when instruction is decoded
then outputs bytes one by one

each command is 7 bytes so 56 bits
*/

  reg [55:0] uart_cmd = 56'h0;
  reg [15:0] uart_cmd_head = 0;
  reg uart_reading = 0;
  reg uart_printing = 0;

  assign leds = ~uart_raw_write_data[5:0];

//  always @(posedge clk) begin
//    if(rst && uart_loader_enable) begin
//        uart_cmd_head <= 0;
//        uart_cmd <= 56'h0;
//    end else  begin end
//  end


  always @(posedge clk) begin
              //  uart_raw_write_data <= 8'h24; // $ - instruction start
             //   uart_raw_force_wr_en <= 1;
    uart_raw_write_data <= 8'd0;
    uart_raw_force_wr_en <= 0;
    int_wr_en <= 0;
    //int_addr <= 32'h0;
    int_wdata <= 8'h0;
    if (raw_uart_rx_data_valid) begin
        if(rst && uart_loader_enable) begin
            uart_cmd_head <= 0;
            uart_cmd <= 56'h0;
        end else if (uart_loader_enable) begin
            if (raw_uart_rx_data == 8'hFE) begin
                uart_reading <= 1;
                uart_cmd_head <= 1;
                uart_cmd[7:0] <= 8'hFE;

                uart_raw_write_data <= 8'h24; // $ - instruction start
                uart_raw_force_wr_en <= 1;

            end else if (uart_printing) begin

                if (uart_cmd[7:0] == 8'd0) begin
                     uart_printing <= 0;
                end else begin
                    int_addr <= int_addr + 32'd1;
                    uart_raw_write_data <= cpu_rdata; // $ - just echo stuff
                    uart_raw_force_wr_en <= 1;
                    uart_cmd[7:0] <= uart_cmd[7:0] - 8'd1;
                end

            end else begin 
                if (uart_cmd_head == 7) begin
                    uart_cmd_head <= 0;
                    uart_reading <= 0;
                    // act on the read command

//                        uart_raw_write_data <= uart_cmd[47:40]; // print +
//                        uart_raw_write_data <= uart_cmd[8 * 6 - 1 : 8 * 5]; // print +
//                        uart_raw_force_wr_en <= 1;

                    if (uart_cmd[8 * 6 - 1 : 8 * 5] == 8'hFB) begin // store command
                        int_addr <= uart_cmd[22:8];
                        int_wdata <= uart_cmd[7:0];
                        int_wr_en <= 1;

                        uart_raw_write_data <= 8'h2B; // print +
                        uart_raw_force_wr_en <= 1;
                    end else if (uart_cmd[8 * 6 - 1 : 8 * 5] == 8'hFA) begin // print command
                         int_addr <= uart_cmd[22:8];
                         uart_printing <= 1;
                      //   uart_cmd[7:0] <= uart_cmd[7:0] - 8'd1;

                        uart_raw_write_data <= 8'h2B; // print +
                        uart_raw_force_wr_en <= 1;
                    end


                    uart_reading <= 0;

                end else if (uart_reading) begin
                    uart_cmd <= {uart_cmd[47:0], raw_uart_rx_data};
                    if (uart_cmd_head == 1 && raw_uart_rx_data == 8'hFB) begin
                        uart_raw_write_data <= 8'h3C; // < - store command
                        uart_raw_force_wr_en <= 1;
                    end else if (uart_cmd_head == 1 && raw_uart_rx_data == 8'hFA) begin
                        uart_raw_write_data <= 8'h3E; // > - print command
                        uart_raw_force_wr_en <= 1;
                    end else if (uart_cmd_head == 1 && raw_uart_rx_data == 8'hF0) begin
                        uart_raw_write_data <= 8'h52; // R - run command
                        uart_raw_force_wr_en <= 1;

                        soc_mode <= `SOC_MODE_CPU_RUNNING;

                    end else begin
                        uart_raw_write_data <= raw_uart_rx_data; // echo back written data
                        uart_raw_force_wr_en <= 1;
                    end
                    uart_cmd_head <= uart_cmd_head + 16'd1;
                end
            end
        end else begin end
      end
    end


endmodule
