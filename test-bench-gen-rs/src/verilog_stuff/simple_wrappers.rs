use std::ops::Range;

pub fn range_to_str(range: &Range<u16>) -> String {
    if range.start == 1 && range.end == 0 {
        return "".to_owned();
    }
    format!("[{}:{}]", range.start, range.end)
}

pub fn wire_wide(name: &str, range: Range<u16>) -> String {
    println!("wire {} {};", range_to_str(&range), name);
    name.to_string()
}

pub fn wire_signal(name: &str) -> String {
    println!("wire {};", name);
    name.to_string()
}

pub fn reg_wide(name: &str, range: Range<u16>) -> String {
    println!("reg {} {};", range_to_str(&range), name);
    name.to_string()
}

pub fn reg_signal(name: &str) -> String {
    println!("reg {};", name);
    name.to_string()
}

pub fn assign_full(to: &str, from: &str) {
    println!("assign {to} = {from};")
}

pub fn assign_partial(to: &str, to_range: Range<u16>, from: &str, from_range: Range<u16>) {
    println!(
        "assign {to}{} = {from}{};",
        range_to_str(&to_range), range_to_str(&from_range)
    )
}

pub fn timescale(time_unit_nanoseconds: u16, time_precision: u16) {
    println!("`timescale {time_unit_nanoseconds}ns/{time_precision}ns")
}

pub fn delay(time_units: u64) {
    println!("#{time_units}")
}

pub fn vif(expression: &str, tru: impl Fn(), els: impl Fn()) {
    println!("if {expression} begin");
    tru();
    println!("end else begin");
    els();
    println!("end");
}

pub fn vcase(expression: &str, arms: &[(&str, impl Fn())]) {
    println!("case {expression} begin");
    for (expression, arm) in arms {
        println!("case {expression}: begin");
        arm();
        println!("end");
    }
    println!("endcase");
}

pub fn vline(raw: &str) {
    println!("{raw};")
}

pub fn module(
    name: &str,
    parameters: &[(&str, &str)],
    inputs: &[(&str, Range<u16>)],
    outputs: &[(&str, Range<u16>)],
    body: impl Fn(),
) {
    let parameters_str = parameters
        .iter()
        .map(|(name, default)| format!("parameter integer {name} = {default}"))
        .collect::<Vec<_>>()
        .join(",\n");

    let inputs_str = inputs
        .iter()
        .map(|(name, range)| format!("input {} {name}", range_to_str(range)))
        .collect::<Vec<_>>()
        .join(",\n");

    let outputs_str = outputs
        .iter()
        .map(|(name, range)| format!("output {} {name}", range_to_str(range)))
        .collect::<Vec<_>>()
        .join(",\n");

    println!("module {name} #({}) ({});", parameters_str, &[inputs_str, outputs_str].join(",\n"));
    body();
    println!("endmodule");
}
