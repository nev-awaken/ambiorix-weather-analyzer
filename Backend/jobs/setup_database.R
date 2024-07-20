box::use(
    RSQLite[dbConnect, SQLite, dbDisconnect, dbExecute],
    .. / helper / utils[getDBInfo],
    coro[async]
)


createDatabase <- async(function() {
    tryCatch(
        {
            dbInfo <- getDBInfo()
            dbName <- dbInfo$dbName
            dbLocation <- dbInfo$dbLocation
            fs::dir_create(dbLocation, recurse = TRUE)

            fullPath <- paste0("./", dbLocation, dbName)

            message(paste("Creating database:", dbName))
            mydb <- dbConnect(RSQLite::SQLite(), fullPath)

            cat("database created : ", dbName)

            on.exit(dbDisconnect(mydb))
        },
        error = function(e) {
            message(sprintf("Error at  createDatabase(): %s", e$message))
        }
    )
})


setupDatabase <- async(function() {
    tryCatch(
        {
            await(createDatabase())
            print("Database setup completed successfully")
            return(TRUE)
        },
        error = function(e) {
            message(sprintf("Error in setupDatabase: %s", e$message))
            return(FALSE)
        }
    )
})
