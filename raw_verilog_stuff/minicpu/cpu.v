module cpu(
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

    reg [8:0] current_state = 0;

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
        $display ("current_state %d", current_state);	
        case(current_state)
            0:
                // prepare reading instruction
                address_bus <= reg_pc;
            1: begin
                    // fetch instruction 
                    reg_instr <= memory_readout;
                    $display ("reg_instr read from memory_readout %h", memory_readout);	
                    address_bus <= reg_pc + 1;
                    case(memory_readout) 
                        `INSTR_STX_DIRECT: $display("decoded instruction INSTR_STX_DIRECT");
                        `INSTR_STY_DIRECT: $display("decoded instruction INSTR_STY_DIRECT");
                        `INSTR_MEM_LX_DIRECT: $display("decoded instruction INSTR_MEM_LX_DIRECT");
                        `INSTR_MEM_LY_DIRECT: $display("decoded instruction INSTR_MEM_LY_DIRECT");
                        `INSTR_MEM_LX_INDIRECT: $display("decoded instruction INSTR_MEM_LX_INDIRECT");
                        `INSTR_MEM_LY_INDIRECT: $display("decoded instruction INSTR_MEM_LY_INDIRECT");
                        `INSTR_MEM_SX_DIRECT: $display("decoded instruction INSTR_MEM_SX_DIRECT");
                        `INSTR_MEM_SY_DIRECT: $display("decoded instruction INSTR_MEM_SY_DIRECT");
                        `INSTR_MEM_SX_INDIRECT: $display("decoded instruction INSTR_MEM_SX_INDIRECT");
                        `INSTR_MEM_SY_INDIRECT: $display("decoded instruction INSTR_MEM_SY_INDIRECT");
                        `INSTR_ADD: $display("decoded instruction INSTR_ADD");
                        `INSTR_SUB: $display("decoded instruction INSTR_SUB");
                        `INSTR_MUL: $display("decoded instruction INSTR_MUL");
                        `INSTR_DIV: $display("decoded instruction INSTR_DIV");
                        `INSTR_MOVE_X_ACCU: $display("decoded instruction INSTR_MOVE_X_ACCU");
                        `INSTR_MOVE_Y_ACCU: $display("decoded instruction INSTR_MOVE_Y_ACCU");
                        `INSTR_MOVE_X_Y: $display("decoded instruction INSTR_MOVE_X_Y");
                        `INSTR_MOVE_Y_X: $display("decoded instruction INSTR_MOVE_Y_X");
                        `INSTR_MOVE_ACCU_X: $display("decoded instruction INSTR_MOVE_ACCU_X");
                        `INSTR_MOVE_ACCU_Y: $display("decoded instruction INSTR_MOVE_ACCU_Y");
                    endcase
                end
            2: begin
                    // fetch instruction data
                    reg_instr_data <= memory_readout;
                    $display ("reg_instr_data read from memory_readout %h", memory_readout);	
                    // if needed, prepare read for the instruction
                    case(reg_instr)
                        `INSTR_STX_DIRECT:
                            reg_x <= memory_readout;
                        `INSTR_STY_DIRECT:
                            reg_y <= memory_readout;
                        `INSTR_MEM_LX_DIRECT:begin
                                $display ("preparing read from %h", memory_readout);	
                                address_bus <= memory_readout;
                            end
                        `INSTR_MEM_LY_DIRECT:begin
                                $display ("preparing read from %h", memory_readout);	
                                address_bus <= memory_readout;
                            end
                        `INSTR_MEM_SX_DIRECT: 
                            address_bus <= memory_readout;
                        `INSTR_MEM_SY_DIRECT:
                            address_bus <= memory_readout;
                        default: 
                            address_bus <= address_bus;
                    endcase
                end
            3:
                // execute instruction
                case(reg_instr)
                    `INSTR_STX_DIRECT:
                        reg_x <= reg_instr_data;
                    `INSTR_STY_DIRECT:
                        reg_y <= reg_instr_data;
                    `INSTR_MEM_LX_DIRECT: begin
                        $display ("reading %h", memory_readout);	
                        reg_x <= memory_readout;
                    end
                    `INSTR_MEM_LY_DIRECT:
                        reg_y <= memory_readout;
                    `INSTR_MEM_SX_DIRECT: begin
                        memory_writeout <= reg_x;
                        memory_write_enable <= 1;
                        $display ("writing %h to %h", reg_x, address_bus);	
                    end
                    `INSTR_MEM_SY_DIRECT:begin
                        memory_writeout <= reg_y;
                        memory_write_enable <= 1;
                    end
                    `INSTR_ADD:
                        reg_accu <= reg_x + reg_y;
                    `INSTR_SUB:
                        reg_accu <= reg_x - reg_y;
                    `INSTR_MUL:
                        reg_accu <= reg_x * reg_y;
                    `INSTR_DIV:
                        reg_accu <= reg_x / reg_y;
                endcase
            4:begin
                // advance PC, disable memwrite
                reg_pc <= reg_pc + 2;
                memory_write_enable <= 0;
            end
            default:
                reg_pc <= reg_pc;
        endcase

        current_state <= (current_state + 1) % 5;
    end

    assign out_reg_x = reg_x;
    assign out_reg_y = reg_y;
    assign out_reg_accu = reg_accu[15:0];
    assign out_carry = reg_accu[16:15];
    assign out_reg_pc = reg_pc;
    assign out_reg_sp = reg_sp;

endmodule