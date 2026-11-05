use std::env;

#[derive(Clone, Debug)]
pub struct Config {
    pub host: String,
    pub port: u16,
    pub database_url: String,
    pub jwt_secret: String,
    pub jwt_expiration_hours: i64,
    pub fcm_service_account_key: Option<String>,
    pub upload_bucket: String,
    pub upload_endpoint: String,
    pub environment: String,
}

impl Config {
    pub fn from_env() -> Result<Self, String> {
        let _ = dotenvy::dotenv();

        let host = env::var("HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
        let port = env::var("PORT")
            .unwrap_or_else(|_| "8080".to_string())
            .parse::<u16>()
            .map_err(|e| format!("Invalid PORT: {}", e))?;

        let database_url = env::var("DATABASE_URL")
            .unwrap_or_else(|_| "postgres://pashupati:pashupati_secret@localhost:5432/pashupati".to_string());

        let jwt_secret = env::var("JWT_SECRET")
            .unwrap_or_else(|_| "pashupati_dev_jwt_secret_change_in_production_min32chars!".to_string());

        let jwt_expiration_hours = env::var("JWT_EXPIRATION_HOURS")
            .unwrap_or_else(|_| "720".to_string()) // 30 days
            .parse::<i64>()
            .unwrap_or(720);

        let fcm_service_account_key = env::var("FCM_SERVICE_ACCOUNT_KEY").ok();
        let upload_bucket = env::var("UPLOAD_BUCKET").unwrap_or_else(|_| "pashupati-media".to_string());
        let upload_endpoint = env::var("UPLOAD_ENDPOINT").unwrap_or_else(|_| "http://localhost:9000".to_string());
        let environment = env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string());

        Ok(Self {
            host,
            port,
            database_url,
            jwt_secret,
            jwt_expiration_hours,
            fcm_service_account_key,
            upload_bucket,
            upload_endpoint,
            environment,
        })
    }
}
