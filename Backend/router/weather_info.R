# Routers to get weather info
box::use(
  ambiorix[Router],
  coro[async, await]
)

box::use(
  ../controller/checkUserCredentials[checkUserCredentials, checkUser]
)

router <- Router$new("/")



router$get("", function(req, res){
  home_page_message <- "Welcome to home page"
  res$send(home_page_message)
})

router$get("api/test", function(req, res) {
  str <- strftime(Sys.time(), "%Y-%m-%d %H:%M:%S")
  res$send(str)
})


router$post("login", checkUserCredentials)

router$post("login1", checkUser)
