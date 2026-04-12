use crate::base::wire::Wire;
use crate::base::element_trait::{Element, SerializedPart, get_next_element_id};
use crate::elements::gate_element::GateElement;
use crate::elements::half_adder_element::HalfAdderElement;

pub struct FullAdderElement {
    pub id: u64,

    in_a: Wire,
    in_b: Wire,
    in_c: Wire,

    out_res: Wire,
    out_carry: Wire,

    half_adder_primary: HalfAdderElement,
    half_adder_secondary: HalfAdderElement,
    or_gate_finalizer: GateElement,
}

impl FullAdderElement {
    pub fn new(in_a: Wire, in_b: Wire, in_c: Wire) -> Self {
        let half_adder_primary = HalfAdderElement::new(in_a, in_b);
        let half_adder_secondary = HalfAdderElement::new(in_c, *half_adder_primary.get_res());
        let or_gate_finalizer = GateElement::or(vec![*half_adder_secondary.get_carry(), *half_adder_primary.get_carry()]);
        Self {
            id: get_next_element_id(),
            in_a,
            in_b,
            in_c,
            out_res: *half_adder_secondary.get_res(),
            out_carry: *or_gate_finalizer.get_out(),
            half_adder_primary,
            half_adder_secondary,
            or_gate_finalizer
        }
    }

    pub fn get_res(&self) -> &Wire {
        &self.out_res
    }

    pub fn get_carry(&self) -> &Wire {
        &self.out_carry
    }
}

impl Element for FullAdderElement {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let mut res = Vec::new();

        res.extend(self.half_adder_primary.serialize());
        res.extend(self.half_adder_secondary.serialize());
        res.extend(self.or_gate_finalizer.serialize());

        res
    }
}
