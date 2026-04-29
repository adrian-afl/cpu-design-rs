use crate::base::element_trait::{get_next_element_id, Element, SerializedPart};

#[derive(Clone, Copy, Debug)]
pub enum WireType {
    ExternalInput,
    ExternalOutput,
    Internal,
    StaticZero,
    StaticOne
}

#[derive(Clone, Copy, Debug)]
pub struct Wire {
    pub id: u64,
    pub typ: WireType,
}

impl Wire {
    pub fn new(typ: WireType) -> Self {
        Self {
            id: get_next_element_id(),
            typ
        }
    }

    pub fn internal() -> Self {
        Self {
            id: get_next_element_id(),
            typ: WireType::Internal
        }
    }

    pub fn input() -> Self {
        Self {
            id: get_next_element_id(),
            typ: WireType::ExternalInput
        }
    }

    pub fn output() -> Self {
        Self {
            id: get_next_element_id(),
            typ: WireType::ExternalOutput
        }
    }

    pub fn static_zero() -> Self {
        Self {
            id: get_next_element_id(),
            typ: WireType::StaticZero
        }
    }

    pub fn static_one() -> Self {
        Self {
            id: get_next_element_id(),
            typ: WireType::StaticOne
        }
    }

    pub fn regen_id(&mut self){
        self.id = get_next_element_id();
    }
}