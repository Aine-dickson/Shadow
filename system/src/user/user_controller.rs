use axum::{extract::State, http:: StatusCode, response::IntoResponse, routing::post, Json, Router};
use tower_cookies::{cookie::SameSite, Cookie, Cookies};
use validator::Validate;
use crate::AppState;
use axum::debug_handler;

use super::{user_dtos::{LoginDto, SignupDto}, user_service::{login, signup}};

#[debug_handler]
async fn login_handler(cookies: Cookies, State(app_state): State<AppState>, Json(user): Json<LoginDto>)-> impl IntoResponse{
    if let Err(errors) = user.validate() {
        return (StatusCode::BAD_REQUEST, format!("{}", errors)).into_response();
    }
    let response = login(user, app_state.db.clone()).await;

    let response = match response {
        Ok(res) => res,
        Err(err)  => return err.into_response()
    };

    let cookie = Cookie::build(("auth", response.0))
                                .http_only(true)
                                .path("/")
                                .same_site(SameSite::Lax)
                                .build();
    cookies.add(cookie);
    let response = serde_json::to_string(&response.1).unwrap();

    (StatusCode::CREATED, response).into_response()
}

#[debug_handler]
async fn signup_handler(cookies: Cookies, State(app_state): State<AppState>, Json(user): Json<SignupDto>)-> impl IntoResponse{
    if let Err(errors) = user.validate() {
        return (StatusCode::BAD_REQUEST, format!("{}", errors)).into_response();
    }
    let response = signup(user, app_state.db.clone()).await;

    let response = match response {
        Ok(res) => res,
        Err(err)  => return err.into_response()
    };

    let cookie = Cookie::build(("auth", response.0))
                                .http_only(true)
                                .path("/")
                                .same_site(SameSite::Lax)
                                .build();
    cookies.add(cookie);
    let response = serde_json::to_string(&response.1).unwrap();
    (StatusCode::CREATED, response).into_response()
}

pub fn user_controller()-> Router<AppState>{
    Router::new()
        .route("/login", post(login_handler))
        .route("/signup", post(signup_handler))
}