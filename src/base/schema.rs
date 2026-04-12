use rayon::iter::IndexedParallelIterator;
use crate::base::element_trait::{Element, SerializedPart};
use crate::gates::and_gate::and_gate;
use crate::gates::not_gate::not_gate;
use crate::gates::or_gate::or_gate;
use crate::gates::xor_gate::xor_gate;
use std::collections::HashMap;
use std::fmt::{Display, Formatter, Write};
use rayon::prelude::{IntoParallelRefIterator, ParallelIterator};

pub struct Schema {
    pub elements: Vec<Box<dyn Element>>,
}

impl Schema {
    pub fn new() -> Self {
        Self {
            elements: Vec::new(),
        }
    }

    pub fn serialize(&self) -> Vec<SerializedPart> {
        self.elements.iter().flat_map(|e| e.serialize()).collect()
    }
}

#[derive(Clone, Copy, Debug)]
pub enum FlatSchema {
    Input,
    Output,
    Wire(usize, usize),
    PullUp,
    PullDown,
    And,
    Or,
    Xor,
    Not,
}

impl Display for FlatSchema {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            FlatSchema::Wire(from, to) => f.write_fmt(format_args!("{from} -> {to}")),
            FlatSchema::Input => f.write_str("IN"),
            FlatSchema::Output => f.write_str("OUT"),
            FlatSchema::PullUp => f.write_str("ONE"),
            FlatSchema::PullDown => f.write_str("ZERO"),
            FlatSchema::And => f.write_str("AND"),
            FlatSchema::Or => f.write_str("OR"),
            FlatSchema::Xor => f.write_str("XOR"),
            FlatSchema::Not => f.write_str("NOT"),
        }
    }
}

fn find_id_offset(search_id: u64, input: &Vec<SerializedPart>) -> usize {
    input
        .iter()
        .position(|x| match x {
            SerializedPart::InternalWire(id, _, _) => *id == search_id,
            SerializedPart::ExternalInput(id) => *id == search_id,
            SerializedPart::ExternalOutput(id) => *id == search_id,
            SerializedPart::PullUp(id) => *id == search_id,
            SerializedPart::PullDown(id) => *id == search_id,
            SerializedPart::And(id) => *id == search_id,
            SerializedPart::Or(id) => *id == search_id,
            SerializedPart::Xor(id) => *id == search_id,
            SerializedPart::Not(id) => *id == search_id,
        })
        .expect(&format!("failed to find offset for id {search_id}"))
}

pub fn flatten_schema(input: &Vec<SerializedPart>) -> (Vec<FlatSchema>, HashMap<u64, usize>) {
    let mut res = Vec::new();
    let mut wire_id_map = HashMap::new();

    for item in input {
        match item {
            SerializedPart::InternalWire(wire_id, id_in, id_out) => {
                let new_a = find_id_offset(*id_in, input);
                let new_b = find_id_offset(*id_out, input);
                wire_id_map.insert(*wire_id, res.len());
                res.push(FlatSchema::Wire(new_a, new_b));
            }
            SerializedPart::ExternalInput(wire_id) => {
                wire_id_map.insert(*wire_id, res.len());
                res.push(FlatSchema::Input)
            }
            SerializedPart::ExternalOutput(wire_id) => {
                wire_id_map.insert(*wire_id, res.len());
                res.push(FlatSchema::Output)
            }
            SerializedPart::PullUp(wire_id) => {
                wire_id_map.insert(*wire_id, res.len());
                res.push(FlatSchema::Input)
            }
            SerializedPart::PullDown(wire_id) => {
                wire_id_map.insert(*wire_id, res.len());
                res.push(FlatSchema::Output)
            }
            SerializedPart::And(_) => res.push(FlatSchema::And),
            SerializedPart::Or(_) => res.push(FlatSchema::Or),
            SerializedPart::Xor(_) => res.push(FlatSchema::Xor),
            SerializedPart::Not(_) => res.push(FlatSchema::Not),
        }
    }

    (res, wire_id_map)
}

pub fn print_flat_schema(flat: &Vec<FlatSchema>) {
    for (i, item) in flat.iter().enumerate() {
        println!("{}:\t{}", i, item);
    }
}

pub fn run_flat_schema(flat: &[FlatSchema], in_state: &[bool], iterations: usize) -> Vec<bool> {
    let mut state = in_state.to_vec();

    for _ in 0..iterations {
        state = flat.par_iter().enumerate().map(|(i, item)| {
            let inputs = flat
                .iter()
                .enumerate()
                .filter_map(|(si, sitem)| {
                    if let FlatSchema::Wire(_from, to) = sitem
                        && *to == i
                    {
                        Some(state[si])
                    } else {
                        None
                    }
                })
                .collect::<Vec<bool>>();
            match item {
                FlatSchema::Input =>  state[i],
                FlatSchema::Output =>  inputs[0],
                FlatSchema::Wire(from, _) =>
                     state[*from],

                FlatSchema::PullUp => true,
                FlatSchema::PullDown =>  false,
                FlatSchema::And =>  and_gate(&inputs),
                FlatSchema::Or =>  or_gate(&inputs),
                FlatSchema::Xor =>  xor_gate(&inputs),
                FlatSchema::Not =>  not_gate(inputs[0]),
            }
        }).collect();
    }

    state
}
