use crate::base::wire::Wire;
use crate::base::element_trait::{Element, SerializedPart, get_next_element_id};

pub struct IOCollectionElement {
    pub id: u64,
    inputs: Vec<Wire>,
    outputs: Vec<Wire>,
}

impl IOCollectionElement {
    pub fn new(inputs: Vec<Wire>, outputs: Vec<Wire>) -> Self {
        Self {
            id: get_next_element_id(),
            inputs,
            outputs,
        }
    }
}

impl Element for IOCollectionElement {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let mut res = Vec::new();
        for item in &self.inputs {
            res.push(SerializedPart::ExternalInput(item.id));
        }
        for item in &self.outputs {
            res.push(SerializedPart::ExternalOutput(item.id));
        }
        res
    }
}
