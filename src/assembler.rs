#[derive(Debug, Clone, Copy)]
pub enum Address {
    Direct(u32),
    Pointer(u32),
}

impl Address {
    pub fn value(&self) -> u32 {
        match self {
            Address::Direct(v) => *v,
            Address::Pointer(v) => *v
        }
    }
}

pub fn write_u32(pc: &mut u32, value: u32) {
    let value_string = format!("{:08X}", value);

    let part1 = &value_string[0..2];
    let part2 = &value_string[2..4];
    let part3 = &value_string[4..6];
    let part4 = &value_string[6..8];

    println!("
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = 8'h{part1};
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    println!("
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = 8'h{part2};
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    println!("
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = 8'h{part3};
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    println!("
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = 8'h{part4};
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;
}

pub fn put(pc: &mut u32, address: Address, value: u8) {
    let addressing = match address {
        Address::Direct(_) => "8'b00_00_00",
        Address::Pointer(_) => "8'b00_00_01",
    };

    println!(
        "
    // opcode
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = `INSTR_PUT;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    println!(
        "
    // addressing
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = {addressing};
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    write_u32(pc, address.value());

    println!(
        "
    // 8 bit value

    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = 8'd{value};
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;
}

pub fn mov(pc: &mut u32, from: Address, to: Address) {
    let addressing = match to {
        Address::Direct(_) => "8'b00_00_00",
        Address::Pointer(_) => "8'b00_01_00",
    };

    println!(
        "
    // opcode
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = `INSTR_MOV;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    println!(
        "
    // addressing
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = {addressing};
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    write_u32(pc, from.value());
    write_u32(pc, to.value());
}

pub fn add(pc: &mut u32, a: Address, b: Address, to: Address) {
    let addressing = match to {
        Address::Direct(_) => "8'b00_00_00",
        Address::Pointer(_) => "8'b01_00_00",
    };

    println!(
        "
    // opcode
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = `INSTR_ADD;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    println!(
        "
    // addressing
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = {addressing};
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

    write_u32(pc, a.value());
    write_u32(pc, b.value());
    write_u32(pc, to.value());
}


pub fn halt(pc: &mut u32) {
    println!(
        "
    // opcode
    #5 ext_addr = 32'd{pc};
    #5 ext_wdata = `INSTR_HALT;
    #5 ext_wr_en = 1;
    #5 clk = 1;
    #5 clk = 0;
    #5 ext_wr_en = 0;"
    );

    *pc += 1;

}
