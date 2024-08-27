# controller/checkUserCredentials.R
box::use(
  coro[async],
  ambiorix[parse_json],
  DBI[dbGetQuery, dbDisconnect],
  pool[poolCheckout, poolReturn]
)

box::use(
  .. / helper / utils[connectToDB, closeDBConnection]
)

#' @export
checkUserCredentials <- async(function(req, res) {
  conn <- NULL
  status_code <- NULL
  response_message <- ""
  success <- FALSE
  
  tryCatch({
    parsed_body <- parse_json(req)

    email <- parsed_body$email
    password <- parsed_body$password

    if (email == "" || password == "") {
      status_code <- 400L
      response_message <- "Email and password are required"
      return(res$json(status = status_code, body = list(success = FALSE, message = response_message)))
    }

    conn <- connectToDB()
    on.exit(closeDBConnection(conn))

    query <- "SELECT * FROM user_login WHERE email = ? AND password = ?"
    result <- dbGetQuery(conn, query, params = list(email, password))

    if (nrow(result) > 0) {
      success <- TRUE
      status_code <- 200L
      response_message <- "User authenticated"
    } else {
      status_code <- 401L
      response_message <- "Invalid credentials"
    }

    return(res$json(status = status_code, body = list(success = success, message = response_message)))
  }, error = function(e) {
    print(paste("Error occurred:", e$message))
    if (!is.null(conn)) {
      closeDBConnection(conn)
    }
    response_message <- "Internal server error"
    return(res$json(status = 500, body = list(success = FALSE, message = response_message)))
  })
})


#' @export
checkUser <- async(function(req, res) {
  res$json(status = 500, body = list(message = "checkUser tester"))
})
