module cpu (
    input clk,
    input rst,

    input [7:0] rdata,

    output reg [7:0] wdata = 0,
    output reg wr_en = 0,
    output reg [31:0] addr = 0
);

  // instructions, see idea.md for what is going on

  `define INSTR_HALT 8'h00
  `define INSTR_CRYCLR 8'h01
  `define INSTR_SPUSH 8'h02
  `define INSTR_SPOP 8'h03

  `define INSTR_MOV 8'h10
  `define INSTR_PUT 8'h11

  `define INSTR_ADD 8'h20
  `define INSTR_SUB 8'h21
  `define INSTR_MUL 8'h22
  `define INSTR_DIV 8'h23

  `define INSTR_JEQ 8'h30
  `define INSTR_JCRY 8'h31

  // states that definitely will get reworked heavily maybe
  // even state machine per instruction would be reasonable
  // as there are so little instructions that are wildly different

  // `define INTERNAL_STATE_PREPARE_FETCH_INSTR 8'd0
  // `define INTERNAL_STATE_FETCH_INSTR 8'd1
  // `define INTERNAL_STATE_FETCH_INSTR_DATA_BUS_PREFETCH 8'd2
  // `define INTERNAL_STATE_EXEC 8'd3
  // `define INTERNAL_STATE_FINALIZE 8'd4
  // `define INTERNAL_STATE_HALTED 8'd5


  `define INTERNAL_STATE_PREPARE_FETCH_INSTRUCTION 8'd0
  `define INTERNAL_STATE_FETCH_INSTRUCTION 8'd1
  `define INTERNAL_STATE_FETCH_ADDRESSING 8'd2
  `define INTERNAL_STATE_FETCH_INTO_DATA 8'd3
  `define INTERNAL_STATE_RESOLVE_D1_ONCE 8'd6
  `define INTERNAL_STATE_RESOLVE_D2_ONCE 8'd7
  `define INTERNAL_STATE_RESOLVE_D3_ONCE 8'd8
  `define INTERNAL_STATE_EXEC 8'd9
  `define INTERNAL_STATE_FINALIZE 8'd10
  `define INTERNAL_STATE_HALTED 8'hFF

  `define INTERNAL_ADRESSING_DIRECT 8'b00
  `define INTERNAL_ADRESSING_INDIRECT 8'b01
  `define INTERNAL_ADRESSING_ABSOLUTE 8'b00
  `define INTERNAL_ADRESSING_RELATIVE 8'b01

  reg [7:0] cursor = 0;  // for multi byte reads

  reg [7:0] current_state = 0;

  reg [15:0] reg_pc = 0;
  reg [15:0] reg_sp = 0;

  reg [7:0] reg_instr;
  reg [2:0] addressing_d1 = 0;
  reg [2:0] addressing_d2 = 0;
  reg [2:0] addressing_d3 = 0;
  reg [32 * 3 - 1:0] reg_instr_data_full;
  wire [31:0] reg_instr_data_1;
  wire [31:0] reg_instr_data_2;
  wire [31:0] reg_instr_data_3;

  assign reg_instr_data_1 = reg_instr_data_full[32*1-1:32*0];
  assign reg_instr_data_2 = reg_instr_data_full[32*2-1:32*1];
  assign reg_instr_data_3 = reg_instr_data_full[32*3-1:32*2];

  `define LOADER_STATE_INACTIVE 0
  `define LOADER_STATE_PREPARE_8B 1
  `define LOADER_STATE_PREPARE_32B 2
  `define LOADER_STATE_LOADING 3

  reg [2:0] resolve_d1_state = `LOADER_STATE_INACTIVE;
  reg [2:0] resolve_d2_state = `LOADER_STATE_INACTIVE;
  reg [2:0] resolve_d3_state = `LOADER_STATE_INACTIVE;

  reg [2:0] param_loader_state = `LOADER_STATE_INACTIVE;

  always @(posedge clk) begin
    if (resolve_d1_state > `LOADER_STATE_INACTIVE) begin
      case (resolve_d1_state)
        `LOADER_STATE_PREPARE_8B: begin
          $display("resolve_d1, prepare read 8b from %h", reg_instr_data_1);
          addr <= reg_instr_data_1;
          cursor <= 0;
          resolve_d1_state <= `LOADER_STATE_LOADING;
        end
        `LOADER_STATE_PREPARE_32B: begin
          $display("resolve_d1, prepare read 32b from %h", reg_instr_data_1);
          addr <= reg_instr_data_1;
          cursor <= 3;
          resolve_d1_state <= `LOADER_STATE_LOADING;
        end
        `LOADER_STATE_LOADING: begin
          cursor <= cursor - 1;
          addr   <= addr + 1;
          $display("resolve_d1, cursor %d", cursor);
          case (cursor)
            3: reg_instr_data_full[8*1-1:8*0] <= rdata;
            2: reg_instr_data_full[8*2-1:8*1] <= rdata;
            1: reg_instr_data_full[8*3-1:8*2] <= rdata;
            0: begin
              reg_instr_data_full[8*4-1:8*3] <= rdata;
              resolve_d1_state <= `LOADER_STATE_INACTIVE;
            end
          endcase
        end
      endcase

    end else if (resolve_d2_state > `LOADER_STATE_INACTIVE) begin
      case (resolve_d2_state)
        `LOADER_STATE_PREPARE_8B: begin
          $display("resolve_d2, prepare read 8n from %h", reg_instr_data_2);
          addr <= reg_instr_data_2;
          cursor <= 0;
          resolve_d2_state <= `LOADER_STATE_LOADING;
        end
        `LOADER_STATE_PREPARE_32B: begin
          $display("resolve_d2, prepare read 32b from %h", reg_instr_data_2);
          addr <= reg_instr_data_2;
          cursor <= 3;
          resolve_d1_state <= `LOADER_STATE_LOADING;
        end
        `LOADER_STATE_LOADING: begin
          cursor <= cursor - 1;
          addr   <= addr + 1;
          $display("resolve_d2, cursor %d", cursor);
          case (cursor)
            3: reg_instr_data_full[8*5-1:8*4] <= rdata;
            2: reg_instr_data_full[8*6-1:8*5] <= rdata;
            1: reg_instr_data_full[8*7-1:8*6] <= rdata;
            0: begin
              reg_instr_data_full[8*8-1:8*7] <= rdata;
              resolve_d2_state <= `LOADER_STATE_INACTIVE;
            end
          endcase
        end
      endcase

    end else if (resolve_d3_state > `LOADER_STATE_INACTIVE) begin
      case (resolve_d3_state)
        `LOADER_STATE_PREPARE_8B: begin
          $display("resolve_d3, prepare read 8n from %h", reg_instr_data_3);
          addr <= reg_instr_data_3;
          cursor <= 0;
          resolve_d2_state <= `LOADER_STATE_LOADING;
        end
        `LOADER_STATE_PREPARE_32B: begin
          $display("resolve_d3, prepare read 32b from %h", reg_instr_data_3);
          addr <= reg_instr_data_3;
          cursor <= 3;
          resolve_d1_state <= `LOADER_STATE_LOADING;
        end
        `LOADER_STATE_LOADING: begin
          cursor <= cursor - 1;
          addr   <= addr + 1;
          $display("resolve_d3, cursor %d", cursor);
          case (cursor)
            3: reg_instr_data_full[8*9-1:8*8] <= rdata;
            2: reg_instr_data_full[8*10-1:8*9] <= rdata;
            1: reg_instr_data_full[8*11-1:8*10] <= rdata;
            0: begin
              reg_instr_data_full[8*12-1:8*11] <= rdata;
              resolve_d3_state <= `LOADER_STATE_INACTIVE;
            end
          endcase
        end
      endcase

    end else begin

      addr   <= addr;
      reg_pc <= reg_pc;
      wr_en  <= 0;

      case (current_state)
        `INTERNAL_STATE_PREPARE_FETCH_INSTRUCTION: begin
          $display("INTERNAL_STATE_PREPARE_FETCH_INSTRUCTION");
          // prepare reading instruction, next cycle will have it ready
          addr <= reg_pc;
          current_state <= `INTERNAL_STATE_FETCH_INSTRUCTION;
        end
        `INTERNAL_STATE_FETCH_INSTRUCTION: begin
          $display("INTERNAL_STATE_FETCH_INSTRUCTION");
          // fetch instruction 
          reg_instr <= rdata;
          addr <= reg_pc + 1;  // also prepare to read the addressiing
          current_state <= `INTERNAL_STATE_FETCH_ADDRESSING;
          // for debugging print next instruction and current registers
          case (rdata)
            `INSTR_PUT: $display("PUT");
            `INSTR_MOV: $display("MOV");
            `INSTR_HALT: $display("HALT");
            default: $display("Unknown instruction %h at %h", rdata, reg_pc);
          endcase

          // case (rdata)
          //   `INSTR_ADD:
          //   $display(
          //       "ADD        \tX %h, Y %h, ACCU %h, PC %h, SP %h",
          //       reg_x,
          //       reg_y,
          //       reg_accu,
          //       reg_pc,
          //       reg_sp
          //   );
          //   `INSTR_SUB:
          //   $display(
          //       "SUB        \tX %h, Y %h, ACCU %h, PC %h, SP %h",
          //       reg_x,
          //       reg_y,
          //       reg_accu,
          //       reg_pc,
          //       reg_sp
          //   );
          //   `INSTR_MUL:
          //   $display(
          //       "MUL        \tX %h, Y %h, ACCU %h, PC %h, SP %h",
          //       reg_x,
          //       reg_y,
          //       reg_accu,
          //       reg_pc,
          //       reg_sp
          //   );
          //   `INSTR_DIV:
          //   $display(
          //       "DIV        \tX %h, Y %h, ACCU %h, PC %h, SP %h",
          //       reg_x,
          //       reg_y,
          //       reg_accu,
          //       reg_pc,
          //       reg_sp
          //   );
          //   `INSTR_HALT:
          //   $display(
          //       "HALT       \tX %h, Y %h, ACCU %h, PC %h, SP %h",
          //       reg_x,
          //       reg_y,
          //       reg_accu,
          //       reg_pc,
          //       reg_sp
          //   );
          // endcase
        end
        `INTERNAL_STATE_FETCH_ADDRESSING: begin
          $display("INTERNAL_STATE_FETCH_ADDRESSING");
          addressing_d1 <= rdata[3:2];
          addressing_d2 <= rdata[2:1];
          addressing_d3 <= rdata[1:0];
          addr <= reg_pc;
          case (reg_instr)
            `INSTR_PUT: begin
              // put gotta read one thing into D1
              current_state <= `INTERNAL_STATE_FETCH_INTO_DATA;
              cursor <= 4;  // read 4 bytes so d1 is filled with 32 bits
                            // and additional byte into d2 which is the value to save
              addr <= reg_pc + 1 + 4 + 1;  // im not sure why this eactly needs to be 1 byte off
            end
            `INSTR_MOV: begin
              // mov gotta read one thing into D1 and D2
              current_state <= `INTERNAL_STATE_FETCH_INTO_DATA;
              cursor <= 7;  // read 8 bytes so d1 and d2 are filled with 32 bits
              addr <= reg_pc + 1 + 7 + 1;
            end
            default: current_state <= `INTERNAL_STATE_EXEC;
          endcase
        end
        `INTERNAL_STATE_FETCH_INTO_DATA: begin
          cursor <= cursor - 1;
          addr   <= reg_pc + 1 + cursor;
          $display("INTERNAL_STATE_FETCH_INTO_DATA, cursor %d", cursor);
          case (cursor)
            3: begin
              reg_instr_data_full[8*1-1:8*0] <= rdata;
            end
            2: begin
              reg_instr_data_full[8*2-1:8*1] <= rdata;
            end
            1: begin
              reg_instr_data_full[8*3-1:8*2] <= rdata;
            end
            0: begin
              reg_instr_data_full[8*4-1:8*3] <= rdata;

              case (reg_instr)
                `INSTR_PUT: begin
                  if (addressing_d1 == `INTERNAL_ADRESSING_INDIRECT)
                    resolve_d1_state <= `LOADER_STATE_PREPARE_32B;
                end
                `INSTR_MOV: begin
                  resolve_d1_state <= `LOADER_STATE_PREPARE_8B;
                  if (addressing_d2 == `INTERNAL_ADRESSING_INDIRECT)
                    resolve_d2_state <= `LOADER_STATE_PREPARE_32B;
                end
              endcase

              current_state <= `INTERNAL_STATE_EXEC;
            end
            7: begin
              reg_instr_data_full[8*5-1:8*4] <= rdata;
            end
            6: begin
              reg_instr_data_full[8*6-1:8*5] <= rdata;
            end
            5: begin
              reg_instr_data_full[8*7-1:8*6] <= rdata;
            end
            4: begin
              reg_instr_data_full[8*8-1:8*7] <= rdata;
            end
            11: begin
              reg_instr_data_full[8*9-1:8*8] <= rdata;
            end
            10: begin
              reg_instr_data_full[8*10-1:8*9] <= rdata;
            end
            9: begin
              reg_instr_data_full[8*11-1:8*10] <= rdata;
            end
            8: begin
              reg_instr_data_full[8*12-1:8*11] <= rdata;
            end
            default: begin
              cursor <= 0;
            end
          endcase
        end
        `INTERNAL_STATE_EXEC: begin
          $display("INTERNAL_STATE_EXEC");

          // execute instruction
          current_state <= `INTERNAL_STATE_FINALIZE;
          case (reg_instr)
            `INSTR_PUT: begin
              $display("reg_instr_data_1 %h", reg_instr_data_1);
              $display("reg_instr_data_2 %h", reg_instr_data_2);
              $display("reg_instr_data_3 %h", reg_instr_data_3);
              wr_en <= 1;
              addr  <= reg_instr_data_1;
              wdata <= reg_instr_data_2[31:24];
            end
            `INSTR_MOV: begin
              $display("reg_instr_data_1 %h", reg_instr_data_1);
              $display("reg_instr_data_2 %h", reg_instr_data_2);
              $display("reg_instr_data_3 %h", reg_instr_data_3);
              $display("reg_instr_data_full %h", reg_instr_data_full);
              wr_en <= 1;
              addr  <= reg_instr_data_2;
              wdata <= reg_instr_data_1[31:24];
            end
            `INSTR_HALT: current_state <= `INTERNAL_STATE_HALTED;
          endcase
        end
        `INTERNAL_STATE_HALTED: begin
          // $display("INTERNAL_STATE_HALTED");
          current_state <= `INTERNAL_STATE_HALTED;
        end
        `INTERNAL_STATE_FINALIZE: begin
          $display("INTERNAL_STATE_FINALIZE");
          wr_en <= 0;

          // as instrutionas vary in size pc needs to be adjusted accordingly


          case (reg_instr)
            `INSTR_PUT: reg_pc <= reg_pc + 1 + 1 + 4 + 1;  // opcode, adressing, d1, value
            `INSTR_MOV: reg_pc <= reg_pc + 1 + 4 + 4 + 1;  // opcode, adressing, d1, d2
            `INSTR_HALT: reg_pc <= reg_pc + 1 + 1;  // opcode
            default: reg_pc <= reg_pc;
          endcase
          current_state <= `INTERNAL_STATE_PREPARE_FETCH_INSTRUCTION;
        end
        default: begin
          $display("UNKNOWN STATE!!");
          current_state <= `INTERNAL_STATE_HALTED;
        end
      endcase

    end
  end

endmodule
