use crate::base::element_trait::{Element, SerializedPart, get_next_element_id};
use crate::base::wire::{Wire, WireType};

pub struct SRLatchElement {
    pub id: u64,
    in_set: Wire,
    in_reset: Wire,
    out: Wire,
    out_inverted: Wire,
}

impl SRLatchElement {
    pub fn new(in_set: Wire, in_reset: Wire) -> Self {
        Self {
            id: get_next_element_id(),
            in_set,
            in_reset,
            out: Wire::internal(),
            out_inverted: Wire::internal(),
        }
    }


    pub fn get_out(&self) -> &Wire {
        &self.out
    }

    pub fn get_out_inverted(&self) -> &Wire {
        &self.out_inverted
    }
}

impl Element for SRLatchElement {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let or_1_id = get_next_element_id();
        let or_2_id = get_next_element_id();
        let not_1_id = get_next_element_id();
        let not_2_id = get_next_element_id();

        let or_1 = SerializedPart::Or(or_1_id);
        let or_2 = SerializedPart::Or(or_2_id);
        let not_1 = SerializedPart::Not(not_1_id);
        let not_2 = SerializedPart::Not(not_2_id);

        let mut res = Vec::new();

        // inputs to ors
        res.push(SerializedPart::InternalWire(
            get_next_element_id(),
            self.in_set.id,
            or_2_id,
        ));
        res.push(SerializedPart::InternalWire(
            get_next_element_id(),
            self.in_reset.id,
            or_1_id,
        ));
        res.push(or_1);
        res.push(or_2);

        // negate ors
        res.push(SerializedPart::InternalWire(
            get_next_element_id(),
            or_1_id,
            not_1_id,
        ));
        res.push(SerializedPart::InternalWire(
            get_next_element_id(),
            or_2_id,
            not_2_id,
        ));
        res.push(not_1);
        res.push(not_2);

        // ors interconnect
        res.push(SerializedPart::InternalWire(
            get_next_element_id(),
            not_2_id,
            or_1_id,
        ));

        res.push(SerializedPart::InternalWire(
            get_next_element_id(),
            not_1_id,
            or_2_id,
        ));

        // outputs
        res.push(SerializedPart::InternalWire(
            get_next_element_id(),
            not_1_id,
            self.out.id,
        ));

        res.push(SerializedPart::InternalWire(
            get_next_element_id(),
            not_2_id,
            self.out_inverted.id,
        ));

        res
    }
}
