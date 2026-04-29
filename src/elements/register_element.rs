use crate::base::element_trait::{get_next_element_id, Element, SerializedPart};
use crate::base::wire::Wire;
use crate::elements::gate_element::GateElement;
use crate::elements::sr_latch_element::SRLatchElement;

pub struct RegisterElement<const ADDER_BITWIDTH: usize> {
    pub id: u64,

    out_data: [Wire; ADDER_BITWIDTH],

    latches: Vec<SRLatchElement>,
    ands: Vec<GateElement>,
}

impl<const REGISTER_BITWIDTH: usize> RegisterElement<REGISTER_BITWIDTH> {
    pub fn new(in_data: &[Wire], in_set: Wire, in_reset: Wire) -> Self {
        let mut latches = Vec::new();
        let mut ands = Vec::new();
        (0..REGISTER_BITWIDTH).for_each(|bi| {
            let and = GateElement::and(vec![in_data[bi], in_set]);
            let latch = SRLatchElement::new(*and.get_out(), in_reset);
            ands.push(and);
            latches.push(latch);
        });
        Self {
            id: get_next_element_id(),
            out_data: latches
                .iter()
                .map(|x| *x.get_out())
                .collect::<Vec<_>>()
                .try_into()
                .unwrap(),
            latches,
            ands
        }
    }

    pub fn get_data(&self) -> &[Wire; REGISTER_BITWIDTH] {
        &self.out_data
    }
}

impl<const ADDER_BITWIDTH: usize> Element for RegisterElement<ADDER_BITWIDTH> {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let mut res = Vec::new();

        for latch in &self.latches {
            res.extend(latch.serialize());
        }

        for and in &self.ands {
            res.extend(and.serialize());
        }

        res
    }
}
