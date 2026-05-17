use crate::verilog_stuff::simple_wrappers::{assign_full, delay, module, reg_wide, timescale};

mod verilog_stuff;

fn main() {
    timescale(1, 1);

    module("tralala", &[], &[
        ("clock", 1..0),
        ("reset", 1..0),
    ], &[
        ("uart_data", 7..0)
    ], || {
        delay(5);
        reg_wide("myregister", 7..0);
        delay(5);
        assign_full("uart_data", "myregister");
    });
}
