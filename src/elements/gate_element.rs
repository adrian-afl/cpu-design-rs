use crate::base::wire::Wire;
use crate::base::element_trait::{Element, SerializedPart, get_next_element_id};

pub enum GateType {
    And,
    Or,
    Xor,
    Not,
}

pub struct GateElement {
    pub id: u64,
    gate: GateType,
    ins: Vec<Wire>,
    out: Wire,
}

impl GateElement {
    pub fn and(ins: Vec<Wire>) -> Self {
        Self {
            id: get_next_element_id(),
            ins,
            out: Wire::internal(),
            gate: GateType::And,
        }
    }

    pub fn or(ins: Vec<Wire>) -> Self {
        Self {
            id: get_next_element_id(),
            ins,
            out: Wire::internal(),
            gate: GateType::Or,
        }
    }
    pub fn xor(ins: Vec<Wire>) -> Self {
        Self {
            id: get_next_element_id(),
            ins,
            out: Wire::internal(),
            gate: GateType::And,
        }
    }

    pub fn not(ins: Wire) -> Self {
        Self {
            id: get_next_element_id(),
            ins: vec![ins],
            out: Wire::internal(),
            gate: GateType::Not,
        }
    }

    pub fn get_out(&self) -> &Wire {
        &self.out
    }
}

impl Element for GateElement {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let and_id = get_next_element_id();
        let and = match self.gate {
            GateType::And => SerializedPart::And(and_id),
            GateType::Or => SerializedPart::Or(and_id),
            GateType::Xor => SerializedPart::Xor(and_id),
            GateType::Not => SerializedPart::Not(and_id),
        };
        let mut res = Vec::new();
        for i in &self.ins {
            res.push(SerializedPart::InternalWire(get_next_element_id(), i.id, and_id));
        }
        res.push(and);
        res.push(SerializedPart::InternalWire(self.out.id, and_id, self.out.id));

        res
    }
}
