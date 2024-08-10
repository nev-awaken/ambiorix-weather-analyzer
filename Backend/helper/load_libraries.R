
#' @export 
load_all_libraries <- function() {
  libraries <- c("coro", "httr2", "yaml", "dplyr", "tidyr", "lubridate", "jsonlite", "later", "utils", "agris")
  cat("Libraries to load :", paste(libraries, collapse = ", "), "\n")
  
  for (lib in libraries) {
    suppressPackageStartupMessages(library(lib, character.only = TRUE))
  }
  
  message("👍 All libraries loaded successfully.")
}