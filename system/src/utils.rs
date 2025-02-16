use std::env::{self, var};

use axum::{extract::FromRequestParts, http::{request::Parts, StatusCode}, response::{IntoResponse, Response}};
use jsonwebtoken::{DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};

pub struct JwtGuard(pub Claims);

impl <S> FromRequestParts<S> for JwtGuard
where 
    S: Send + Sync 
{
    type Rejection = Response;

    async fn from_request_parts(parts: &mut Parts, _state: &S,) -> Result<Self, Self::Rejection> {
        let cookie_header = parts.headers.get("cookie").ok_or_else(
            || (StatusCode::UNAUTHORIZED, "No cookie found").into_response()
        )?;

        let cookies = cookie_header.to_str().map(|header|{
            header.split(";").collect::<Vec<&str>>()
        }).ok().ok_or_else(
            || (StatusCode::UNAUTHORIZED, "Invalid cookie").into_response()
        )?;

        let auth_token = cookies.iter().find(|cookie| cookie.contains("auth")).map(|cookie|{
            let cookie_parts = cookie.split("=").collect::<Vec<&str>>();
            cookie_parts[1]
        }).ok_or_else(
            || (StatusCode::UNAUTHORIZED, "No auth cookie found").into_response()
        )?;

        let claims = verify_jwt(auth_token).ok_or_else(||{
            return (StatusCode::UNAUTHORIZED, "Invalid token".to_string())
                .into_response()
        })?;
        
        Ok(JwtGuard(claims))
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub id: String,
    pub tel_contact: String,
    pub verified: bool,
    pub exp: usize,
}

pub fn verify_jwt(token:&str)->Option<Claims>{
    let secret = var("AUTH_KEY").unwrap();
    let mut validation = Validation::default();
    validation.validate_exp = true;
    validation.leeway = 60;

    let claims = jsonwebtoken::decode::<Claims>(token, &DecodingKey::from_secret(secret.as_bytes()), &validation);
    match claims {
        Ok(value) => return Some(value.claims),
        Err(_) => return None,
    }
}

pub fn assign_jwt(claims: Claims)-> String {
    let secret = env::var("AUTH_KEY").unwrap();
    jsonwebtoken::encode(&Header::default(), &claims, &EncodingKey::from_secret(secret.as_bytes())).unwrap()
}