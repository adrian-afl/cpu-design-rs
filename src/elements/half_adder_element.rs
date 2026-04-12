use crate::base::wire::Wire;
use crate::base::element_trait::{get_next_element_id, Element, SerializedPart};

pub struct HalfAdderElement {
    pub id: u64,

    in_a: Wire,
    in_b: Wire,

    out_res: Wire,
    out_carry: Wire,
}

impl HalfAdderElement {
    pub fn new(in_a: Wire, in_b: Wire) -> Self {
        Self {
            id: get_next_element_id(),
            in_a,
            in_b,
            out_res: Wire::internal(),
            out_carry: Wire::internal(),
        }
    }

    pub fn get_res(&self) -> &Wire {
        &self.out_res
    }

    pub fn get_carry(&self) -> &Wire {
        &self.out_carry
    }
}

impl Element for HalfAdderElement {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let and_id = get_next_element_id();
        let xor_id = get_next_element_id();

        let and = SerializedPart::And(and_id);
        let xor = SerializedPart::Xor(xor_id);

        let mut res = Vec::new();
        res.push(SerializedPart::InternalWire(get_next_element_id(), self.in_a.id, xor_id));
        res.push(SerializedPart::InternalWire(get_next_element_id(), self.in_b.id, xor_id));

        res.push(SerializedPart::InternalWire(get_next_element_id(), self.in_a.id, and_id));
        res.push(SerializedPart::InternalWire(get_next_element_id(), self.in_b.id, and_id));

        res.push(and);
        res.push(xor);

        res.push(SerializedPart::InternalWire(self.out_res.id, xor_id, self.out_res.id));
        res.push(SerializedPart::InternalWire(self.out_carry.id, and_id, self.out_carry.id));

        res
    }
}
