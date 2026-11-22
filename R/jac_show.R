#' Preview jacarandr palettes
#'
#' Draws colour swatches with base R graphics, so no extra packages are
#' needed. Called with no arguments it shows every palette; give a `palette`
#' to see that palette's swatches labelled with their names and hex codes.
#'
#' @inheritParams jac_pal
#' @param palette Name of the palette to show, or `NULL` (the default) for an
#'   overview of all palettes. See [jac_pal()] for the available palettes.
#' @param n Number of colours to show, passed to [jac_pal()]. It can only be
#'   used when `palette` is given.
#' @param labels If `TRUE` (the default), each swatch is labelled with its hex
#'   code and, for discrete palettes, its name. Labels are left out when more
#'   than 16 swatches are shown, because they would overlap.
#'
#' @return Invisibly, the colours that were drawn: a character vector for a
#'   single palette, or a named list of character vectors for the overview.
#'   The function is called for its side effect of drawing a plot.
#'
#' @seealso [jac_pal()] to get the colours themselves.
#' @export
#' @examples
#' # All palettes at a glance
#' jac_show()
#'
#' # One palette, labelled
#' jac_show("main")
#' jac_show("main", n = 4, reverse = TRUE)
#' jac_show("seq", n = 9)
jac_show <- function(palette = NULL, n = NULL, reverse = FALSE,
                     labels = TRUE) {
  check_flag(reverse, "reverse")
  check_flag(labels, "labels")

  if (is.null(palette)) {
    if (!is.null(n)) {
      jac_abort("`n` can only be used when `palette` is given.",
                class = "jacarandr_error_n")
    }
    return(invisible(show_overview(reverse)))
  }

  colours <- jac_pal(palette, n = n, reverse = reverse)
  if (length(colours) == 0L) {
    jac_abort("There are no colours to show (n = 0).",
              class = "jacarandr_error_n")
  }

  # Discrete palettes carry names; recover them in the order drawn.
  swatch_names <- NULL
  if (jac_palettes[[palette]]$type == "discrete") {
    all_names <- names(jac_palettes[[palette]]$colours)
    swatch_names <- all_names[match(colours, jac_palettes[[palette]]$colours)]
  }

  old_par <- graphics::par(mar = c(0.5, 0.5, 2, 0.5))
  on.exit(graphics::par(old_par), add = TRUE)

  k <- length(colours)
  graphics::plot.new()
  graphics::plot.window(xlim = c(0, k), ylim = c(0, 1), xaxs = "i",
                        yaxs = "i")
  graphics::rect(seq_len(k) - 1, 0, seq_len(k), 1, col = colours,
                 border = NA)
  graphics::title(main = paste0('jacarandr "', palette, '"',
                                if (reverse) " (reversed)"))

  if (labels && k <= 16L) {
    ink <- label_ink(colours)
    x <- seq_len(k) - 0.5
    label_names <- if (!is.null(swatch_names)) gsub("_", " ", swatch_names)
    # Shrink the text if needed so the widest label fits inside its swatch
    # (one user unit wide) on any device size, keeping a small margin.
    widest <- max(graphics::strwidth(c(colours, label_names), cex = 1,
                                     font = 2))
    cex <- min(if (k > 8L) 0.6 else 0.8, 0.9 / widest)
    graphics::text(x, 0.45, colours, col = ink, cex = cex)
    if (!is.null(label_names)) {
      graphics::text(x, 0.58, label_names, col = ink, cex = cex, font = 2)
    }
  }

  invisible(colours)
}

#' Draw every palette as one row each
#' @param reverse Passed to `jac_pal()`.
#' @return Named list of the colours drawn.
#' @noRd
show_overview <- function(reverse) {
  pal_names <- jac_palette_names()
  # Continuous palettes are drawn as a smooth 64-step ramp so the gradient
  # itself is visible, discrete palettes as their individual colours.
  rows <- lapply(pal_names, function(p) {
    n <- if (jac_palettes[[p]]$type == "discrete") NULL else 64L
    jac_pal(p, n = n, reverse = reverse)
  })
  names(rows) <- pal_names

  old_par <- graphics::par(mar = c(0.5, 4, 2, 0.5))
  on.exit(graphics::par(old_par), add = TRUE)

  m <- length(rows)
  graphics::plot.new()
  graphics::plot.window(xlim = c(0, 1), ylim = c(0, m), xaxs = "i",
                        yaxs = "i")
  for (i in seq_len(m)) {
    cols <- rows[[i]]
    k <- length(cols)
    y <- m - i # first palette at the top
    edges <- seq(0, 1, length.out = k + 1L)
    graphics::rect(edges[-(k + 1L)], y + 0.1, edges[-1L], y + 0.9,
                   col = cols, border = NA)
  }
  graphics::axis(2, at = rev(seq_len(m)) - 0.5, labels = pal_names,
                 las = 1, tick = FALSE, line = -0.5)
  graphics::title(main = paste0("jacarandr palettes",
                                if (reverse) " (reversed)"))
  rows
}

#' Pick black or white text for legibility on each background colour
#'
#' Uses WCAG relative luminance: backgrounds lighter than the threshold get
#' near-black text, darker ones get white.
#' @param colours Background colours.
#' @return Character vector of text colours, the same length as `colours`.
#' @noRd
label_ink <- function(colours) {
  rgb <- grDevices::col2rgb(colours) / 255
  lin <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  luminance <- 0.2126 * lin[1, ] + 0.7152 * lin[2, ] + 0.0722 * lin[3, ]
  # 0.179 is where contrast against black equals contrast against white.
  ifelse(luminance > 0.179, "#1A1A1A", "#FFFFFF")
}
