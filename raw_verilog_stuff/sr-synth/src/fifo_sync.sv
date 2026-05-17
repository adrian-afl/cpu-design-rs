module fifo_sync #(
    parameter integer WIDTH = 8,
    parameter integer DEPTH = 64
) (
    input              clock,
    input              n_reset,
    input              enqueue_enable,
    input  [WIDTH-1:0] data_in,
    input              dequeue_enable,
    output [WIDTH-1:0] data_out,
    output             is_full,
    output             is_empty
);
  // address width
  localparam integer ADDRWIDTH = (DEPTH <= 1) ? 1 : $clog2(DEPTH);

  reg [WIDTH-1:0] memory[DEPTH-1];
  reg [ADDRWIDTH-1:0] write_ptr, read_ptr;
  reg [ADDRWIDTH:0] count;

  assign is_empty = (count == {(ADDRWIDTH + 1) {1'b0}});
  assign is_full  = (count >= DEPTH[ADDRWIDTH:0]);
  assign data_out = memory[read_ptr];

  wire do_enqueue = enqueue_enable && !is_full;
  wire do_dequeue = dequeue_enable && !is_empty;

  always_ff @(posedge clock or negedge n_reset) begin
    if (!n_reset) begin
      write_ptr <= {ADDRWIDTH{1'b0}};
      read_ptr <= {ADDRWIDTH{1'b0}};
      count <= {(ADDRWIDTH + 1) {1'b0}};
      memory[0] <= {WIDTH{1'b0}};
    end else begin
      count <= count;

      if (do_enqueue) begin
        memory[write_ptr] <= data_in;
        write_ptr <= write_ptr + {{(ADDRWIDTH - 1) {1'b0}}, 1'b1};
      end

      if (do_dequeue) begin
        read_ptr <= read_ptr + {{(ADDRWIDTH - 1) {1'b0}}, 1'b1};
      end

      case ({
        do_enqueue, do_dequeue
      })
        2'b10:   count <= count + 1'b1;
        2'b01:   count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end

endmodule
