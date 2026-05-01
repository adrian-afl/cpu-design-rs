use std::io::Write;

const INSTR_HALT: u8 = 0x00;

const INSTR_MOV: u8 = 0x10;
const INSTR_PUT: u8 = 0x11;

const INSTR_ADD: u8 = 0x20;
const INSTR_SUB: u8 = 0x21;
const INSTR_MUL: u8 = 0x22;
const INSTR_DIV: u8 = 0x23;

const INSTR_JEQ: u8 = 0x30;
const INSTR_JNEQ: u8 = 0x31;
const INSTR_JGT: u8 = 0x32;
const INSTR_JGTE: u8 = 0x33;
const INSTR_JLT: u8 = 0x34;
const INSTR_JLTE: u8 = 0x35;
const INSTR_JZERO: u8 = 0x36;
const INSTR_JNZERO: u8 = 0x37;
const INSTR_RET: u8 = 0x38;

#[derive(Debug, Clone, Copy)]
pub enum Address {
    Direct(u32),
    Pointer(u32),
}

impl Address {
    pub fn value(&self) -> u32 {
        match self {
            Address::Direct(v) => *v,
            Address::Pointer(v) => *v,
        }
    }
}

fn write_u32(stream: &mut dyn Write, value: u32) {
    stream
        .write_all(&value.to_be_bytes())
        .expect("Stream write failed");
}

fn write_u8(stream: &mut dyn Write, value: u8) {
    stream
        .write_all(&value.to_be_bytes())
        .expect("Stream write failed");
}

pub fn put(stream: &mut dyn Write, address: Address, value: u8) {
    let addressing = match address {
        Address::Direct(_) => 0b00_00_00_00_u8,
        Address::Pointer(_) => 0b00_00_00_01_u8,
    };

    stream
        .write_all(&INSTR_PUT.to_be_bytes())
        .expect("Opcode write failed");
    stream
        .write_all(&addressing.to_be_bytes())
        .expect("Addressing write failed");
    stream
        .write_all(&address.value().to_be_bytes())
        .expect("Address write failed");
    stream
        .write_all(&value.to_be_bytes())
        .expect("Value write failed");
}

pub fn mov(stream: &mut dyn Write, from: Address, to: Address) {
    let addressing = match to {
        Address::Direct(_) => 0b00_00_00_00_u8,
        Address::Pointer(_) => 0b00_00_01_00_u8,
    };

    stream
        .write_all(&INSTR_MOV.to_be_bytes())
        .expect("Opcode write failed");
    stream
        .write_all(&addressing.to_be_bytes())
        .expect("Addressing write failed");
    stream
        .write_all(&from.value().to_be_bytes())
        .expect("Address write failed");
    stream
        .write_all(&to.value().to_be_bytes())
        .expect("Address write failed");
}

pub fn add(stream: &mut dyn Write, a: Address, b: Address, to: Address) {
    let addressing = match to {
        Address::Direct(_) => 0b00_00_00_00_u8,
        Address::Pointer(_) => 0b00_01_00_00_u8,
    };

    stream
        .write_all(&INSTR_ADD.to_be_bytes())
        .expect("Opcode write failed");
    stream
        .write_all(&addressing.to_be_bytes())
        .expect("Addressing write failed");
    stream
        .write_all(&a.value().to_be_bytes())
        .expect("Address write failed");
    stream
        .write_all(&b.value().to_be_bytes())
        .expect("Address write failed");
    stream
        .write_all(&to.value().to_be_bytes())
        .expect("Address write failed");
}

pub fn halt(stream: &mut dyn Write) {
    stream
        .write_all(&INSTR_HALT.to_be_bytes())
        .expect("Opcode write failed");
}
