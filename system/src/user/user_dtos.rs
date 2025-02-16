use serde::{Deserialize, Serialize};
use validator::Validate;

#[derive(Debug, Serialize, Deserialize, Validate)]
pub struct LoginDto {
    #[validate(length(min = 3, max=16))]
    pub tel_contact: String,

    #[validate(length(min = 4, max=16))]
    pub password: String,
}

#[derive(Debug, Serialize, Deserialize, Validate)]
pub struct SignupDto {
    #[validate(length(min = 3, max=16))]
    pub tel_contact: String,

    #[validate(length(min = 4, max=16))]
    pub password: String,
}