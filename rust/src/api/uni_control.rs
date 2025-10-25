use env_logger::Env;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    let _ = env_logger::try_init_from_env(Env::default().filter_or("RUST_LOG", "debug"));
    flutter_rust_bridge::setup_default_user_utils();
}
