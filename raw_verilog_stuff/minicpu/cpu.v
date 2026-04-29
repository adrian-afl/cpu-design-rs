module cpu(
    input clk,
    input rst,
    input [7:0] instr,
    input [15:0] instr_data,

    output [15:0] out_reg_x,
    output [15:0] out_reg_y,
    output [15:0] out_reg_accu
);

`define INSTR_STX_DIRECT 8'h10
`define INSTR_STY_DIRECT 8'h11
`define INSTR_ADD 8'h20

    reg [15:0] reg_x;
    reg [15:0] reg_y;
    reg [15:0] reg_accu;

    always @(posedge clk) begin
        case(instr)
            `INSTR_STX_DIRECT:
                reg_x <= instr_data;
            `INSTR_STY_DIRECT:
                reg_y <= instr_data;
            `INSTR_ADD:
                reg_accu <= reg_x + reg_y;
        endcase
    end

    assign out_reg_x = reg_x;
    assign out_reg_y = reg_y;
    assign out_reg_accu = reg_accu;

endmodule