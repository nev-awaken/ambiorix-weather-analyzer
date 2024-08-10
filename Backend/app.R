box::use(
  . / helper / utils[getDBInfo, getAppSettingsInfo],
  . / helper / load_libraries[load_all_libraries],
  . / router / weather_info[router],
  . / scheduler / main_scheduler[executionPipeline],
  . / helper / middleware[cors]
)

box::use(
  future[plan, multisession],
  ambiorix[Ambiorix],
  agris[agris],
  promises[promise_all],
  RSQLite[dbConnect, SQLite, dbDisconnect]
)

load_all_libraries()

plan(multisession)

app_settings <- getAppSettingsInfo()
PORT <- app_settings$port
localhost <- app_settings$host

app <- Ambiorix$new()

# CORS middleware
cors <- \(req, res) {
  res$header("Access-Control-Allow-Origin", "127.0.0.1:1001")  

}

app$get("/test", \(req, res) {
  res$send("CORS Test Successful!")
})


app$use(cors)
app$use(router)


promise_all(executionPipeline())


app$start(port = PORT, host = localhost)
