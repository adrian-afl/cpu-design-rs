use crate::base::wire::{Wire, WireType};
use crate::base::element_trait::{Element, SerializedPart, get_next_element_id};

// used to "advertise" the wires because otherwise the inputs have nothing at all that would serialize them
// all outputs should auto serialize tho as the flow should go this way
// so there is need for inputs to be "initialized" and this here does that
// it can also advertise outputs if those are indirect or whatever so its called IO
// also supports pull downs and pull ups if needed
// BUT DOESNT SUPPORT internal wires as the connecting ids cannot be known yet
// to advertise connections between stuff use ConnectionElement
pub struct IOCollectionElement {
    pub id: u64,
    wires: Vec<Wire>,
}

impl IOCollectionElement {
    pub fn new(wires: &[Wire]) -> Self {
        Self {
            id: get_next_element_id(),
            wires: wires.to_vec(),
        }
    }
}

impl Element for IOCollectionElement {
    fn get_id(&self) -> u64 {
        self.id
    }

    fn serialize(&self) -> Vec<SerializedPart> {
        let mut res = Vec::new();
        for item in &self.wires {
            match item.typ {
                WireType::ExternalInput => res.push(SerializedPart::ExternalInput(item.id)),
                WireType::ExternalOutput => res.push(SerializedPart::ExternalOutput(item.id)),
                WireType::Internal => (),
                WireType::StaticZero => res.push(SerializedPart::PullDown(item.id)),
                WireType::StaticOne => res.push(SerializedPart::PullUp(item.id))
            }
        }
        res
    }
}
