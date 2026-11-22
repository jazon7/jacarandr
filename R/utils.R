# Internal helpers: input validation and conditions --------------------------
#
# All user-facing errors go through `jac_abort()` so they share the class
# "jacarandr_error". Callers can catch them programmatically and tests can
# check the class instead of matching fragile message text.

#' Signal a classed jacarandr error
#'
#' @param ... Message pieces, pasted together with no separator.
#' @param class Optional subclass, added in front of `"jacarandr_error"`.
#' @noRd
jac_abort <- function(..., class = NULL) {
  msg <- paste0(...)
  cond <- structure(
    class = c(class, "jacarandr_error", "error", "condition"),
    list(message = msg, call = NULL)
  )
  stop(cond)
}

#' Names of all available palettes
#' @noRd
jac_palette_names <- function() {
  names(jac_palettes)
}

#' Validate a palette name and return its definition
#'
#' Matching is exact (no partial matching), so a typo produces an
#' informative error rather than silently picking another palette.
#'
#' @param palette A single palette name.
#' @param allowed_types Palette types accepted by the caller.
#' @param hint Extra advice appended to the error when the type is wrong.
#' @return The palette's list entry from `jac_palettes`.
#' @noRd
check_palette <- function(palette,
                          allowed_types = c("discrete", "sequential",
                                            "diverging"),
                          hint = NULL) {
  valid <- jac_palette_names()
  if (!is.character(palette) || length(palette) != 1L || is.na(palette)) {
    jac_abort(
      "`palette` must be a single string, one of: ",
      paste0('"', valid, '"', collapse = ", "), ".",
      class = "jacarandr_error_palette"
    )
  }
  if (!palette %in% valid) {
    jac_abort(
      'Unknown palette "', palette, '". Available palettes are: ',
      paste0('"', valid, '"', collapse = ", "), ".",
      class = "jacarandr_error_palette"
    )
  }
  pal <- jac_palettes[[palette]]
  if (!pal$type %in% allowed_types) {
    ok <- valid[vapply(jac_palettes, function(p) p$type %in% allowed_types,
                       logical(1))]
    jac_abort(
      'Palette "', palette, '" is ', pal$type, ", but only ",
      paste0('"', ok, '"', collapse = ", "), " can be used here.",
      if (!is.null(hint)) paste0(" ", hint),
      class = "jacarandr_error_palette"
    )
  }
  pal
}

#' Validate `n`: NULL, or a single non-negative whole number
#' @noRd
check_n <- function(n) {
  if (is.null(n)) {
    return(invisible(NULL))
  }
  ok <- is.numeric(n) && length(n) == 1L && !is.na(n) && is.finite(n) &&
    n >= 0 && n == round(n)
  if (!ok) {
    jac_abort(
      "`n` must be NULL or a single non-negative whole number.",
      class = "jacarandr_error_n"
    )
  }
  invisible(NULL)
}

#' Validate a single TRUE/FALSE argument
#' @param x Value to check.
#' @param arg Argument name used in the error message.
#' @noRd
check_flag <- function(x, arg) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    jac_abort("`", arg, "` must be TRUE or FALSE.",
              class = "jacarandr_error_flag")
  }
  invisible(NULL)
}

#' Is ggplot2 available?
#'
#' A thin wrapper so tests can simulate ggplot2 being absent with
#' `testthat::local_mocked_bindings()`.
#' @noRd
is_ggplot2_installed <- function() {
  requireNamespace("ggplot2", quietly = TRUE)
}

#' Stop with install advice if ggplot2 is missing
#'
#' ggplot2 is in Suggests, not Imports, so users who only need the colours
#' do not have to install it. The scale functions call this first.
#' @param fn Name of the calling function, for the message.
#' @noRd
check_ggplot2 <- function(fn) {
  if (!is_ggplot2_installed()) {
    jac_abort(
      "`", fn, "()` needs the 'ggplot2' package. ",
      'Install it with install.packages("ggplot2").',
      class = "jacarandr_error_ggplot2"
    )
  }
  invisible(NULL)
}

#' Interpolate `n` colours evenly along a palette in CIELAB space
#'
#' CIELAB is closer to perceptually uniform than sRGB, so evenly spaced
#' positions give colours that look evenly spaced. Positions that fall exactly
#' on an anchor return that anchor's hex code unchanged. Without this, the
#' sRGB to Lab to sRGB round trip can shift an anchor by one unit (as
#' `grDevices::colorRampPalette()` does), so `jac_pal("seq", n)` would not
#' start and end on the documented colours.
#'
#' @param colours Anchor colours as hex codes, in order.
#' @param n Number of colours wanted (a non-negative whole number).
#' @return Character vector of `n` upper-case hex codes.
#' @noRd
interpolate_lab <- function(colours, n) {
  if (n == 0) {
    return(character(0))
  }
  k <- length(colours)
  # Anchor i sits at position i - 1 on a 0 to (k - 1) axis.
  at <- if (n == 1) 0 else seq(0, k - 1, length.out = n)

  lab <- grDevices::convertColor(t(grDevices::col2rgb(colours)) / 255,
                                 from = "sRGB", to = "Lab")
  out_lab <- vapply(seq_len(3), function(j) {
    stats::approx(seq_len(k) - 1, lab[, j], xout = at)$y
  }, numeric(n))
  out_lab <- matrix(out_lab, nrow = n) # keep a matrix when n == 1

  rgb <- grDevices::convertColor(out_lab, from = "Lab", to = "sRGB")
  rgb <- pmin(pmax(rgb, 0), 1) # clip any slightly out-of-gamut values
  out <- grDevices::rgb(rgb[, 1], rgb[, 2], rgb[, 3])

  # Snap positions within floating point error of an anchor to it exactly.
  on_anchor <- abs(at - round(at)) < 1e-8
  out[on_anchor] <- toupper(colours[round(at[on_anchor]) + 1])
  out
}
