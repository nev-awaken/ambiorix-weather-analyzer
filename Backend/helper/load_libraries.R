#' @export
load_all_libraries <- function() {
  libraries <- c("coro", "httr2", "yaml", "dplyr", "tidyr", "lubridate", "jsonlite", "later", "utils", "agris", "tidygeocoder", "xgboost")
  cat("Libraries to load:", paste(libraries, collapse = ", "), "\n")

  if (!requireNamespace("pak", quietly = TRUE)) {
    install.packages("pak")
  }
 

  for (lib in libraries) {
    if (!requireNamespace(lib, quietly = TRUE)) {
      cat(paste("Package", lib, "not found. Installing it now...\n"))
      pak::pkg_install(lib)
    }
    suppressPackageStartupMessages(library(lib, character.only = TRUE))
  }

  message("👍 All libraries loaded successfully.")
}
