use std::fs;
use crate::base::connection_element::ConnectionElement;
use crate::base::io_collection_element::IOCollectionElement;
use crate::base::schema::{RunConfig, Schema, flatten_schema, run_flat_schema, generate_verilog};
use crate::base::wire::Wire;
use crate::elements::adder_unsigned_element::AdderUnsignedElement;
use crate::elements::register_element::RegisterElement;

pub mod base;
pub mod elements;
pub mod gates;

const LOGICAL_ZERO: f32 = 0.0;
const LOGICAL_ONE: f32 = 5.0;
const LOGICAL_THRESHOLD: f32 = 2.5;

fn u8_to_bits(v: u8) -> Vec<f32> {
    let mut res = Vec::new();
    for i in 0..8 {
        res.push(if v & (1 << i) != 0 {
            LOGICAL_ONE
        } else {
            LOGICAL_ZERO
        });
    }

    res
}

fn bits_to_u8(bits: &[f32]) -> u8 {
    let mut res: u8 = 0;
    for i in 0..bits.len() {
        if bits[i] > LOGICAL_THRESHOLD {
            res |= 0x1 << i;
        }
    }

    res
}

fn u64_to_bits(v: u64) -> Vec<f32> {
    let mut res = Vec::new();
    for i in 0..64 {
        res.push(if v & (1 << i) != 0 {
            LOGICAL_ONE
        } else {
            LOGICAL_ZERO
        });
    }

    res
}

fn bits_to_u64(bits: &[f32]) -> u64 {
    let mut res: u64 = 0;
    for i in 0..bits.len() {
        if bits[i] > LOGICAL_THRESHOLD {
            res |= 0x1 << i;
        }
    }

    res
}

fn main() {
    let mut schema = Schema::new();

    let mut binary_in_a = Vec::new();
    let mut binary_in_b = Vec::new();
    let mut binary_output = Vec::new();
    for bi in 0..8 {
        binary_in_a.push(Wire::input());
        binary_in_b.push(Wire::input());
        binary_output.push(Wire::output());
    }
    // let binary_out = [Wire::output(); 8];

    let io_collection_8bit_a = IOCollectionElement::new(&binary_in_a);
    let io_collection_8bit_b = IOCollectionElement::new(&binary_in_b);
    let io_collection_8bit_out = IOCollectionElement::new(&binary_output);

    let adder8 = AdderUnsignedElement::<8>::new(&binary_in_a, &binary_in_b);
    let adder8out = adder8.get_res().clone();

    schema.elements.push(Box::new(io_collection_8bit_a));
    schema.elements.push(Box::new(io_collection_8bit_b));
    schema.elements.push(Box::new(io_collection_8bit_out));
    schema.elements.push(Box::new(adder8));

    let register8 = RegisterElement::<8>::new(&adder8out, Wire::static_one(), Wire::static_zero());
    let register88out = register8.get_data().clone();
    schema.elements.push(Box::new(register8));

    for (index, outbit) in register88out.iter().enumerate() {
        schema.elements.push(Box::new(ConnectionElement::new(*outbit, binary_output[index])));
    }

    let serialized = schema.serialize();

    // println!("{:#?}", serialized);

    let (flat, wires_map) = flatten_schema(&serialized);

    fs::write("verilog.v", generate_verilog(&flat)).expect("failed to save verilog file");

    // print_flat_schema(&flat);

    let mut init_state = (0..flat.len()).map(|_| 0.0).collect::<Vec<_>>();

    let in_num_a = 123;
    let in_num_b = 55;
    let expected_out = in_num_a + in_num_b;

    for (bi, v) in u8_to_bits(in_num_a).iter().enumerate() {
        // println!("Setting A bit {} at {} to {}", bi, wires_map[&binary_in_a[bi].id], *v);
        init_state[wires_map[&binary_in_a[bi].id]] = *v;
    }

    for (bi, v) in u8_to_bits(in_num_b).iter().enumerate() {
        // println!("Setting B bit {} at {} to {}", bi, wires_map[&binary_in_b[bi].id], *v);
        init_state[wires_map[&binary_in_b[bi].id]] = *v;
    }

    for (i, item) in init_state.iter().enumerate() {
        // println!("{}:\t{}\t{}", i, item, flat[i]);
    }

    let run_config = RunConfig {
        iterations: 128,
        logical_zero_volts: LOGICAL_ZERO,
        logical_one_volts: LOGICAL_ONE,
    };

    let final_state = run_flat_schema(&flat, &init_state, &run_config);

    for (i, item) in final_state.iter().enumerate() {
        // println!("{}:\t{}\t{}", i, item, flat[i]);
    }

    let readout = |wire: Wire| -> f32 { final_state[wires_map[&wire.id]] };

    let readout_arr = |wires: &[Wire]| -> Vec<f32> {
        wires
            .iter()
            .map(|wire| final_state[wires_map[&wire.id]])
            .collect()
    };

    let final_sum = readout_arr(&register88out);
    let final_u8 = bits_to_u8(final_sum.as_slice());

    // println!("final_sum {:#?}", final_sum);
    println!("final_decoded {:#?}", final_u8);
    println!("expected {:#?}", expected_out);
    println!("mismatch {:#?}", expected_out as i64 - final_u8 as i64);
}
