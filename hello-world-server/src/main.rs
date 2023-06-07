use actix_files::Files;
use actix_web::{middleware::Logger, App, HttpServer};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    log::info!("starting HTTP server at http://0.0.0.0:8080");

    HttpServer::new(|| {
        App::new()
            // enable logger
            .wrap(Logger::default())
            .service(Files::new("/images", "static/images/").show_files_listing())
            .service(Files::new("/", "./static/").index_file("index.html"))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
