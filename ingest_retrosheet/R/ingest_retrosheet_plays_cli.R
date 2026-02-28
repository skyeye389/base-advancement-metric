#!/usr/bin/env Rscript
# ingest_retrosheet/R/ingest_retrosheet_plays_cli.R

args <- commandArgs(trailingOnly = TRUE)

get_flag <- function(flag) flag %in% args
get_value <- function(flag, default = NULL) {
  idx <- match(flag, args)
  if (is.na(idx) || idx == length(args)) return(default)
  val <- args[[idx + 1]]
  if (startsWith(val, "--")) return(default)
  val
}

help <- function(code = 0) {
  cat(
"ingest_retrosheet_plays_cli.R

Download Retrosheet parsed play-by-play (plays) for a season and emit EIC-v1 per-game files.

Options:
  --year <YYYY>           Required (e.g., 2022)
  --out <dir>             Output directory for per-game EIC-v1 CSVs (default: data/ingested_retrosheet/<YYYY>)
  --cache <dir>           Cache directory for downloads (default: ingest_retrosheet/cache)
  --overwrite             Overwrite cached zip/csv and outputs
  --help

Example:
  Rscript ingest_retrosheet/R/ingest_retrosheet_plays_cli.R --year 2022 --out data/ingested_retrosheet/2022
",
    sep = ""
  )
  quit(status = code, save = "no")
}

if (get_flag("--help") || length(args) == 0) help(0)

year <- suppressWarnings(as.integer(get_value("--year", NA)))
if (is.na(year)) { cat("ERROR: --year is required\n"); help(1) }

out_dir <- get_value("--out", sprintf("data/ingested_retrosheet/%d", year))
cache_dir <- get_value("--cache", "ingest_retrosheet/cache")
overwrite <- get_flag("--overwrite")

# Source modules
source("ingest_retrosheet/R/retrosheet_download.R")
source("ingest_retrosheet/R/retrosheet_plays_to_eic_v1.R")

zip_path <- download_retrosheet_plays_zip(year, dest_dir = cache_dir, overwrite = overwrite)
csv_path <- extract_retrosheet_plays_zip(zip_path, dest_dir = cache_dir, overwrite = overwrite)

plays_df <- read_retrosheet_plays_csv(csv_path)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
retrosheet_plays_to_eic_v1(plays_df, output_dir = out_dir, year = year, write_files = TRUE)

cat(sprintf("Done. Wrote EIC-v1 per-game files to: %s\n", out_dir))
quit(status = 0, save = "no")