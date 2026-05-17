module sync_2ff (
    input  clock,
    input  n_reset,
    input  unstable_async_signal,
    output stable_signal
);
  reg level1;
  reg level2;
  assign stable_signal = level2;

  always_ff @(posedge clock or negedge n_reset) begin
    if (!n_reset) begin
      level1 <= 1'b1;
      level2 <= 1'b1;
    end else begin
      level1 <= unstable_async_signal;
      level2 <= level1;
    end
  end

endmodule
