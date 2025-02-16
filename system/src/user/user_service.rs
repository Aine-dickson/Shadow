use axum::{http::StatusCode, response::IntoResponse};
use bcrypt::{hash, verify, DEFAULT_COST};
use mongodb::{bson::{doc, oid::ObjectId, DateTime}, Database};
use serde::{Deserialize, Serialize};

use crate::utils::{assign_jwt, Claims};
use super::user_dtos::{LoginDto, SignupDto};

pub async fn signup(user: SignupDto, db: Database)-> Result<(String, UserAccount), impl IntoResponse>{
    let user_collection: mongodb::Collection<UserAccount> = db.collection("users");
    let existing_user = user_collection.find_one(doc! {"primary_contact": user.tel_contact.clone()}).await.unwrap();
    if existing_user.is_some() {
        return Err((StatusCode::CONFLICT, "User already exists"));
    }

    let hash = hash(user.password.clone(), DEFAULT_COST).unwrap();
    let user = UserAccount {
        password: hash,
        id: ObjectId::new(),
        email_address: "".to_string(),
        username: "".to_string(),
        mode: UserMode::Casual,
        bio: "".to_string(),
        verified: false,
        profile_photo: None,
        last_seen: DateTime::now(),
        updated_at: DateTime::now(),
        created_at: DateTime::now(),
        primary_contact: user.tel_contact.clone()
    };

    let claims = Claims{
        id: ObjectId::new().to_string(),
        tel_contact: user.primary_contact.clone(),
        verified: false,
        exp: chrono::Utc::now().timestamp() as usize + (3600*24*30),
    };

    let insert_result = user_collection.insert_one(&user).await;

    if insert_result.is_err(){
        return Err((StatusCode::INTERNAL_SERVER_ERROR, "Failed to create user"));
    }

    let cookie = assign_jwt(claims);

    Ok((cookie, user))
}

pub async fn login(user: LoginDto, db: Database)-> Result<(String, UserAccount), impl IntoResponse>{
    let user_collection: mongodb::Collection<UserAccount> = db.collection("users");
    let existing_user = user_collection.find_one(doc! {"primary_contact": user.tel_contact}).await.unwrap();
    if existing_user.is_none(){
        return Err((StatusCode::UNAUTHORIZED, "No matching user"));
    }

    let hash = hash(user.password, DEFAULT_COST).unwrap();
    let user = existing_user.unwrap();

    if !verify(user.password.clone(), &hash).unwrap() {
        return Err((StatusCode::UNAUTHORIZED, "Invalid password"));
    }

    let claims = Claims{
        id: user.id.to_string(),
        tel_contact: user.primary_contact.clone(),
        verified: user.verified,
        exp: chrono::Utc::now().timestamp() as usize + (3600*24*30),
    };

    let cookie = assign_jwt(claims);
    let user = UserAccount {
        password: user.password,
        id: user.id,
        email_address: user.email_address,
        username: user.username,
        mode: user.mode,
        bio: user.bio,
        verified: user.verified,
        profile_photo: user.profile_photo,
        last_seen: user.last_seen,
        updated_at: user.updated_at,
        created_at: user.created_at,
        primary_contact: user.primary_contact
    };

    Ok((cookie, user))
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserProfile {
    pub id: String,
    pub email_address: String,
    pub username: String,
    pub primary_contact: String,
    pub bio: String,
    pub mode: UserMode,
    pub last_seen: String,
    pub profile_photo: Option<String>,
    pub created_at: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserAccount {
    pub id: ObjectId,
    pub password: String,
    pub email_address: String,
    pub username: String,
    pub mode: UserMode,
    pub bio: String,
    pub verified: bool,
    pub profile_photo: Option<String>,
    pub last_seen: DateTime,
    pub updated_at: DateTime,
    pub created_at: DateTime,
    pub primary_contact: String
}

impl From<UserAccount> for UserProfile {
    fn from(value: UserAccount) -> Self {
        Self { 
            id: value.id.to_string(),
            email_address: value.email_address,
            username: value.username,
            primary_contact:  value.primary_contact,
            bio: value.bio,
            mode: value.mode,
            last_seen: value.last_seen.to_string(),
            profile_photo: value.profile_photo,
            created_at: value.created_at.to_string()
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub enum UserMode {
    Stealth,
    Casual
}