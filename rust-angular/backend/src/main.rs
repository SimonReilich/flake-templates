use axum::{
    Router,
    body::Body,
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    http::{Response, StatusCode, header},
    response::IntoResponse,
    routing::get,
};
use include_dir::{Dir, include_dir};
use std::net::SocketAddr;
use tokio::time::{Duration, timeout};

static FRONTEND_DIR: Dir<'_> = include_dir!("$FRONTEND_DIST");

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/ws", get(ws_handler))
        .fallback(static_handler);

    let addr = SocketAddr::from(([127, 0, 0, 1], 4444));
    println!("\n[INFO] - Server started at http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn static_handler(uri: axum::http::Uri) -> impl IntoResponse {
    let path = uri.path().trim_start_matches('/');
    let target_path = if path.is_empty() { "index.html" } else { path };

    if let Some(file) = FRONTEND_DIR.get_file(target_path) {
        return serve_file(target_path, file.contents());
    }
    if let Some(index) = FRONTEND_DIR.get_file("index.html") {
        return serve_file("index.html", index.contents());
    }

    (StatusCode::NOT_FOUND, "Frontend not found in binary").into_response()
}

fn serve_file(path: &str, contents: &'static [u8]) -> Response<Body> {
    let mime = mime_guess::from_path(path).first_or_octet_stream();
    Response::builder()
        .header(header::CONTENT_TYPE, mime.as_ref())
        .body(Body::from(contents))
        .unwrap()
}

// WebSockets

async fn ws_handler(ws: WebSocketUpgrade) -> impl IntoResponse {
    ws.on_upgrade(move |socket| handle_socket(socket))
}

async fn handle_socket(mut socket: WebSocket) {
    loop {
        let msg = match timeout(Duration::from_secs(60), socket.recv()).await {
            Ok(Some(Ok(m))) => m,
            Ok(None) => {
                // Client closed connection
                break;
            }
            Ok(Some(Err(e))) => {
                println!("{}", e);
                // WebSocket error
                break;
            }
            Err(_) => {
                // Timeout
                break;
            }
        };

        if let Message::Text(text) = msg {
            println!("{}", text);
            // Handle Request
        }
    }
}
