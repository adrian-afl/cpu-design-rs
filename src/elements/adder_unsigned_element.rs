use crate::base::element_trait::{Element, SerializedPart, get_next_element_id};
use crate::base::wire::Wire;
use crate::elements::full_adder_element::FullAdderElement;
use crate::elements::gate_element::GateElement;
use crate::elements::half_adder_element::HalfAdderElement;

pub struct AdderUnsignedElement<const ADDER_BITWIDTH: usize> {
    pub id: u64,

    zero_wire: Wire,

    out_res: [Wire; ADDER_BITWIDTH],
    out_carry: Wire,

    full_adders: Vec<FullAdderElement>,
}

impl<const ADDER_BITWIDTH: usize> AdderUnsignedElement<ADDER_BITWIDTH> {
    pub fn new(in_a: &[Wire], in_b: &[Wire]) -> Self {
        let mut full_adders = Vec::new();
        let zero_wire = Wire::static_zero();
        (0..ADDER_BITWIDTH).for_each(|bi| {
            let is_first = bi == 0;
            let is_last = bi == ADDER_BITWIDTH - 1;
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

    pub fn get_res(&self) -> &[Wire; ADDER_BITWIDTH] {
        &self.out_res
    }

    pub fn get_carry(&self) -> &Wire {
        &self.out_carry
    }
}

impl<const ADDER_BITWIDTH: usize> Element for AdderUnsignedElement<ADDER_BITWIDTH> {
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
