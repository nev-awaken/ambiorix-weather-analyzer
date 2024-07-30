# TODO:
# 2) Parse API Response
# 3) Store API into DB table
# 4) Return success or failure status

box::use(
  coro[async],
  httr[GET],
  jsonlite[toJSON, prettify],
  httr2[request, req_perform, resp_body_json],
  RSQLite[dbWriteTable, dbGetQuery],
  utils[head],
  magrittr[`%>%`],
  purrr[pluck],
  pool[poolCheckout, poolReturn],
  lubridate[ymd_hm, with_tz]
)

box::use(
  .. / .. / helper / utils[initDBPool, closePool, getAPIInfo]
)

checkAndInsertHistoricalData <- function(conn, apiResponse, apiInfo) {
  tryCatch(
    {
      query <- sprintf("SELECT COUNT(*) as count FROM temperature_data WHERE api_parameters_id = %d", apiInfo$api_parameters_id)
      result <- dbGetQuery(conn, query)

      cat("apiResponse \n")

      cat("result : \n")
      print(result)


      if (result$count == 0) {
        timeData <- apiResponse %>%
          purrr::pluck("hourly", "time") %>%
          unlist()

        tempData <- apiResponse %>%
          purrr::pluck("hourly", "temperature_2m") %>%
          unlist()

        historical_data <- data.frame(
          timestamp = timeData,
          temperature = tempData,
          units = apiResponse$hourly_units$temperature_2m,
          api_parameters_id = apiInfo$api_parameters_id
        )

        # Debug print
        print("Sample of historical data:")
        print(head(historical_data))

        dbWriteTable(conn, "temperature_data", historical_data, append = TRUE, row.names = FALSE)
        print("Historical data inserted")
      } else {
        print("Historical data already exists for this api_parameters_id")
      }
    },
    error = function(e) {
      print(paste("Error in historical data:", e$message))
      print("API Response Structure:")
    }
  )
}

storeCurrentData <- function(conn, apiResponse, apiInfo) {
  tryCatch(
    {
      current_data <- data.frame(
        timestamp = as.POSIXct(apiResponse$current$time, format = "%Y-%m-%dT%H:%M"),
        temperature = apiResponse$current$temperature_2m,
        units = apiResponse$current_units$temperature_2m,
        api_parameters_id = apiInfo$api_parameters_id
      )

      query <- sprintf(
        "SELECT COUNT(*) as count FROM temperature_data WHERE api_parameters_id = %d AND timestamp = '%s'",
        apiInfo$api_parameters_id,
        current_data$timestamp
      )
      result <- dbGetQuery(conn, query)

      if (result$count == 0) {
        dbWriteTable(conn, "temperature_data", current_data, append = TRUE, row.names = FALSE)
        print("Current data stored")
      }
    },
    error = function(e) {
      print(paste("Error in current data:", e$message))
    }
  )
}

storeAPIResponse <- async(function(apiResponse, conn, apiInfo) {
  print("Starting checkAndInsertHistoricalData")
  await(checkAndInsertHistoricalData(conn, apiResponse, apiInfo))
  print("Completed checkAndInsertHistoricalData")

  print("Starting storeCurrentData")
  await(storeCurrentData(conn, apiResponse, apiInfo))
  print("Completed storeCurrentData")
})


callWeatherAPI <- async(function(apiInfo) {
  tryCatch(
    {
      req <- request(apiInfo$full_url)
      resp <- req_perform(req)
      return(resp_body_json(resp))
    },
    error = function(e) {
      print(paste("API call error:", e$message))
      return(NULL)
    }
  )
})

getAPIParamsInfoFromDB <- async(function(conn) {
  tryCatch(
    {
      query <- "SELECT ID, latitude, longitude FROM api_parameters WHERE is_active = 1 LIMIT 1;"
      apiParams <- dbGetQuery(conn, query)

      if (nrow(apiParams) == 0) {
        print("No active API parameters found in the database")
        return(NULL)
      }

      apiInfo <- getAPIInfo(apiParams$latitude[1], apiParams$longitude[1])
      apiInfo$api_parameters_id <- apiParams$ID[1]

      print("API Info:")
      print(apiInfo)
      return(apiInfo)
    },
    error = function(e) {
      print(paste("Error getting API params:", e$message))
      return(NULL)
    }
  )
})


getAPIParamsInfoFromDB <- async(function(conn) {
  tryCatch(
    {
      query <- "SELECT ID, latitude, longitude FROM api_parameters WHERE is_active = 1 LIMIT 1;"
      apiParams <- dbGetQuery(conn, query)

      if (nrow(apiParams) == 0) {
        stop("No active API parameters found in the database")
      }

      apiInfo <- getAPIInfo(apiParams$latitude[1], apiParams$longitude[1])
      apiInfo$api_parameters_id <- apiParams$ID[1]

      return(apiInfo)
    },
    error = function(e) {
      message(sprintf("Error in getAPIParamsInfoFromDB: %s", e$message))
      return(NULL)
    }
  )
})


callWeatherAPI <- async(function(apiInfo) {
  tryCatch(
    {
      req <- request(apiInfo$full_url)

      resp <- req_perform(req)
      resp_body_json(resp)
    },
    error = function(e) {
      print(paste("API call error:", e$message))
      NULL
    }
  )
})


#' @export
fetchAndStoreWeatherData <- async(function() {
  pool <- NULL
  conn <- NULL

  tryCatch(
    {
      pool <- initDBPool()
      conn <- poolCheckout(pool)

      apiInfo <- await(getAPIParamsInfoFromDB(conn))
      if (is.null(apiInfo)) {
        print("No API parameters found")
        return(FALSE)
      }

      apiResponse <- await(callWeatherAPI(apiInfo))
      if (is.null(apiResponse)) {
        print("API call failed")
        return(FALSE)
      }

      print("Starting storeAPIResponse")
      await(storeAPIResponse(apiResponse, conn, apiInfo))
      print("Completed storeAPIResponse")
    },
    error = function(e) {
      print(paste("Error in fetchAndStoreWeatherData:", e$message))
    }
  )

  if (!is.null(conn)) {
    tryCatch(
      {
        poolReturn(conn)
      },
      error = function(e) {
        print(paste("Error returning connection to pool:", e$message))
      }
    )
  }
  if (!is.null(pool)) {
    tryCatch(
      {
        closePool(pool)
      },
      error = function(e) {
        print(paste("Error closing pool:", e$message))
      }
    )
  }
})
