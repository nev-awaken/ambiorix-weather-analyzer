box::use(
  ./helper/utils[getDBInfo, getAppSettingsInfo],
  ./helper/load_libraries[load_all_libraries],
  ./router/weather_info[router],
  ./scheduler/main_scheduler[executionPipeline]
)

box::use(
  future[plan, multisession],
  ambiorix[Ambiorix],
  promises[promise_all],
  RSQLite[dbConnect, SQLite, dbDisconnect]
)

load_all_libraries()

plan(multisession)

app_settings <- getAppSettingsInfo()
PORT <- app_settings$port
localhost <- app_settings$host

app <- Ambiorix$new()

app$use(function(req, res) {
  res$header("Access-Control-Allow-Origin", "*")
  res$header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
  res$header("Access-Control-Allow-Headers", "Content-Type, Authorization")
})

app$options("*", function(req, res) {
  res$header("Access-Control-Allow-Origin", "*")
  res$header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
  res$header("Access-Control-Allow-Headers", "Content-Type, Authorization")
  res$send()
})

app$use(router)


promise_all(executionPipeline())

# Start the server
app$start(port = PORT, host = localhost)