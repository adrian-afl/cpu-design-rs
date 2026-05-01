module pulse_gen #(
    parameter integer CLK_FRE = 27, // in MHZ
    parameter integer MILISECONDS = 500
) (
    input            clk,
    input            rst,
    output          reg pulse_out
);
  localparam integer ONE_MS_CNT = CLK_FRE * 1000; // this is how much cycles will pass in 1 milisecond

  reg [31:0] counter;

  localparam integer PULSE_PERIOD = ONE_MS_CNT * MILISECONDS;

  always @(posedge clk) begin
    if (rst) begin 
        counter <= 0;
        pulse_out <= 0;
    end else begin 
        counter <= counter + 1;
        pulse_out <= 0;
        if (counter >= PULSE_PERIOD) begin 
            counter <= 0;
            pulse_out <= 1;
        end 
      end
    end
endmodule