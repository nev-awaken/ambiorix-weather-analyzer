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
  promises[promise_all]
)

load_all_libraries()

plan(multisession)

app_settings <- getAppSettingsInfo()
PORT <- app_settings$port
localhost <- app_settings$host

app <- Ambiorix$new()



app$get("/test", \(req, res) {
  res$send("CORS Test Successful!")
})


app$use(router)
app$use(cors)


promise_all(executionPipeline())


app$start(port = PORT, host = localhost)
