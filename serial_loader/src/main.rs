pub mod assembler;

use crate::assembler::{Address, add, mov, put, halt};
use serialport::SerialPort;
use std::io::{Read, Write};
use std::time::Duration;

fn write(port: &mut Box<dyn SerialPort>, address: u32, byte: u8) {
    let addressbytes = address.to_be_bytes();

    port.write_all(&[0xFE]).expect("Failed to write to port");

    let mut byte_buf: [u8; 1] = [0x00; 1];

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[0xFB]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[addressbytes[0]])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[addressbytes[1]])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[addressbytes[2]])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[addressbytes[3]])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[byte]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[0x00]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:x?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );
}

fn read(port: &mut Box<dyn SerialPort>, address: u32, how_many: u8) {
    let addressbytes = address.to_be_bytes();

    port.write_all(&[0xFE]).expect("Failed to write to port");

    let mut byte_buf: [u8; 1] = [0x00; 1];

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[0xFA]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[addressbytes[0]])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[addressbytes[1]])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[addressbytes[2]])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[addressbytes[3]])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[how_many])
        .expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );
    port.write_all(&[0x00]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[0x00]).expect("Failed to write to port");

    for _ in 0..how_many {
        port.read_exact(&mut byte_buf)
            .expect("Failed to read from port");
        println!("{:x?}, ", byte_buf);

        port.write_all(&[0x00]).expect("Failed to write to port");
    }
}


fn run(port: &mut Box<dyn SerialPort>) {
    port.write_all(&[0xFE]).expect("Failed to write to port");

    let mut byte_buf: [u8; 1] = [0x00; 1];

    port.read_exact(&mut byte_buf)
        .expect("Failed to read from port");
    println!(
        "Read following: {:?} {}",
        byte_buf,
        String::from_utf8_lossy(&byte_buf)
    );

    port.write_all(&[0xF0]).expect("Failed to write to port");
}


fn readport(port: &mut Box<dyn SerialPort>) {
    loop {
        let mut byte_buf: [u8; 1] = [0x00; 1];
        let res = port.read_exact(&mut byte_buf);
        match res {
            Ok(_) => println!("{:x?}, ", byte_buf),
            Err(_) => {}
        }
        std::thread::sleep(std::time::Duration::from_millis(100));
    }
}

fn main() {
    let mut program: Vec<u8> = Vec::new();
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    put(&mut program, Address::Direct(0x20000000), 0x66);
    // put(&mut program, Address::Direct(0x00), 0x66);
    // put(&mut program, Address::Direct(0x01), 0x02);
    // mov(&mut program, Address::Direct(0x02), Address::Direct(0x04));
    // add(
    //     &mut program,
    //     Address::Direct(0x01),
    //     Address::Direct(0x02),
    //     Address::Direct(0x03),
    // );
    // mov(&mut program, Address::Direct(0x00000000), Address::Direct(0x20000000));
    // mov(&mut program, Address::Direct(0x00000001), Address::Direct(0x20000000));
    // mov(&mut program, Address::Direct(0x00000002), Address::Direct(0x20000000));
    // mov(&mut program, Address::Direct(0x00000003), Address::Direct(0x20000000));
    halt(&mut program);

    let ports = serialport::available_ports().expect("No ports found!");
    for p in ports {
        println!("{}", p.port_name);
    }

    let mut port = serialport::new("COM6", 9600)
        .timeout(Duration::from_millis(100))
        .open()
        .expect("Failed to open port");

    for (bi, byte) in program.iter().enumerate() {
        write(&mut port, bi as u32, *byte);
    }
    std::thread::sleep(std::time::Duration::from_millis(100));

    println!("{:x?}, ", program);
    read(&mut port, 0x00, program.len() as u8);

    let res = port.read_to_end(&mut vec![]);

    std::thread::sleep(std::time::Duration::from_millis(100));
    println!("Running");
    run(&mut port);

    std::thread::sleep(std::time::Duration::from_millis(100));
    println!("readback");
    readport(&mut port);
}
