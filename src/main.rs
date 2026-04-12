use std::sync::RwLock;
use crate::base::connection_element::ConnectionElement;
use crate::base::io_collection_element::IOCollectionElement;
use crate::base::schema::{Schema, flatten_schema, print_flat_schema, run_flat_schema};
use crate::base::wire::Wire;
use crate::elements::adder_u64_element::AdderU64Element;
use crate::elements::adder_u8_element::AdderU8Element;
use crate::elements::full_adder_element::FullAdderElement;
use crate::elements::half_adder_element::HalfAdderElement;

pub mod base;
pub mod elements;
pub mod gates;

fn u8_to_bits(v: u8) -> Vec<bool> {
    let mut res = Vec::new();
    for i in 0..8 {
        res.push(v & (1 << i) != 0);
    }

    res
}

fn bits_to_u8(bits: &[bool]) -> u8 {
    let mut res: u8 = 0;
    for i in 0..bits.len() {
        if bits[i] { res |= 0x1 << i; }
    }

    res
}

fn u64_to_bits(v: u64) -> Vec<bool> {
    let mut res = Vec::new();
    for i in 0..64 {
        res.push(v & (1 << i) != 0);
    }

    res
}

fn bits_to_u64(bits: &[bool]) -> u64 {
    let mut res: u64 = 0;
    for i in 0..bits.len() {
        if bits[i] { res |= 0x1 << i; }
    }

    res
}

fn main() {
    let mut schema = Schema::new();

    let a = Wire::input();
    let b = Wire::input();
    let c = Wire::input();

    let o_s = Wire::output();
    let o_c = Wire::output();

    let full_adder = FullAdderElement::new(a, b, c);
    let output_s_connection = ConnectionElement::new(*full_adder.get_res(), o_s);
    let output_c_connection = ConnectionElement::new(*full_adder.get_carry(), o_c);

    let mut binary_in_a = Vec::new();
    let mut binary_in_b = Vec::new();
    for bi in 0..64 {
        binary_in_a.push(Wire::input());
        binary_in_b.push(Wire::input());
    }
    // let binary_out = [Wire::output(); 8];

    let io_collection = IOCollectionElement::new(vec![a, b, c], vec![o_s, o_c]);
    let io_collection_8bit_a = IOCollectionElement::new(binary_in_a.to_vec(), vec![]);
    let io_collection_8bit_b = IOCollectionElement::new(binary_in_b.to_vec(), vec![]);

    let adder8 = AdderU64Element::new(binary_in_a.clone().try_into().unwrap(), binary_in_b.clone().try_into().unwrap());
    let adder8out = adder8.get_res().clone();

    // schema.elements.push(Box::new(io_collection));
    schema.elements.push(Box::new(io_collection_8bit_a));
    schema.elements.push(Box::new(io_collection_8bit_b));
    // schema.elements.push(Box::new(full_adder));
    schema.elements.push(Box::new(adder8));
    // schema.elements.push(Box::new(output_s_connection));
    // schema.elements.push(Box::new(output_c_connection));

    let serialized = schema.serialize();

    // println!("{:#?}", serialized);

    let (flat, wires_map) = flatten_schema(&serialized);

    // print_flat_schema(&flat);

    let mut init_state = (0..flat.len()).map(|_| false).collect::<Vec<_>>();

    let in_num_a = 289374928374;
    let in_num_b = 4554765673212;
    let expected_out = in_num_a + in_num_b;

    for (bi, v) in u64_to_bits(in_num_a).iter().enumerate() {
        // println!("Setting A bit {} at {} to {}", bi, wires_map[&binary_in_a[bi].id], *v);
        init_state[wires_map[&binary_in_a[bi].id]] = *v;
    }

    for (bi, v) in u64_to_bits(in_num_b).iter().enumerate() {
        // println!("Setting B bit {} at {} to {}", bi, wires_map[&binary_in_b[bi].id], *v);
        init_state[wires_map[&binary_in_b[bi].id]] = *v;
    }

    for (i, item) in init_state.iter().enumerate() {
        // println!("{}:\t{}\t{}", i, item, flat[i]);
    }
    let final_state = run_flat_schema(&flat, &init_state, 1);

    for (i, item) in final_state.iter().enumerate() {
        // println!("{}:\t{}\t{}", i, item, flat[i]);
    }

    let readout = |wire: Wire| -> bool { final_state[wires_map[&wire.id]] };

    let readout_arr = |wires: &[Wire]| -> Vec<bool> {
        wires
            .iter()
            .map(|wire| final_state[wires_map[&wire.id]])
            .collect()
    };

    let final_sum = readout_arr(&adder8out);
    let final_u8 = bits_to_u64(final_sum.as_slice());

    // println!("final_sum {:#?}", final_sum);
    println!("final_decoded {:#?}", final_u8);
    println!("expected {:#?}", expected_out);
}
