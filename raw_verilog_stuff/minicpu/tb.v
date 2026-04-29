`include "cpu.v"
module counter_tb();

// Declare inputs as regs and outputs as wires
    reg [15:0] ram [0:(16 * 1024)];

    wire [15:0] memory_readout;

    wire [15:0] memory_writeout;
    wire memory_write_enable;
    wire [15:0] address_bus;

    wire [15:0] out_reg_x;
    wire [15:0] out_reg_y;
    wire [15:0] out_reg_accu;
    wire [15:0] out_reg_pc;
    wire [15:0] out_reg_sp;

    reg run_signal;

    (* keep = "true", syn_preserve = 1 *)
    cpu i_cpu1(
        .clk(run_signal),
        .rst(1'b0), // no reset for now
        .memory_readout(memory_readout),
        .memory_writeout(memory_writeout),
        .memory_write_enable(memory_write_enable),
        .address_bus(address_bus),
        .out_reg_x(out_reg_x),
        .out_reg_y(out_reg_y),
        .out_reg_accu(out_reg_accu),
        .out_reg_pc(out_reg_pc),
        .out_reg_sp(out_reg_sp)
    );

    assign memory_readout = ram[address_bus];

    always @(negedge run_signal) begin
        if(memory_write_enable) begin
            $display ("REALLY in TB writing %h to %h", memory_writeout, address_bus);	
            ram[address_bus] <= memory_writeout;
        end
    end


  integer i = 0;
// Initialize all variables
initial begin     
    

   //$dumpfile("test.vcd");
//    $dumpvars(0,run_signal);
//    $dumpvars(1,instr);

//   $display ("time\trun_signal\tinstr\tX\tY, ACCU");	
  $monitor ("T%g\t CLK %b, address_bus %h, memory_readout %h, X %h, Y %h, ACCU %h, PC %h, SP %h", 
	  $time, run_signal, address_bus, memory_readout, out_reg_x, out_reg_y, out_reg_accu, out_reg_pc, out_reg_sp);

// x = 0x6
 ram[0] = `INSTR_STX_DIRECT;
 ram[1] = 16'h6;

// y = 0x3
 ram[2] = `INSTR_STY_DIRECT;
 ram[3] = 16'h3;

// accu = x/y = 2
 ram[4] = `INSTR_DIV;
 ram[5] = 16'h0;

// x = 0x32
 ram[6] = `INSTR_STX_DIRECT;
 ram[7] = 16'h32;

// ram[0x0102] = x = 0x32
 ram[8] = `INSTR_MEM_SX_DIRECT;
 ram[9] = 16'h0102;

// x = 0x36
 ram[10] = `INSTR_STX_DIRECT;
 ram[11] = 16'h36;

// ram[0x0103] = x = 0x36
 ram[12] = `INSTR_MEM_SX_DIRECT;
 ram[13] = 16'h0103;

// x = ram[0x0102] = 0x32 
 ram[14] = `INSTR_MEM_LX_DIRECT;
 ram[15] = 16'h0102;

    for (i = 0; i < 16 * 4; i = i + 1) begin
        #5 run_signal = 1;
        #5 run_signal = 0;
    end

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

endmodule
