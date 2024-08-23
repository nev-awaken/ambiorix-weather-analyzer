box::use(
  . / utils[getFrontEndInfo]
)

# helper/middleware.R
#' @export
cors <- \(req, res) {
  appUrlInfo <- getFrontEndInfo()
  print(appUrlInfo)
  
  allowed_origin <- paste0(appUrlInfo$host, ":", appUrlInfo$port)
  print(allowed_origin)

  res$header("Access-Control-Allow-Origin", allowed_origin)

  if (req$REQUEST_METHOD == "OPTIONS") {
    res$header("Access-Control-Allow-Methods", "*")
    res$header(
      "Access-Control-Allow-Headers",
      req$HEADERS$`access-control-request-headers`
    )
    return(
      res$set_status(200L)$send("")
    )
  }
}
