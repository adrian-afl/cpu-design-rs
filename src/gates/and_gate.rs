pub fn and_gate(input: &[bool]) -> bool {
    input.iter().fold(true, |a, &b| a && b)
}