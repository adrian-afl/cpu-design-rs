module cpu (
    input clk,
    input rst,

    input [15:0] memory_readout,

    output reg [15:0] memory_writeout,
    output reg memory_write_enable,
    output reg [15:0] address_bus = 0,

    output [15:0] out_reg_x,
    output [15:0] out_reg_y,
    output [15:0] out_reg_accu,
    output [15:0] out_reg_pc,
    output [15:0] out_reg_sp,
    output out_carry
);

  `define INSTR_HALT 16'h0

  `define INSTR_STX_DIRECT 16'h10
  `define INSTR_STY_DIRECT 16'h11

  `define INSTR_MEM_LX_DIRECT 16'h12
  `define INSTR_MEM_LY_DIRECT 16'h13

  `define INSTR_MEM_LX_INDIRECT 16'h14
  `define INSTR_MEM_LY_INDIRECT 16'h15

  `define INSTR_MEM_SX_DIRECT 16'h16
  `define INSTR_MEM_SY_DIRECT 16'h17

  `define INSTR_MEM_SX_INDIRECT 16'h18
  `define INSTR_MEM_SY_INDIRECT 16'h19

  `define INSTR_ADD 16'h20
  `define INSTR_SUB 16'h21
  `define INSTR_MUL 16'h22
  `define INSTR_DIV 16'h23

  `define INSTR_MOVE_X_ACCU 16'h30
  `define INSTR_MOVE_Y_ACCU 16'h31
  `define INSTR_MOVE_X_Y 16'h32
  `define INSTR_MOVE_Y_X 16'h33
  `define INSTR_MOVE_ACCU_X 16'h34
  `define INSTR_MOVE_ACCU_Y 16'h35

  `define INTERNAL_STATE_PREPARE_FETCH_INSTR 8'd0
  `define INTERNAL_STATE_FETCH_INSTR 8'd1
  `define INTERNAL_STATE_FETCH_INSTR_DATA_BUS_PREFETCH 8'd2
  `define INTERNAL_STATE_EXEC 8'd3
  `define INTERNAL_STATE_FINALIZE 8'd4
  `define INTERNAL_STATE_HALTED 8'd5

  reg [ 8:0] current_state = 0;

  reg [15:0] reg_pc = 0;
  reg [15:0] reg_sp = 0;

  reg [15:0] reg_instr;
  reg [15:0] reg_instr_data;

  reg [15:0] reg_x;
  reg [15:0] reg_y;
  reg [16:0] reg_accu;

  always @(posedge clk) begin
    address_bus <= address_bus;
    reg_pc <= reg_pc;
    memory_write_enable <= 0;

    case (current_state)
      `INTERNAL_STATE_PREPARE_FETCH_INSTR: begin
        // prepare reading instruction, next cycle will have it ready
        address_bus   <= reg_pc;
        current_state <= `INTERNAL_STATE_FETCH_INSTR;
      end
      `INTERNAL_STATE_FETCH_INSTR: begin
        // fetch instruction 
        reg_instr <= memory_readout;
        address_bus <= reg_pc + 1;  // also prepare to read the instruction data
        current_state <= `INTERNAL_STATE_FETCH_INSTR_DATA_BUS_PREFETCH;
        // for debugging print next instruction and current registers
        case (memory_readout)
          `INSTR_STX_DIRECT:
          $display(
              "STX_DIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_STY_DIRECT:
          $display(
              "STY_DIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MEM_LX_DIRECT:
          $display(
              "MEM_LX_DIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MEM_LY_DIRECT:
          $display(
              "MEM_LY_DIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MEM_LX_INDIRECT:
          $display(
              "MEM_LX_INDIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MEM_LY_INDIRECT:
          $display(
              "MEM_LY_INDIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MEM_SX_DIRECT:
          $display(
              "MEM_SX_DIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MEM_SY_DIRECT:
          $display(
              "MEM_SY_DIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MEM_SX_INDIRECT:
          $display(
              "MEM_SX_INDIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MEM_SY_INDIRECT:
          $display(
              "MEM_SY_INDIRECT\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_ADD:
          $display(
              "ADD        \tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_SUB:
          $display(
              "SUB        \tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MUL:
          $display(
              "MUL        \tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_DIV:
          $display(
              "DIV        \tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MOVE_X_ACCU:
          $display(
              "MOVE_X_ACCU\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MOVE_Y_ACCU:
          $display(
              "MOVE_Y_ACCU\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MOVE_X_Y:
          $display(
              "MOVE_X_Y\tX %h, Y %h, ACCU %h, PC %h, SP %h", reg_x, reg_y, reg_accu, reg_pc, reg_sp
          );
          `INSTR_MOVE_Y_X:
          $display(
              "MOVE_Y_X\tX %h, Y %h, ACCU %h, PC %h, SP %h", reg_x, reg_y, reg_accu, reg_pc, reg_sp
          );
          `INSTR_MOVE_ACCU_X:
          $display(
              "MOVE_ACCU_X\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_MOVE_ACCU_Y:
          $display(
              "MOVE_ACCU_Y\tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
          `INSTR_HALT:
          $display(
              "HALT       \tX %h, Y %h, ACCU %h, PC %h, SP %h",
              reg_x,
              reg_y,
              reg_accu,
              reg_pc,
              reg_sp
          );
        endcase
      end
      `INTERNAL_STATE_FETCH_INSTR_DATA_BUS_PREFETCH: begin
        // fetch instruction data
        reg_instr_data <= memory_readout;
        current_state  <= `INTERNAL_STATE_EXEC;
        // if needed, prepare read for the instruction executor
        case (reg_instr)
          `INSTR_STX_DIRECT: reg_x <= memory_readout;
          `INSTR_STY_DIRECT: reg_y <= memory_readout;
          `INSTR_MEM_LX_DIRECT: address_bus <= memory_readout;
          `INSTR_MEM_LY_DIRECT: address_bus <= memory_readout;
          `INSTR_MEM_SX_DIRECT: address_bus <= memory_readout;
          `INSTR_MEM_SY_DIRECT: address_bus <= memory_readout;
          default: address_bus <= address_bus;
        endcase
      end
      `INTERNAL_STATE_EXEC: begin
        // execute instruction
        current_state <= `INTERNAL_STATE_FINALIZE;
        case (reg_instr)
          `INSTR_STX_DIRECT: reg_x <= reg_instr_data;
          `INSTR_STY_DIRECT: reg_y <= reg_instr_data;
          `INSTR_MEM_LX_DIRECT: reg_x <= memory_readout;
          `INSTR_MEM_LY_DIRECT: reg_y <= memory_readout;
          `INSTR_MEM_SX_DIRECT: begin
            memory_writeout <= reg_x;
            memory_write_enable <= 1;  // those enables get reset with next cycle
          end
          `INSTR_MEM_SY_DIRECT: begin
            memory_writeout <= reg_y;
            memory_write_enable <= 1;
          end
          `INSTR_ADD: reg_accu <= reg_x + reg_y;
          `INSTR_SUB: reg_accu <= reg_x - reg_y;
          `INSTR_MUL: reg_accu <= reg_x * reg_y;
          `INSTR_DIV: reg_accu <= reg_x / reg_y;
          `INSTR_HALT: current_state <= `INTERNAL_STATE_HALTED;
        endcase
      end
      `INTERNAL_STATE_FINALIZE: begin
        // advance PC, disable memwrite
        reg_pc <= reg_pc + 2;
        current_state <= `INTERNAL_STATE_PREPARE_FETCH_INSTR;
      end
      `INTERNAL_STATE_HALTED: begin
        reg_pc <= reg_pc + 2;
        current_state <= `INTERNAL_STATE_PREPARE_FETCH_INSTR;
      end
      default: begin
        current_state <= `INTERNAL_STATE_HALTED;
      end
    endcase

  end

  assign out_reg_x = reg_x;
  assign out_reg_y = reg_y;
  assign out_reg_accu = reg_accu[15:0];
  assign out_carry = reg_accu[16:15];
  assign out_reg_pc = reg_pc;
  assign out_reg_sp = reg_sp;

endmodule
