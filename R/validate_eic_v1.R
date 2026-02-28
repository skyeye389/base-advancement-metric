# R/validate_eic_v1.R

validate_eic_v1 <- function(df, strict_types = FALSE) {
  # df: data.frame / tibble representing ONE GAME (recommended)
  # strict_types: if TRUE, enforce numeric/integer typing strictly; if FALSE, coerce safely

  required_cols <- c(
    "source_file","game_date","game_num","Inn","@Bat","BatTeam",
    "Out_before","RoB_raw","mask_before","outs_on_play","runs_on_play",
    "BA_adj","BAP_adj","maxopp",
    "Batter","Pitcher","PlayText","Play Description",
    "Score","Out","RoB","R/O","Pit(cnt)","wWPA","wWE","matchup"
  )

  # ---- helpers ----
  stopf <- function(...) stop(sprintf(...), call. = FALSE)

  assert_cols_present <- function() {
    missing <- setdiff(required_cols, names(df))
    if (length(missing) > 0) {
      stopf("EIC-v1 schema violation: missing columns: %s", paste(missing, collapse = ", "))
    }
  }

  safe_as_int <- function(x, col) {
    if (is.integer(x)) return(x)
    if (!is.numeric(x)) {
      # try coercion
      x2 <- suppressWarnings(as.integer(x))
      if (any(is.na(x2) & !is.na(x))) stopf("Column %s cannot be coerced to integer cleanly.", col)
      return(x2)
    }
    # numeric -> integer if whole-number
    if (any(!is.na(x) & abs(x - round(x)) > 1e-9)) stopf("Column %s has non-integer numeric values.", col)
    as.integer(round(x))
  }

  safe_as_num <- function(x, col) {
    if (is.numeric(x)) return(as.numeric(x))
    x2 <- suppressWarnings(as.numeric(x))
    if (any(is.na(x2) & !is.na(x))) stopf("Column %s cannot be coerced to numeric cleanly.", col)
    x2
  }

  assert_domain <- function(x, col, min = NULL, max = NULL, allowed = NULL, pattern = NULL) {
    if (!is.null(allowed)) {
      bad <- which(!is.na(x) & !(x %in% allowed))
      if (length(bad) > 0) stopf("Domain violation in %s: found disallowed value(s): %s",
                                 col, paste(unique(x[bad]), collapse = ", "))
    }
    if (!is.null(pattern)) {
      bad <- which(!is.na(x) & !grepl(pattern, x))
      if (length(bad) > 0) stopf("Domain violation in %s: values do not match pattern %s", col, pattern)
    }
    if (!is.null(min)) {
      bad <- which(!is.na(x) & x < min)
      if (length(bad) > 0) stopf("Domain violation in %s: values below %s", col, min)
    }
    if (!is.null(max)) {
      bad <- which(!is.na(x) & x > max)
      if (length(bad) > 0) stopf("Domain violation in %s: values above %s", col, max)
    }
  }

  # ---- 1) Schema presence ----
  assert_cols_present()

  # ---- 2) Type / coercion (Arrow-like) ----
  # game_date should be Date (or coercible)
  if (!inherits(df$game_date, "Date")) {
    gd <- suppressWarnings(as.Date(df$game_date))
    if (any(is.na(gd) & !is.na(df$game_date))) stopf("game_date not parseable as Date (YYYY-MM-DD).")
    if (strict_types) stopf("game_date must be Date class when strict_types=TRUE.")
    df$game_date <- gd
  }

  # integers
  int_cols <- c("game_num","Out_before","mask_before","outs_on_play","runs_on_play","maxopp")
  for (cc in int_cols) {
    if (strict_types && !is.integer(df[[cc]])) stopf("%s must be integer when strict_types=TRUE.", cc)
    df[[cc]] <- safe_as_int(df[[cc]], cc)
  }

  # numerics (engine-computed fields may be NA)
  num_cols <- c("BA_adj","BAP_adj","wWPA","wWE")
  for (cc in num_cols) {
    if (strict_types && !(is.numeric(df[[cc]]) || all(is.na(df[[cc]])))) stopf("%s must be numeric/NA when strict_types=TRUE.", cc)
    df[[cc]] <- safe_as_num(df[[cc]], cc)
  }

  # ---- 3) Domain checks ----
  assert_domain(df$Inn, "Inn", pattern = "^[tb][1-9][0-9]?$")
  assert_domain(df$RoB_raw, "RoB_raw", allowed = c("---","1--","-2-","--3","12-","1-3","-23","123"))
  assert_domain(df$mask_before, "mask_before", min = 0, max = 7)
  assert_domain(df$Out_before, "Out_before", min = 0, max = 2)
  assert_domain(df$outs_on_play, "outs_on_play", min = 0, max = 3)
  assert_domain(df$runs_on_play, "runs_on_play", min = 0, max = 4)

  # BatTeam == @Bat
  bad_bt <- which(!is.na(df$BatTeam) & !is.na(df[["@Bat"]]) & df$BatTeam != df[["@Bat"]])
  if (length(bad_bt) > 0) stopf("Equality constraint violation: BatTeam != @Bat on %d row(s).", length(bad_bt))

  # ---- 4) Base mask mapping invariant ----
  mask_map <- c("---"=0L, "1--"=1L, "-2-"=2L, "--3"=4L, "12-"=3L, "1-3"=5L, "-23"=6L, "123"=7L)
  expected_mask <- unname(mask_map[df$RoB_raw])
  bad_mask <- which(!is.na(expected_mask) & df$mask_before != expected_mask)
  if (length(bad_mask) > 0) {
    stopf("Base mask invariant violation: mask_before does not match RoB_raw on %d row(s).", length(bad_mask))
  }

  # ---- 5) Outs arithmetic invariant ----
  bad_outs <- which(df$Out_before + df$outs_on_play > 3)
  if (length(bad_outs) > 0) {
    stopf("Outs invariant violation: Out_before + outs_on_play > 3 on %d row(s).", length(bad_outs))
  }

  # ---- 6) Ordering / half-inning invariants ----
  # We recommend df is already a single-game file and already in order.
  # Validate Out_before monotonicity within a half-inning and resets between half-innings.
  inn <- df$Inn
  outb <- df$Out_before

  # detect half-inning boundaries
  boundary <- c(TRUE, inn[-1] != inn[-length(inn)])

  # resets on new half-inning (Out_before must be 0 when Inn changes)
  bad_reset <- which(boundary & outb != 0)
  if (length(bad_reset) > 0) {
    stopf("Half-inning reset violation: Out_before != 0 at start of new Inn on %d row(s).", length(bad_reset))
  }

  # monotonic within half-inning
  # for each segment, Out_before must be non-decreasing
  for (i in seq_along(inn)) {
    if (i == 1) next
    if (inn[i] == inn[i-1] && outb[i] < outb[i-1]) {
      stopf("Ordering violation: Out_before decreases within Inn=%s at row %d (%d -> %d).",
            inn[i], i, outb[i-1], outb[i])
    }
  }

  # ---- 7) Engine isolation: BA_adj, BAP_adj, maxopp must be 0 or NA pre-engine ----
  must_zero_or_na <- function(x, col) {
    bad <- which(!is.na(x) & abs(x) > 1e-12)
    if (length(bad) > 0) stopf("Engine isolation violation: %s must be 0 or NA pre-engine; found non-zero.", col)
  }
  must_zero_or_na(df$BA_adj, "BA_adj")
  must_zero_or_na(df$BAP_adj, "BAP_adj")
  # maxopp integer
  bad_maxopp <- which(!is.na(df$maxopp) & df$maxopp != 0L)
  if (length(bad_maxopp) > 0) stopf("Engine isolation violation: maxopp must be 0 or NA pre-engine; found non-zero.")

  # If we get here, the table is EIC-v1 compliant.
  invisible(TRUE)
}