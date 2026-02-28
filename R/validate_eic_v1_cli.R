#!/usr/bin/env Rscript
# validate_eic_v1_cli.R
#
# Validate one EIC-v1 game file or a directory of files before running the v1.0 engine.
#
# Usage:
#   Rscript validate_eic_v1_cli.R --path data/ingested_retrosheet/2022
#   Rscript validate_eic_v1_cli.R --path one_game.csv
#   Rscript validate_eic_v1_cli.R --path data --recursive --strict-types
#
# Exit codes:
#   0 = all files valid
#   1 = one or more files invalid (or read error)

# ----------------------------
# Arg parsing (no dependencies)
# ----------------------------
args <- commandArgs(trailingOnly = TRUE)

get_flag <- function(flag) flag %in% args

get_value <- function(flag, default = NULL) {
  idx <- match(flag, args)
  if (is.na(idx)) return(default)
  if (idx == length(args)) return(default)
  val <- args[[idx + 1]]
  if (startsWith(val, "--")) return(default)
  val
}

print_help_and_exit <- function(code = 0) {
  cat(
"validate_eic_v1_cli.R

Validate EIC-v1 compliance for one file or a directory of game files.

Options:
  --path <file|dir>     Required. Path to a .csv/.xlsx file or a directory.
  --recursive           If --path is a directory, recurse subdirectories.
  --strict-types        Enforce strict column types (otherwise allows safe coercion).
  --extensions <list>   Comma-separated extensions to scan in directories (default: csv,xls,xlsx).
  --quiet               Only print errors + final summary.
  --help                Print help.

Examples:
  Rscript validate_eic_v1_cli.R --path data/ingested_retrosheet/2022 --recursive
  Rscript validate_eic_v1_cli.R --path 2022-04-10_BAL_TBR.csv
",
    sep = ""
  )
  quit(status = code, save = "no")
}

if (get_flag("--help") || length(args) == 0) print_help_and_exit(0)

path <- get_value("--path", default = NA_character_)
if (is.na(path) || !nzchar(path)) {
  cat("ERROR: --path is required.\n")
  print_help_and_exit(1)
}

recursive <- get_flag("--recursive")
strict_types <- get_flag("--strict-types")
quiet <- get_flag("--quiet")
exts <- strsplit(get_value("--extensions", "csv,xls,xlsx"), ",", fixed = TRUE)[[1]]
exts <- tolower(trimws(exts))

# ----------------------------
# Locate validator
# ----------------------------
# Try to source validate_eic_v1() from R/validate_eic_v1.R relative to this script.
# Fallback: error with instructions.
script_dir <- tryCatch({
  # Works in most Rscript invocations
  normalizePath(dirname(sys.frame(1)$ofile))
}, error = function(e) NULL)

candidate_paths <- c(
  if (!is.null(script_dir)) file.path(script_dir, "R", "validate_eic_v1.R") else NULL,
  file.path(getwd(), "R", "validate_eic_v1.R")
)

validator_loaded <- FALSE
for (p in candidate_paths) {
  if (!is.null(p) && file.exists(p)) {
    source(p, local = TRUE)
    validator_loaded <- TRUE
    break
  }
}
if (!validator_loaded || !exists("validate_eic_v1", mode = "function")) {
  cat("ERROR: Could not find validate_eic_v1().\n")
  cat("Expected to source R/validate_eic_v1.R relative to this script or the current working directory.\n")
  quit(status = 1, save = "no")
}

# ----------------------------
# File discovery
# ----------------------------
stopf <- function(...) stop(sprintf(...), call. = FALSE)

is_file <- file.exists(path) && !dir.exists(path)
is_dir  <- dir.exists(path)

if (!file.exists(path)) stopf("Path does not exist: %s", path)

files <- character(0)
if (is_file) {
  files <- normalizePath(path)
} else if (is_dir) {
  # Build regex from extensions
  # Example: \.(csv|xls|xlsx)$
  ext_regex <- paste0("\\.(", paste(exts, collapse = "|"), ")$")
  files <- list.files(
    path = path,
    pattern = ext_regex,
    recursive = recursive,
    full.names = TRUE,
    ignore.case = TRUE
  )
  files <- normalizePath(files, winslash = "/", mustWork = FALSE)
} else {
  stopf("Path is neither a file nor directory: %s", path)
}

if (length(files) == 0) stopf("No matching files found at: %s", path)

# ----------------------------
# Readers
# ----------------------------
read_game_file <- function(fp) {
  ext <- tolower(tools::file_ext(fp))
  if (ext == "csv") {
    if (requireNamespace("readr", quietly = TRUE)) {
      return(readr::read_csv(fp, show_col_types = FALSE, progress = FALSE))
    }
    return(utils::read.csv(fp, stringsAsFactors = FALSE, check.names = FALSE))
  }

  if (ext %in% c("xls", "xlsx")) {
    if (!requireNamespace("readxl", quietly = TRUE)) {
      stopf("Missing dependency 'readxl' needed to read %s. Install with: install.packages('readxl')", fp)
    }
    # Read first sheet by default; preserve column names
    return(readxl::read_excel(fp, sheet = 1, .name_repair = "minimal"))
  }

  stopf("Unsupported file extension: %s", ext)
}

# ----------------------------
# Validate files
# ----------------------------
ok <- 0L
bad <- 0L
failures <- list()

log <- function(...) if (!quiet) cat(sprintf(...), "\n")

log("Validating %d file(s) (strict_types=%s, recursive=%s)", length(files), strict_types, recursive)

for (fp in files) {
  msg_prefix <- sprintf("[%s]", basename(fp))
  tryCatch({
    df <- read_game_file(fp)
    validate_eic_v1(df, strict_types = strict_types)
    ok <<- ok + 1L
    log("%s OK", msg_prefix)
  }, error = function(e) {
    bad <<- bad + 1L
    failures[[fp]] <<- conditionMessage(e)
    cat(sprintf("%s FAIL: %s\n", msg_prefix, conditionMessage(e)))
  })
}

cat(sprintf("\nSummary: %d OK, %d FAIL (total %d)\n", ok, bad, ok + bad))

if (bad > 0) {
  cat("\nFailures:\n")
  for (fp in names(failures)) {
    cat(sprintf("- %s\n  %s\n", fp, failures[[fp]]))
  }
  quit(status = 1, save = "no")
}

quit(status = 0, save = "no")