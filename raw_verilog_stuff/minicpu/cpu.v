module cpu(
    input clk,
    input rst,
    input [7:0] instr,
    input [15:0] instr_data,

    output [15:0] out_reg_x,
    output [15:0] out_reg_y,
    output [15:0] out_reg_accu,
    output out_carry
);

`define INSTR_STX_DIRECT 8'h10
`define INSTR_STY_DIRECT 8'h11

`define INSTR_MEM_LX_DIRECT 8'h12
`define INSTR_MEM_LY_DIRECT 8'h13

`define INSTR_MEM_LX_INDIRECT 8'h14
`define INSTR_MEM_LY_INDIRECT 8'h15

`define INSTR_MEM_SX_DIRECT 8'h16
`define INSTR_MEM_SY_DIRECT 8'h17

`define INSTR_MEM_SX_INDIRECT 8'h18
`define INSTR_MEM_SY_INDIRECT 8'h19

`define INSTR_ADD 8'h20
`define INSTR_SUB 8'h21
`define INSTR_MUL 8'h22
`define INSTR_DIV 8'h23

`define INSTR_MOVE_X_ACCU 8'h30
`define INSTR_MOVE_Y_ACCU 8'h31
`define INSTR_MOVE_X_Y 8'h32
`define INSTR_MOVE_Y_X 8'h33
`define INSTR_MOVE_ACCU_X 8'h34
`define INSTR_MOVE_ACCU_Y 8'h35

    reg [15:0] ram [16384:0];

    reg [15:0] reg_x;
    reg [15:0] reg_y;
    reg [16:0] reg_accu;

    always @(posedge clk) begin
        case(instr)
            `INSTR_STX_DIRECT:
                reg_x <= instr_data;
            `INSTR_STY_DIRECT:
                reg_y <= instr_data;
            `INSTR_MEM_LX_DIRECT:
                reg_x <= ram[instr_data[15:0]];
            `INSTR_MEM_LY_DIRECT:
                reg_y <= ram[instr_data[15:0]];
            `INSTR_MEM_SX_DIRECT:
                ram[instr_data[15:0]] <= reg_x;
            `INSTR_MEM_SY_DIRECT:
                ram[instr_data[15:0]] <= reg_y;
            `INSTR_ADD:
                reg_accu <= reg_x + reg_y;
            `INSTR_SUB:
                reg_accu <= reg_x - reg_y;
            `INSTR_MUL:
                reg_accu <= reg_x * reg_y;
            `INSTR_DIV:
                reg_accu <= reg_x / reg_y;
        endcase
    end

    assign out_reg_x = reg_x;
    assign out_reg_y = reg_y;
    assign out_reg_accu = reg_accu[15:0];
    assign out_carry = reg_accu[16:15];

endmodule