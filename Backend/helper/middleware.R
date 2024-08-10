# helper/middleware.R
# '@export'
cors <- \(req, res) {
  res$header("Access-Control-Allow-Origin", "http://localhost:3000")
}

