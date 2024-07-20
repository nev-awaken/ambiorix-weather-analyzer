# TODO:
# 1) Call API function
# 2) Parse API Response
# 3) Store API into DB table
# 4) Return success or failure status

box::use(
  coro[async],
  httr[GET],
  jsonlite[toJSON, prettify],
  httr2[request, req_perform, resp_body_json],
  RSQLite[dbConnect, SQLite, dbWriteTable, dbDisconnect],
  utils[head]
)

box::use(
  .. / .. / helper / utils[getAPIInfo],
)

callWeatherAPI <- async(function() {
  tryCatch(
    {
      apiInfo <- getAPIInfo()
      req <- request(apiInfo$full_url)
      resp <- req_perform(req)

      json_data <- resp_body_json(resp)

      current_weather <- json_data$current

      cat("\nCurrent Weather Data:\n")
      cat(prettify(toJSON(current_weather, auto_unbox = TRUE), indent = 2))


      cat("\nEntire Response:\n")
      cat(prettify(toJSON(json_data, auto_unbox = TRUE), indent = 2))
    },
    error = function(e) {
      message(sprintf("Error in : %s", emessage))
    }
  )
})

storeAPIResponse <- async(function(){
  tryCatch({
      
  }, error = function(e) {
      message(sprintf('Error in : %s', emessage))
      
  })
})

#' @export
fetchAndStoreWeatherData <- async(function() {
  # Fetch weather data

  apiResponse <- await(callWeatherAPI())
  await(storeAPIResponse(apiResponse))

  return(TRUE)
})
