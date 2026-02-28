# ingest_retrosheet/R/retrosheet_plays_to_eic_v1.R

# Convert Retrosheet parsed "plays" rows into EIC-v1 per-game files (CSV)
# Critical fields come directly from parsed plays:
# outs_pre/outs_post, br*_pre, runs, inning, top_bot, batteam, batter, pitcher, pitches, score_v/score_h, gid, date
# Column definitions are documented by Retrosheet. :contentReference[oaicite:2]{index=2}

# -------- helpers --------

mask_from_bases <- function(on1, on2, on3) {
  as.integer(on1) * 1L + as.integer(on2) * 2L + as.integer(on3) * 4L
}

rob_raw_from_mask <- function(mask) {
  # mapping defined in EIC-v1
  map <- c(
    "0"="---","1"="1--","2"="-2-","3"="12-",
    "4"="--3","5"="1-3","6"="-23","7"="123"
  )
  out <- unname(map[as.character(mask)])
  if (any(is.na(out))) stop("Invalid base mask encountered.")
  out
}

parse_date_any <- function(x) {
  # Accepts: "YYYY-MM-DD", "YYYYMMDD", "MM/DD/YYYY"
  x <- as.character(x)
  x <- trimws(x)
  
  # Treat blank/"NA" as missing
  x[x %in% c("", "NA", "NaN")] <- NA_character_
  
  # If it's YYYYMMDD (8 digits), convert to YYYY-MM-DD
  is_yyyymmdd <- !is.na(x) & grepl("^[0-9]{8}$", x)
  x[is_yyyymmdd] <- paste0(substr(x[is_yyyymmdd], 1, 4), "-",
                           substr(x[is_yyyymmdd], 5, 6), "-",
                           substr(x[is_yyyymmdd], 7, 8))
  
  # Try multiple formats safely
  out <- suppressWarnings(as.Date(x, format = "%Y-%m-%d"))
  need2 <- is.na(out) & !is.na(x)
  if (any(need2)) out[need2] <- suppressWarnings(as.Date(x[need2], format = "%m/%d/%Y"))
  
  # If anything still fails to parse, return NA (do NOT error)
  out
}
parse_gid <- function(gid) {
  # Robust parse for Retrosheet game id.
  gid <- as.character(gid)
  if (is.na(gid) || nchar(gid) < 12) {
    return(list(home_team = NA_character_, game_date = as.Date(NA), game_num = 0L))
  }
  
  home_team <- substr(gid, 1, 3)
  yy <- substr(gid, 4, 5)
  mm <- substr(gid, 6, 7)
  dd <- substr(gid, 8, 9)
  n  <- substr(gid, 12, 12)
  
  # Build a YYYYMMDD string, then parse with our safe parser
  year_full <- paste0("20", yy)
  date_str <- paste0(year_full, mm, dd)   # e.g., 20220407
  game_date <- parse_date_any(date_str)   # safe; returns Date or NA (never errors)
  
  game_num <- suppressWarnings(as.integer(n))
  if (is.na(game_num)) game_num <- 0L
  
  list(home_team = home_team, game_date = game_date, game_num = game_num)
}

inn_label <- function(inning, top_bot) {
  # top_bot: 0 top, 1 bottom per Retrosheet plays definition :contentReference[oaicite:4]{index=4}
  prefix <- ifelse(as.integer(top_bot) == 0L, "t", "b")
  paste0(prefix, as.integer(inning))
}

score_string <- function(score_v, score_h) {
  # simple display; not used for scoring
  paste0(as.integer(score_v), "-", as.integer(score_h))
}

ensure_cols_exist <- function(df, cols) {
  missing <- setdiff(cols, names(df))
  if (length(missing) > 0) stop("Missing required Retrosheet plays columns: ", paste(missing, collapse = ", "))
  invisible(TRUE)
}

# -------- main conversion --------

retrosheet_plays_to_eic_v1 <- function(plays_df, output_dir, year = NULL, write_files = TRUE) {
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("Please install 'dplyr'.")
  if (!requireNamespace("tidyr", quietly = TRUE)) stop("Please install 'tidyr'.")

  needed <- c(
    "gid","date","inning","top_bot","batteam","score_v","score_h",
    "batter","pitcher","pitches",
    "outs_pre","outs_post","runs",
    "br1_pre","br2_pre","br3_pre",
    "event"
  )
  ensure_cols_exist(plays_df, needed)

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  df <- plays_df |>
    dplyr::mutate(
      gid = as.character(.data$gid),
      date = parse_date_any(.data$date), 
      inning = as.integer(.data$inning),
      top_bot = as.integer(.data$top_bot),
      game_num = 0L,

      Out_before   = as.integer(.data$outs_pre),
      outs_on_play = as.integer(.data$outs_post) - as.integer(.data$outs_pre),
      runs_on_play = as.integer(.data$runs),

      # occupancy: in plays files, br*_pre contains runner id if occupied else blank/NA :contentReference[oaicite:5]{index=5}
      on1 = !is.na(.data$br1_pre) & nzchar(trimws(as.character(.data$br1_pre))),
      on2 = !is.na(.data$br2_pre) & nzchar(trimws(as.character(.data$br2_pre))),
      on3 = !is.na(.data$br3_pre) & nzchar(trimws(as.character(.data$br3_pre))),

      mask_before = mask_from_bases(on1, on2, on3),
      RoB_raw     = rob_raw_from_mask(mask_before),

      Inn   = inn_label(.data$inning, .data$top_bot),
      `@Bat` = as.character(.data$batteam),
      BatTeam = as.character(.data$batteam),

      Batter  = as.character(.data$batter),
      Pitcher = as.character(.data$pitcher),

      PlayText = as.character(.data$event),
      `Play Description` = as.character(.data$event),

      `Pit(cnt)` = as.character(.data$pitches),
      Score = score_string(.data$score_v, .data$score_h),

      # display-only placeholders (engine doesn’t score on these)
      Out = NA_character_,
      RoB = NA_character_,
      `R/O` = NA_character_,
      matchup = NA_character_,

      # engine-computed fields must be 0/NA pre-engine
      BA_adj = 0,
      BAP_adj = 0,
      maxopp = 0,

      # optional fields
      wWPA = NA_real_,
      wWE  = NA_real_
    ) |>
    dplyr::select(
      # EIC-v1 required order (keep stable)
      source_file = gid,
      game_date   = date,
      game_num,
      
      Inn, `@Bat`, BatTeam,
      Out_before, RoB_raw, mask_before,
      outs_on_play, runs_on_play,
      
      BA_adj, BAP_adj, maxopp,
      
      Batter, Pitcher,
      PlayText, `Play Description`,
      Score, Out, RoB, `R/O`, `Pit(cnt)`, wWPA, wWE, matchup
    )

  # Normalize game_date + game_num from gid (authoritative)
  # (Retrosheet gid encodes date and game number) :contentReference[oaicite:6]{index=6}
  gid_info <- lapply(df$source_file, parse_gid)
  
  df$game_date <- as.Date(
    vapply(gid_info, function(x) {
      if (is.null(x$game_date) || is.na(x$game_date)) NA_character_ else format(x$game_date, "%Y-%m-%d")
    }, character(1)),
    format = "%Y-%m-%d"
  )
  
  df$game_num <- as.integer(vapply(gid_info, function(x) x$game_num, integer(1)))
  # Split to per-game files
  games <- split(df, df$source_file)

  if (!write_files) return(games)

  for (gid in names(games)) {
    gdf <- games[[gid]]

    # Retrosheet 'plays' includes a 'pn' play number field in some versions; if present, we’d sort by it.
    # Otherwise, the file is already in chronological order, and we preserve the existing ordering. :contentReference[oaicite:7]{index=7}

    out_path <- file.path(output_dir, paste0(gid, ".csv"))

    if (requireNamespace("readr", quietly = TRUE)) {
      readr::write_csv(gdf, out_path)
    } else {
      utils::write.csv(gdf, out_path, row.names = FALSE, quote = TRUE)
    }
  }

  invisible(TRUE)
}