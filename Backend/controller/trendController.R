box::use(
    coro[async],
    ambiorix[parse_json],
    DBI[dbGetQuery, dbDisconnect],
    pool[poolCheckout, poolReturn],
    tidygeocoder[reverse_geo],
    utils[str],
    stats[ts, time, predict],
    forecast[auto.arima, forecast],
    lubridate[as_datetime],
    rlang[`%||%`],
    xgboost[...]
)

box::use(
    .. / helper / utils[connectToDB, closeDBConnection]
)

#' @export
getTrendData <- async(function(req, res) {
    conn <- NULL
    status_code <- 200L
    response_message <- ""
    success <- TRUE
    data <- list(timestamp = c(), temperature = c())

    tryCatch(
        {
            conn <- connectToDB()
            on.exit(closeDBConnection(conn))

            temp_query <- "SELECT timestamp, temperature FROM temperature_data
                ORDER BY timestamp ASC LIMIT 100;"

            location_query <- "SELECT latitude, longitude FROM api_parameters WHERE is_active = TRUE;"



            temp_result <- dbGetQuery(conn, temp_query)
            loc_result <- dbGetQuery(conn, location_query)

            location_info <- reverse_geo(lat = loc_result$latitude, long = loc_result$longitude, method = "osm")

            print(location_info$address)


            data <- list(
                location = location_info$address,
                timestamp = as_datetime(temp_result$timestamp),
                temperature = temp_result$temperature
            )

            str(data, max.level = 1)

            return(
                res$json(
                    status = status_code,
                    body = list(
                        success = success,
                        data = data
                    )
                )
            )
        },
        error = function(e) {
            status_code <- 500L
            success <- FALSE
            print(sprintf("Error in : %s", e$message))

            response_message <- sprintf("Error in : %s", e$message)
            return(
                res$json(
                    status = status_code,
                    body = list(
                        success = success,
                        message = response_message
                    )
                )
            )
        }
    )
})


#' @export
getForecast <- async(function(req, res) {
    conn <- NULL
    status_code <- 200L
    response_message <- ""
    success <- TRUE
    forecast <- list()

    tryCatch(
        {
            conn <- connectToDB()
            on.exit(closeDBConnection(conn))

            
            hours <- as.integer(req$query$hours %||% 2)

        
            temp_query <- "SELECT timestamp, temperature FROM temperature_data
                ORDER BY timestamp ASC;"
            temp_result <- dbGetQuery(conn, temp_query)

          
            df <- data.frame(
                ds = as.POSIXct(temp_result$timestamp, origin = "1970-01-01"),
                y = temp_result$temperature
            )

          
            df$time_numeric <- as.numeric(df$ds)

            
            lagged_data <- data.frame(
                y = df$y[-1],
                lag1 = df$y[-nrow(df)],
                time_numeric = df$time_numeric[-1]
            )

      
            dtrain <- xgb.DMatrix(data = as.matrix(lagged_data[, c("lag1", "time_numeric")]), label = lagged_data$y)

          
            params <- list(objective = "reg:squarederror", max_depth = 3, eta = 0.1, nthread = 2)
            xgb_model <- xgboost(params = params, data = dtrain, nrounds = 100, verbose = FALSE)

      
            future_timestamps <- seq(
                from = max(df$time_numeric),
                by = 3600, 
                length.out = hours
            )


            future_values <- numeric(hours)
            current_value <- df$y[nrow(df)]
            for (i in 1:hours) {
                new_data <- as.matrix(data.frame(lag1 = current_value, time_numeric = future_timestamps[i]))
                future_values[i] <- predict(xgb_model, new_data)
                current_value <- future_values[i]
            }

            forecast <- list(
                timestamp = as.POSIXct(future_timestamps, origin = "1970-01-01"),
                temperature = future_values
            )

            return(
                res$json(
                    status = status_code,
                    body = list(
                        success = success,
                        forecast = forecast
                    )
                )
            )
        },
        error = function(e) {
            print(sprintf("Error in getForecast: %s", e$message))
            status_code <- 500L
            success <- FALSE
            response_message <- sprintf("Error in getForecast: %s", e$message)
            return(
                res$json(
                    status = status_code,
                    body = list(
                        success = success,
                        message = response_message
                    )
                )
            )
        }
    )
})
