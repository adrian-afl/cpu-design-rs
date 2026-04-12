use std::sync::atomic::{AtomicU64, Ordering};

static ELEMENT_ID_COUNTER: AtomicU64 = AtomicU64::new(1);

pub fn get_next_element_id() -> u64 {
    ELEMENT_ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

#[derive(Debug)]
pub enum SerializedPart {
    InternalWire(u64, u64, u64),
    ExternalInput(u64),
    ExternalOutput(u64),
    And(u64),
    Or(u64),
    Xor(u64),
    Not(u64)
}

pub trait Element {
    fn get_id(&self) -> u64;
    fn serialize(&self) -> Vec<SerializedPart>;
}