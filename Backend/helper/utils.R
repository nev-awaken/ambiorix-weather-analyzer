box::use(
  yaml[read_yaml],
  httr2[url_parse, url_build],
  pool[dbPool, poolClose],
  RSQLite[SQLite, dbConnect]
)


readYaml <- function() {
  yaml::read_yaml("config/app_config.yaml")
}


getDBInfo <- function() {
  app_config <- readYaml()
  dbName <- app_config$database_info$DB_NAME
  dbLocation <- app_config$database_info$DB_LOCATION
  return(list("dbName" = dbName, "dbLocation" = dbLocation))
}

getAppSettingsInfo <- function() {
  app_config <- readYaml()
  port <- app_config$app_settings$port
  host <- app_config$app_settings$host
  updateIntervalMinutes <- app_config$app_settings$update_interval_minutes

  return(
    list(
      "port" = port,
      "host" = host,
      "updateIntervalMinutes" = updateIntervalMinutes
    )
  )
}


getAPIInfo <- function(latitude = NULL, longitude = NULL) {
  app_config <- readYaml()
  
  base_url <- app_config$api_info$base_url
  default_params <- app_config$api_info$default_params
  current_params <- paste(app_config$api_info$current_params, collapse = ",")
  hourly_params <- paste(app_config$api_info$hourly_params, collapse = ",")
  forecast_days <- app_config$api_info$forecast_days
  
  lat <- latitude %||% default_params$latitude
  long <- longitude %||% default_params$longitude
  
  query_params <- list(
    latitude = lat,
    longitude = long,
    current = current_params,
    hourly = hourly_params,
    forecast_days = forecast_days
  )
  
  parsed_url <- url_parse(base_url)
  parsed_url$query <- query_params
  full_url <- url_build(parsed_url)
  
  return(list(
    "full_url" = full_url,
    "base_url" = base_url,
    "latitude" = lat,
    "longitude" = long,
    "current_params" = current_params,
    "hourly_params" = hourly_params,
    "forecast_days" = forecast_days
  ))
}

# Null coalescing operator
`%||%` <- function(x, y) if (is.null(x)) y else x


initDBPool <- function() {
  dbInfo <- getDBInfo()
  dbName <- dbInfo$dbName
  dbLocation <- dbInfo$dbLocation
  fullPath <- paste0("./", dbLocation, dbName)
  
  dbPool <- dbPool(
    drv = SQLite(),
    dbname = fullPath
  )
  
  return(dbPool)
}

box::export(getDBInfo, getAppSettingsInfo, getAPIInfo, initDBPool)