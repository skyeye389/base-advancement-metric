# ingest_retrosheet/R/retrosheet_download.R

download_retrosheet_plays_zip <- function(year, dest_dir = "ingest_retrosheet/cache", overwrite = FALSE) {
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)

  # Retrosheet parsed play-by-play seasonal zips live here:
  # https://www.retrosheet.org/downloads/plays/2022plays.zip (example)
  zip_url <- sprintf("https://www.retrosheet.org/downloads/plays/%dplays.zip", year)
  zip_path <- file.path(dest_dir, sprintf("%dplays.zip", year))

  if (file.exists(zip_path) && !overwrite) return(zip_path)

  message("Downloading: ", zip_url)
  utils::download.file(zip_url, destfile = zip_path, mode = "wb", quiet = TRUE)
  zip_path
}

extract_retrosheet_plays_zip <- function(zip_path, dest_dir = dirname(zip_path), overwrite = FALSE) {
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)

  listing <- utils::unzip(zip_path, list = TRUE)
  if (nrow(listing) == 0) stop("Zip appears empty: ", zip_path)

  # Typically contains a single CSV like "2022plays.csv" (we do not assume the name; we discover it).
  csv_name <- listing$Name[grepl("\\.csv$", listing$Name, ignore.case = TRUE)][1]
  if (is.na(csv_name) || !nzchar(csv_name)) stop("Could not find a .csv inside: ", zip_path)

  out_path <- file.path(dest_dir, basename(csv_name))
  if (file.exists(out_path) && !overwrite) return(out_path)

  message("Extracting: ", csv_name)
  utils::unzip(zip_path, files = csv_name, exdir = dest_dir, overwrite = overwrite)
  out_path
}

read_retrosheet_plays_csv <- function(csv_path) {
  if (requireNamespace("readr", quietly = TRUE)) {
    return(readr::read_csv(csv_path, show_col_types = FALSE, progress = FALSE))
  }
  utils::read.csv(csv_path, stringsAsFactors = FALSE, check.names = FALSE)
}