#' Get colours from a jacarandr palette
#'
#' `jac_pal()` is the main way to get colours from jacarandr, for any plotting
#' system. It returns a plain character vector of hex codes.
#'
#' @section Palettes:
#' * `"main"` (discrete, 8 colours): jacaranda, gum leaf, flame tree,
#'   wattle, blue gum, red cedar, paperbark and twilight. The colours are
#'   ordered so that the first `n` are always a good choice: the first three
#'   are the most distinct, and every pair stays distinguishable under
#'   simulated red-green and blue-yellow colour vision deficiency.
#' * `"light"` (discrete, 8 colours): softer versions of `"main"` with the same
#'   names and order, for large filled areas, backgrounds or pairing with
#'   `"main"`.
#' * `"seq"` (sequential): pale petal through jacaranda to deep violet, for
#'   ordered or continuous data.
#' * `"div"` (diverging): jacaranda violet through a near-neutral centre to
#'   gum leaf green, for data with a meaningful midpoint such as zero.
#'
#' Use [jac_show()] to see them.
#'
#' @param palette Name of the palette: `"main"` (the default), `"light"`,
#'   `"seq"` or `"div"`. See the Palettes section.
#' @param n Number of colours to return, or `NULL` (the default) for all of
#'   the palette's defined colours.
#'   * For the discrete palettes (`"main"`, `"light"`), the first `n` colours
#'     are returned. Asking for more than 8 is an error, because more
#'     categorical colours than that cannot be told apart reliably.
#'   * For the continuous palettes (`"seq"`, `"div"`), `n` colours are
#'     interpolated evenly along the palette in CIELAB space, so any `n` works.
#' @param reverse If `TRUE`, reverse the palette.
#'   * For discrete palettes, the first `n` colours are chosen and then
#'     reversed, so `reverse` changes the order but not which colours you get.
#'   * For continuous palettes, the palette runs the other way (dark to light
#'     for `"seq"`) before the `n` colours are taken from it.
#'
#' @return An unnamed character vector of `n` hex colour codes. It is unnamed
#'   on purpose: named colours passed to `ggplot2::scale_fill_manual()` are
#'   matched to data values by name, which is rarely what you want. For named
#'   colours use [jac_colours()].
#'
#' @seealso [jac_colours()] to pick single colours by name, [jac_show()] to
#'   preview palettes, and [scale_colour_jac_d()] and [scale_colour_jac_c()]
#'   for 'ggplot2' scales.
#' @export
#' @examples
#' # The full main palette
#' jac_pal()
#'
#' # The three most distinct colours, and the same three reversed
#' jac_pal(n = 3)
#' jac_pal(n = 3, reverse = TRUE)
#'
#' # Any number of colours from the continuous palettes
#' jac_pal("seq", n = 10)
#' jac_pal("div", n = 5)
#'
#' # Base R graphics
#' barplot(1:5, col = jac_pal(n = 5))
#' image(volcano, col = jac_pal("seq", n = 50, reverse = TRUE))
jac_pal <- function(palette = "main", n = NULL, reverse = FALSE) {
  pal <- check_palette(palette)
  check_n(n)
  check_flag(reverse, "reverse")

  colours <- unname(pal$colours)
  continuous <- pal$type != "discrete"

  # Continuous palettes are reversed before interpolation, so that the
  # direction of the palette changes (this matters for n = 1). Discrete
  # palettes are reversed after subsetting, keeping the same n colours.
  if (continuous && reverse) {
    colours <- rev(colours)
  }

  if (!is.null(n)) {
    if (!continuous) {
      if (n > length(colours)) {
        jac_abort(
          'Palette "', palette, '" has ', length(colours), " colours, but ",
          "n = ", n, " were requested. More than ", length(colours),
          " categorical colours are hard to tell apart; consider grouping ",
          'categories, or use the "seq" palette for ordered categories.',
          class = "jacarandr_error_too_many"
        )
      }
      colours <- colours[seq_len(n)]
    } else {
      colours <- interpolate_lab(colours, n)
    }
  }

  if (!continuous && reverse) rev(colours) else colours
}

#' Get named jacarandr colours
#'
#' Returns colours from a discrete palette by name, which is handy for
#' highlighting, annotation, or setting a single colour such as
#' `geom_line(colour = jac_colours("jacaranda"))`.
#'
#' The names are `jacaranda`, `gum_leaf`, `flame_tree`, `wattle`, `blue_gum`,
#' `red_cedar`, `paperbark` and `twilight`, and both discrete palettes use
#' them.
#'
#' @param ... Colour names as character strings. If none are given, every
#'   colour in the palette is returned.
#' @param palette A discrete palette: `"main"` (the default) or `"light"`.
#'
#' @return A named character vector of hex colour codes, in the order
#'   requested.
#'
#' @seealso [jac_pal()] for an unnamed vector of `n` colours.
#' @export
#' @examples
#' jac_colours()
#' jac_colours("jacaranda", "flame_tree")
#' jac_colours("jacaranda", palette = "light")
#'
#' # Highlight one bar in base graphics
#' barplot(c(3, 5, 2), col = jac_colours("paperbark", "jacaranda", "paperbark"))
jac_colours <- function(..., palette = "main") {
  pal <- check_palette(
    palette,
    allowed_types = "discrete",
    hint = "Use jac_pal() for the continuous palettes."
  )
  wanted <- c(...)
  if (is.null(wanted)) {
    return(pal$colours)
  }
  if (!is.character(wanted) || anyNA(wanted)) {
    jac_abort("Colour names in `...` must be character strings.",
              class = "jacarandr_error_colour_name")
  }
  unknown <- setdiff(wanted, names(pal$colours))
  if (length(unknown) > 0L) {
    jac_abort(
      "Unknown colour name", if (length(unknown) > 1L) "s", ": ",
      paste0('"', unknown, '"', collapse = ", "), ". Available names are: ",
      paste0('"', names(pal$colours), '"', collapse = ", "), ".",
      class = "jacarandr_error_colour_name"
    )
  }
  pal$colours[wanted]
}

#' @rdname jac_colours
#' @export
jac_colors <- jac_colours
