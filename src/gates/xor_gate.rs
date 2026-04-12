pub fn xor_gate(input: &[bool]) -> bool {
    input.iter().fold(false, |a, &b| a ^ b)
}
