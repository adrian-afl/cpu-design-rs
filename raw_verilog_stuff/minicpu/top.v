module top(
    input   clk,

    input rst,
    input shifter_data_in,
    input shifter_store_signal,
    input run_signal,
    input read_signal,

    output shifter_data_out
);

    reg [7:0] instr;
    reg [15:0] instr_data;

    reg [23:0] instr_and_instr_data;

    wire [15:0] out_reg_x;
    wire [15:0] out_reg_y;
    wire [15:0] out_reg_accu;

    always @(posedge shifter_store_signal) begin
        instr_and_instr_data[23:1] <= instr_and_instr_data[22:0];
        instr_and_instr_data[0] <= shifter_data_in;
        instr <= instr_and_instr_data[7:0];
        instr_data <= instr_and_instr_data[23:8];
    end

    reg [8:0] transmit_shift;
    reg transmit_accu;

//    always @(posedge clk) begin
//        transmit_shift <= (transmit_shift + 1) % 8;
//    end

//    assign shifter_data_out = out_reg_x[transmit_shift];

    (* keep = "true", syn_preserve = 1 *)
    cpu i_cpu1(
        .clk(run_signal),
        .rst(1'b0), // no reset for now
        .instr(instr),
        .instr_data(instr_data),
        .out_reg_x(out_reg_x),
        .out_reg_y(out_reg_y),
        .out_reg_accu(out_reg_accu)
    );

endmodule