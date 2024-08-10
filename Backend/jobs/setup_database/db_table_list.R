# Tables :
# 1) Default API Parameters table :ID, longitude, latitude, forecast_days, current_params, hourly_params, is_active
# 2) Store temperature data for each timestamp: id, temperature, units, some reference to latitude and longitude from api_parameters_table

create_api_parameters_table <- "
CREATE TABLE IF NOT EXISTS api_parameters (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    longitude REAL NOT NULL,
    latitude REAL NOT NULL,
    forecast_days INTEGER NOT NULL,
    current_params TEXT,
    hourly_params TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    UNIQUE(longitude, latitude, forecast_days, current_params)
);
"

create_temperature_data_table <- "
CREATE TABLE IF NOT EXISTS temperature_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME NOT NULL,
    temperature REAL NOT NULL,
    units TEXT NOT NULL,
    api_parameters_id INTEGER,
    FOREIGN KEY(api_parameters_id) REFERENCES api_parameters(ID)
);
"

create_user_login_table  <- "
CREATE TABLE IF NOT EXISTS user_login (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT,
    password TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
"

create_table_queries_list <-  list(create_api_parameters_table, create_temperature_data_table, create_user_login_table)

box::export(create_table_queries_list)