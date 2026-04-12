use crate::base::element_trait::{Element, SerializedPart, get_next_element_id};
use crate::base::wire::Wire;
use crate::elements::full_adder_element::FullAdderElement;
use crate::elements::gate_element::GateElement;
use crate::elements::half_adder_element::HalfAdderElement;

const U8_ADDER_BITWIDTH: usize = 64;

pub struct AdderU64Element {
    pub id: u64,

    in_a: [Wire; U8_ADDER_BITWIDTH],
    in_b: [Wire; U8_ADDER_BITWIDTH],
    zero_wire: Wire,

    out_res: [Wire; U8_ADDER_BITWIDTH],
    out_carry: Wire,

    full_adders: Vec<FullAdderElement>,
}

impl AdderU64Element {
    pub fn new(in_a: [Wire; U8_ADDER_BITWIDTH], in_b: [Wire; U8_ADDER_BITWIDTH]) -> Self {
        let mut full_adders = Vec::new();
        let zero_wire = Wire::static_zero();
        (0..U8_ADDER_BITWIDTH).for_each(|bi| {
            let is_first = bi == 0;
            let is_last = bi == U8_ADDER_BITWIDTH - 1;
            if is_first {
                let new = FullAdderElement::new(in_a[bi], in_b[bi], zero_wire);
                full_adders.push(new);
            } else if is_last {
                let previous: &FullAdderElement = full_adders.last().unwrap();
                let new = FullAdderElement::new(in_a[bi], in_b[bi], *previous.get_carry());
                full_adders.push(new);
            } else {
                // middle
                let previous: &FullAdderElement = full_adders.last().unwrap();
                let new = FullAdderElement::new(in_a[bi], in_b[bi], *previous.get_carry());
                full_adders.push(new);
            }
        });
        let last_adder: &FullAdderElement = full_adders.last().unwrap();
        Self {
            id: get_next_element_id(),
            in_a,
            in_b,
            out_res: full_adders
                .iter()
                .map(|x| *x.get_res())
                .collect::<Vec<_>>()
                .try_into()
                .unwrap(),
            out_carry: *last_adder.get_carry(),
            full_adders,
            zero_wire
        }
    }

    pub fn get_res(&self) -> &[Wire; U8_ADDER_BITWIDTH] {
        &self.out_res
    }

    pub fn get_carry(&self) -> &Wire {
        &self.out_carry
    }
}

impl Element for AdderU64Element {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let mut res = Vec::new();

        res.push(SerializedPart::ExternalInput(self.zero_wire.id));
        for adder in &self.full_adders {
            res.extend(adder.serialize());
        }

        res
    }
}
