use crate::base::wire::{Wire, WireType};
use crate::base::element_trait::{Element, SerializedPart, get_next_element_id};

pub struct ConnectionElement {
    pub id: u64,
    input: Wire,
    output: Wire,
}

impl ConnectionElement {
    pub fn new(input: Wire, output: Wire) -> Self {
        Self {
            id: get_next_element_id(),
            input,
            output,
        }
    }
}

impl Element for ConnectionElement {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let mut res = Vec::new();
        res.push(SerializedPart::InternalWire(get_next_element_id(), self.input.id, self.output.id));
        res
    }
}
