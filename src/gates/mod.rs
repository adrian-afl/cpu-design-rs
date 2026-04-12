pub fn and_gate(input: &[f32], zero_v: f32, one_v: f32) -> f32 {
    let threshold = (zero_v + one_v) * 0.5;
    let logical = input
        .iter()
        .fold(true, |a, &b| a && (b > threshold));
    if logical { one_v } else { zero_v }
}

pub fn not_gate(input: f32, zero_v: f32, one_v: f32) -> f32 {
    let threshold = (zero_v + one_v) * 0.5;
    let logical = !(input > threshold);
    if logical { one_v } else { zero_v }
}

pub fn or_gate(input: &[f32], zero_v: f32, one_v: f32) -> f32 {
    let threshold = (zero_v + one_v) * 0.5;
    let logical = input.iter().fold(false, |a, &b| a || (b > threshold));
    if logical { one_v } else { zero_v }
}

pub fn xor_gate(input: &[f32], zero_v: f32, one_v: f32) -> f32 {
    let threshold = (zero_v + one_v) * 0.5;
    let logical = input.iter().fold(false, |a, &b| a ^ (b > threshold));
    if logical { one_v } else { zero_v }
}
