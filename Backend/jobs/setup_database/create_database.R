box::use(
  RSQLite[dbConnect, SQLite, dbDisconnect, dbExecute],
  coro[async],
  DBI[dbExecute]
)

box::use(
  .. / .. / helper / utils[getDBInfo, getAPIInfo, deleteDBIfExists],
  .. / setup_database / db_table_list[create_table_queries_list]
)

insertAPIInfo <- async(function(mydb) {
  tryCatch(
    {
      apiInfo <- getAPIInfo()

      query <- "
    INSERT INTO api_parameters (longitude, latitude, forecast_days, current_params, hourly_params, is_active)
    VALUES (?, ?, ?, ?, ?, ?)
    "
      dbExecute(mydb, query, params = list(
        apiInfo$longitude,
        apiInfo$latitude,
        apiInfo$forecast_days,
        apiInfo$current_params,
        apiInfo$hourly_params,
        1
      ))

      cat("API info inserted successfully\n")
    },
    error = function(e) {
      message(sprintf("Error in insertAPIInfo: %s", e$message))
    }
  )
})

insertUserInfo <- async(function(mydb) {
  tryCatch(
    {
      #Hard Code User Credentials
      userInfo <- list(
        password = "admin123",
        email = "admin@example.com"
      )

      query <- "
        INSERT INTO user_login (email, password)
        VALUES (?, ?)
      "
      print(mydb)
      dbExecute(mydb, query, params = list(
        userInfo$email,
        userInfo$password
      ))

      cat("User credentials inserted successfully\n")
    },
    error = function(e) {
      message(sprintf("Error in insertUserInfo: %s", e$message))
    }
  )
})



createTables <- async(function(mydb) {
  tryCatch(
    {
      lapply(create_table_queries_list, function(query) dbExecute(mydb, query))
      print("Tables created successfully")

      await(insertUserInfo(mydb))
    },
    error = function(e) {
      message(sprintf("Error in createTables(): %s", e$message))
    }
  )
})


setupDatabase <- async(function() {
  tryCatch(
    {
      # For testing, deleting old DB
      deleteDBIfExists()

      dbInfo <- getDBInfo()
      dbName <- dbInfo$dbName
      dbLocation <- dbInfo$dbLocation
      fs::dir_create(dbLocation, recurse = TRUE)

      fullPath <- paste0("./", dbLocation, dbName)

      if (file.exists(fullPath)) {
        message("Database already exists. Skipping setup.")
        return(TRUE)
      }

      message(paste("Creating database:", dbName))
      mydb <- dbConnect(RSQLite::SQLite(), fullPath)

      cat("database created: ", dbName)

      on.exit(dbDisconnect(mydb))

      await(createTables(mydb))
      await(insertAPIInfo(mydb))

      return(TRUE)
    },
    error = function(e) {
      message(sprintf("Error at setupDatabase(): %s", e$message))
      return(FALSE)
    }
  )
})

box::export(setupDatabase)
