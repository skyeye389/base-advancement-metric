# engine_BA_BAP_v1.0.R
#time_stamp: 2_26_26
# v1.0 FROZEN: scoring + filters locked

run_engine <- function(
  input_dir,
  output_dir = file.path(input_dir, "processed_output"),
  write_per_game = FALSE,
  overwrite_outputs = FALSE
) {

  # --- guards ---
  if (!dir.exists(input_dir)) stop("input_dir does not exist: ", input_dir)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  stopifnot(dir.exists(output_dir))

  # --- your existing file discovery ---
  files <- list.files(input_dir, pattern = "\\.(xls|xlsx)$", full.names = TRUE, recursive = TRUE)
  if (length(files) == 0) stop("No .xls/.xlsx files found under: ", input_dir)

  # --- your existing functions: read_game_table(), parse_filename_meta(), find_col(), etc. ---
  # (Paste them here unchanged from v1.0)

  # --- process_game (keep your v1.0 version) ---
  # (Paste unchanged; keep raw %>% mutate(across(everything(), as.character)))

  # --- run ---
  all_games <- purrr::map_dfr(files, process_game)

  # summary-safe dataset
  pa_clean <- all_games %>%
    dplyr::filter(
      !is.na(Inn),
      stringr::str_detect(Inn, "^[tb][0-9]+$"),
      !is.na(BatTeam), !is.na(Batter),
      BatTeam != "", Batter != "",
      !stringr::str_detect(BatTeam, "Top of|Bottom of|Batting|facing"),
      !stringr::str_detect(Batter, "Top of|Bottom of|Batting|facing")
    )

  # --- outputs ---
  stamp <- format(Sys.time(), "%Y%m%d_%H%M%S")

  combined_out <- file.path(output_dir, if (overwrite_outputs) "all_games_combined.csv" else paste0("all_games_combined_", stamp, ".csv"))
  leader_out   <- file.path(output_dir, if (overwrite_outputs) "leaderboard.csv"       else paste0("leaderboard_", stamp, ".csv"))
  pitcher_out  <- file.path(output_dir, if (overwrite_outputs) "pitcher_BAP_leaderboard.csv" else paste0("pitcher_BAP_leaderboard_", stamp, ".csv"))
  series_out   <- file.path(output_dir, if (overwrite_outputs) "series_summary.csv"    else paste0("series_summary_", stamp, ".csv"))

  readr::write_csv(all_games, combined_out)

  batter_leaderboard <- pa_clean %>%
    dplyr::group_by(BatTeam, Batter) %>%
    dplyr::summarise(
      PA = dplyr::n(),
      BA = sum(BA_adj, na.rm = TRUE),
      MaxOpp = sum(maxopp, na.rm = TRUE),
      BA_per_MaxOpp = dplyr::if_else(MaxOpp > 0, BA / MaxOpp, 0),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(BA_per_MaxOpp), dplyr::desc(BA))

  readr::write_csv(batter_leaderboard, leader_out)

  pitcher_bap <- all_games %>%
    dplyr::filter(
      !is.na(Pitcher),
      Pitcher != "",
      !stringr::str_detect(Pitcher, "Batting|facing|Top of|Bottom of")
    ) %>%
    dplyr::group_by(Pitcher) %>%
    dplyr::summarise(
      BFP = dplyr::n(),
      BAP = sum(BAP_adj, na.rm = TRUE),
      MaxOpp = sum(maxopp, na.rm = TRUE),
      BAP_per_BFP = BAP / BFP,
      BAP_per_MaxOpp = dplyr::if_else(MaxOpp > 0, BAP / MaxOpp, 0),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(BAP_per_MaxOpp), dplyr::desc(BAP))

  readr::write_csv(pitcher_bap, pitcher_out)

  series_summary <- pa_clean %>%
    dplyr::group_by(source_file, BatTeam) %>%
    dplyr::summarise(
      team_PA     = dplyr::n(),
      team_BA     = sum(BA_adj, na.rm = TRUE),
      team_MaxOpp = sum(maxopp, na.rm = TRUE),
      top3        = fmt_top3(dplyr::pick(dplyr::everything())),
      .groups = "drop"
    ) %>%
    dplyr::mutate(top3 = dplyr::coalesce(top3, "")) %>%
    tidyr::pivot_wider(
      names_from  = BatTeam,
      values_from = c(team_PA, team_BA, team_MaxOpp, top3)
    ) %>%
    dplyr::mutate(
      dplyr::across(where(is.numeric), ~ tidyr::replace_na(.x, 0)),
      dplyr::across(where(is.character), ~ tidyr::replace_na(.x, ""))
    )

  readr::write_csv(series_summary, series_out)

  # optional per-game
  if (isTRUE(write_per_game)) {
    split(all_games, all_games$source_file) %>%
      purrr::imap(~{
        out_name <- paste0(tools::file_path_sans_ext(.y), "_processed_", stamp, ".csv")
        readr::write_csv(.x, file.path(output_dir, out_name))
      })
  }

  invisible(list(
    combined_out = combined_out,
    leader_out   = leader_out,
    pitcher_out  = pitcher_out,
    series_out   = series_out
  ))
}