box::use(
  .. / jobs / setup_database / create_database[setupDatabase],
  .. / jobs / fetch_and_store_data / weather_jobs[fetchAndStoreWeatherData],
  .. / helper / utils[getAppSettingsInfo]
)

box::use(
  coro[async, await],
  lubridate[ceiling_date, now, minutes],
  later
)

#' Calculate the delay until the next aligned time interval
#' @param interval_minutes The interval in minutes
#' @return The number of minutes until the next aligned time
calculateDelay <- function(interval_minutes) {
  tryCatch(
    {
      current_time <- Sys.time()
      next_time <- ceiling_date(current_time, paste(interval_minutes, "mins"))
      as.numeric(difftime(next_time, current_time, units = "mins"))
    },
    error = function(e) {
      message(sprintf("Error in calculateDelay: %s", e$message))
      return(NA)
    }
  )
}

#' @export
executionPipeline <- async(function() {
  tryCatch({
    success <- await(setupDatabase())
    if (!success) {
      message("Database setup failed. Exiting execution pipeline.")
      return(FALSE)
    }
    
    appInfo <- getAppSettingsInfo()
    updateIntervalMinutes <- appInfo$updateIntervalMinutes

    recurringFetch <- function() {
      message("Starting recurring fetch")
      fetchAndStoreWeatherData()$then(
        onFulfilled = function(value) {
          nextFetchTime <- now() + minutes(updateIntervalMinutes)
          message(sprintf("Next fetch scheduled at %s", format(nextFetchTime, "%Y-%m-%d %H:%M:%S")))
          later::later(recurringFetch, delay = updateIntervalMinutes * 60)
        },
        onRejected = function(reason) {
          message(paste("Failed to fetch weather data:", reason))
          later::later(recurringFetch, delay = 60)  
        }
      )
    }

    await(fetchAndStoreWeatherData())
    print("First fetchAndStoreWeatherData completed")

    later::later(recurringFetch, delay = updateIntervalMinutes * 60)


    return(TRUE)
  }, error = function(e) {
    message(sprintf("Error in executionPipeline: %s", e$message))
    return(FALSE)
  })
})

