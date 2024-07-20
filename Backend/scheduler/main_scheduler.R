box::use(
  .. / jobs / setup_database / create_database[setupDatabase],
  .. / jobs / fetch_and_store_data / weather_jobs[fetchAndStoreWeatherData],
  .. / helper / utils[getAppSettingsInfo]
)

box::use(
  coro[async, await],
  lubridate[ceiling_date],
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
  tryCatch(
    {
      success <- await(setupDatabase())
      if (!success) {
        message("Database setup failed. Exiting execution pipeline.")
        return(FALSE)
      }

      appInfo <- getAppSettingsInfo()
      updateIntervalMinutes <- appInfo$updateIntervalMinutes

      recurringFetch <- function() {
        fetchAndStoreWeatherData()$then(
          onFulfilled = function(value) {
            message("Weather data fetched successfully")
            delay <- calculateDelay(updateIntervalMinutes)
            if (!is.na(delay)) {
              message(sprintf("Next fetch scheduled in %.2f minutes", delay))
              later::later(recurringFetch, delay = delay * 60)
            } else {
              message("Failed to calculate next fetch time. Retrying in 1 minute.")
              later::later(recurringFetch, delay = 60)
            }
          },
          onRejected = function(reason) {
            message(paste("Failed to fetch weather data:", reason))
            delay <- calculateDelay(updateIntervalMinutes)
            if (!is.na(delay)) {
              message(sprintf("Next fetch scheduled in %.2f minutes", delay))
              later::later(recurringFetch, delay = delay * 60)
            } else {
              message("Failed to calculate next fetch time. Retrying in 1 minute.")
              later::later(recurringFetch, delay = 60)
            }
          }
        )
      }

      initial_delay <- calculateDelay(updateIntervalMinutes)
      if (!is.na(initial_delay)) {
        message(sprintf("Initial fetch scheduled in %.2f minutes", initial_delay))
        later::later(recurringFetch, delay = initial_delay * 60)
      } else {
        message("Failed to calculate initial fetch time. Starting immediately.")
        recurringFetch()
      }

      return(TRUE)
    },
    error = function(e) {
      message(sprintf("Error in executionPipeline: %s", e$message))
      return(FALSE)
    }
  )
})
