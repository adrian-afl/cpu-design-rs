`include "cpu.v"
module counter_tb();
// Declare inputs as regs and outputs as wires
    reg [7:0] instr;
    reg [15:0] instr_data;

    wire [15:0] out_reg_x;
    wire [15:0] out_reg_y;
    wire [15:0] out_reg_accu;

    reg run_signal;

// Initialize all variables
initial begin        
   //$dumpfile("test.vcd");
   $dumpvars(0,run_signal);
   $dumpvars(1,instr);

//   $display ("time\trun_signal\tinstr\tX\tY, ACCU");	
  $monitor ("T%g\t CLK %b, INSTR %h, INSTR_DATA %h, X %h, Y %h, ACCU %h", 
	  $time, run_signal, instr, instr_data, out_reg_x, out_reg_y, out_reg_accu);

//   $display ("time\t clk reset counter");	
//   $monitor ("%g\t %b   %b   %b", 
// 	  $time, clock, reset, counter_out);	
  run_signal = 0;       // initial value of clock
  instr = `INSTR_STX_DIRECT;
  instr_data = 16'h6;
  #5 run_signal = 1;
  #5 run_signal = 0;

  instr = `INSTR_STY_DIRECT;
  instr_data = 16'h6;
  #5 run_signal = 1;
  #5 run_signal = 0;

  instr = `INSTR_DIV;
  instr_data = 16'h00;
  #5 run_signal = 1;
  #5 run_signal = 0;

$display ("setting X to 0x32");	

  instr = `INSTR_STX_DIRECT;
  instr_data = 16'h32;
  #5 run_signal = 1;
  #5 run_signal = 0;

$display ("storing X to 0x0102");	

  instr = `INSTR_MEM_SX_DIRECT;
  instr_data = 16'h0102;
  #5 run_signal = 1;
  #5 run_signal = 0;

$display ("setting X to 0x36");	

  instr = `INSTR_STX_DIRECT;
  instr_data = 16'h36;
  #5 run_signal = 1;
  #5 run_signal = 0;

$display ("storing X to 0x0103");	

  instr = `INSTR_MEM_SX_DIRECT;
  instr_data = 16'h0103;
  #5 run_signal = 1;
  #5 run_signal = 0;

$display ("loading X from 0x0102");	

  instr = `INSTR_MEM_LX_DIRECT;
  instr_data = 16'h0102;
  #5 run_signal = 1;
  #5 run_signal = 0;

  #50 $finish;      // Terminate simulation
end

// // Clock generator
// always begin
//   #5 clock = ~clock; // Toggle clock every 5 ticks
// end

// Connect DUT to test bench


    // always @(posedge shifter_store_signal) begin
    //     instr_and_instr_data[23:1] <= instr_and_instr_data[22:0];
    //     instr_and_instr_data[0] <= shifter_data_in;
    //     instr <= instr_and_instr_data[7:0];
    //     instr_data <= instr_and_instr_data[23:8];
    // end

    // reg [8:0] transmit_shift;
    // reg transmit_accu;

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
