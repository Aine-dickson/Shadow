use axum::{http::{header, Method}, Router};
use dotenvy::dotenv;
use mongodb::{Client, Database};
use tower_cookies::CookieManagerLayer;
use tower_http::cors::{Any, CorsLayer};
use user::user_controller::user_controller;

pub mod user;
pub mod utils;

#[derive(Clone)]
pub struct AppState {
    db: Database
}

#[tokio::main]
async fn main(){
    dotenv().ok();
    let client = Client::with_uri_str("mongodb://localhost:27017").await.unwrap();

    let state = AppState {
        db: client.database("shadow")
    };

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods([Method::GET, Method::POST, Method::DELETE, Method::PUT, Method::OPTIONS])
        .allow_headers([header::AUTHORIZATION, header::ACCEPT, header::CONTENT_TYPE, header::ORIGIN, header::COOKIE]);

    let app = Router::new()
                        .nest("/users", user_controller())
                        .layer(cors)
                        .layer(CookieManagerLayer::new())
                        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}