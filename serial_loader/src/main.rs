use std::io::{Read, Write};
use std::time::Duration;
use serialport::SerialPort;

fn write(port: &mut Box<dyn SerialPort>, address:u32, byte: u8) {

    let addressbytes = address.to_be_bytes();

    port.write_all(&[0xFE ]).expect("Failed to write to port");

    let mut byte_buf: [u8;1] = [0x00; 1];

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[0xFB]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));


    port.write_all(&[addressbytes[0]]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[addressbytes[1]]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[addressbytes[2]]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[addressbytes[3]]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[byte]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[0x00]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:x?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));
}

fn read(port: &mut Box<dyn SerialPort>, address:u32, how_many: u8) {

    let addressbytes = address.to_be_bytes();

    port.write_all(&[0xFE]).expect("Failed to write to port");

    let mut byte_buf: [u8;1] = [0x00; 1];

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[0xFA]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[addressbytes[0]]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[addressbytes[1]]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[addressbytes[2]]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[addressbytes[3]]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[how_many]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));
    port.write_all(&[0x00]).expect("Failed to write to port");

    port.read_exact(&mut byte_buf).expect("Failed to read from port");
    println!("Read following: {:?} {}",byte_buf,  String::from_utf8_lossy(&byte_buf));

    port.write_all(&[0x00]).expect("Failed to write to port");

    for _ in 0..how_many {

        port.read_exact(&mut byte_buf).expect("Failed to read from port");
        println!("{:x?}, ",byte_buf);

        port.write_all(&[0x00]).expect("Failed to write to port");
    }
}

fn main() {
    let ports = serialport::available_ports().expect("No ports found!");
    for p in ports {
        println!("{}", p.port_name);
    }

    let mut port = serialport::new("COM6", 9600)
        .timeout(Duration::from_millis(100))
        .open()
        .expect("Failed to open port");

    write(&mut port, 0x00, 0x12);
    write(&mut port, 0x01, 0x22);
    write(&mut port, 0x02, 0x32);
    write(&mut port, 0x03, 0x42);

    read(&mut port, 0x00, 0x04);
}
