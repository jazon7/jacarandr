#' Discrete jacarandr scales for ggplot2
#'
#' Colour and fill scales for discrete data such as groups in bar charts,
#' points or lines. They use the `"main"` palette by default.
#'
#' The continuous palettes `"seq"` and `"div"` can also be used here. They
#' suit ordered categories (for example `"low"`, `"medium"`, `"high"`), and
#' can supply any number of levels.
#'
#' A discrete palette (`"main"` or `"light"`) has 8 colours. If the data has
#' more than 8 levels, the plot fails with an error when it is drawn rather
#' than quietly reusing or inventing colours.
#'
#' These functions need the 'ggplot2' package, which jacarandr suggests but
#' does not require.
#'
#' @inheritParams jac_pal
#' @param ... Other arguments passed on to [ggplot2::discrete_scale()], such
#'   as `name`, `labels`, `breaks`, `na.value` or `guide`.
#' @param aesthetics The aesthetics this scale works with. Defaults to
#'   `"colour"` or `"fill"` to match the function name. Use
#'   `c("colour", "fill")` to style both with one scale.
#'
#' @return A ggplot2 discrete scale object to add to a plot with `+`.
#'
#' @seealso [scale_colour_jac_c()] for continuous data, [jac_pal()] for the
#'   palettes themselves.
#' @export
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' library(ggplot2)
#'
#' ggplot(mpg, aes(class, fill = drv)) +
#'   geom_bar() +
#'   scale_fill_jac_d()
#'
#' # Reversed order
#' ggplot(mpg, aes(class, fill = drv)) +
#'   geom_bar() +
#'   scale_fill_jac_d(reverse = TRUE)
#'
#' # The light palette for large filled areas, main colours for outlines
#' ggplot(mpg, aes(displ, hwy, colour = drv, fill = drv)) +
#'   geom_point(shape = 21, size = 3) +
#'   scale_fill_jac_d(palette = "light") +
#'   scale_colour_jac_d()
#'
#' # The sequential palette for ordered categories
#' ggplot(diamonds, aes(cut, fill = cut)) +
#'   geom_bar() +
#'   scale_fill_jac_d(palette = "seq")
scale_colour_jac_d <- function(palette = "main", reverse = FALSE, ...,
                               aesthetics = "colour") {
  check_ggplot2("scale_colour_jac_d")
  ggplot2::discrete_scale(
    aesthetics = aesthetics,
    palette = jac_discrete_palette(palette, reverse),
    ...
  )
}

#' @rdname scale_colour_jac_d
#' @export
scale_color_jac_d <- scale_colour_jac_d

#' @rdname scale_colour_jac_d
#' @export
scale_fill_jac_d <- function(palette = "main", reverse = FALSE, ...,
                             aesthetics = "fill") {
  check_ggplot2("scale_fill_jac_d")
  ggplot2::discrete_scale(
    aesthetics = aesthetics,
    palette = jac_discrete_palette(palette, reverse),
    ...
  )
}

#' Continuous jacarandr scales for ggplot2
#'
#' Colour and fill gradients for continuous data, built on
#' [ggplot2::scale_colour_gradientn()]. They use the sequential `"seq"`
#' palette (light to dark jacaranda) by default. Use `palette = "div"` for
#' data with a meaningful centre, and set `midpoint` to that centre.
#'
#' These functions need the 'ggplot2' package, which jacarandr suggests but
#' does not require.
#'
#' @param palette A continuous palette: `"seq"` (the default) or `"div"`.
#' @param reverse If `TRUE`, the gradient runs the other way: for `"seq"`,
#'   low values become dark and high values light.
#' @param midpoint For diverging data, the data value that should get the
#'   palette's neutral centre colour, usually `0`. If `NULL` (the default),
#'   the centre colour goes to the middle of the data range, as with any
#'   gradient. With a midpoint, the scale extends equally on both sides of it,
#'   so the colour at a given distance from the midpoint is the same whichever
#'   side it falls on.
#' @param ... Other arguments passed on to
#'   [ggplot2::scale_colour_gradientn()], such as `name`, `limits`, `breaks`,
#'   `labels`, `na.value` or `guide`.
#' @param aesthetics The aesthetics this scale works with. Defaults to
#'   `"colour"` or `"fill"` to match the function name.
#'
#' @return A ggplot2 continuous scale object to add to a plot with `+`.
#'
#' @seealso [scale_colour_jac_d()] for discrete data, [jac_pal()] for the
#'   palettes themselves.
#' @export
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' library(ggplot2)
#'
#' p <- ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
#'   geom_raster()
#'
#' p + scale_fill_jac_c()
#' p + scale_fill_jac_c(reverse = TRUE)
#'
#' # Diverging data centred on zero
#' df <- expand.grid(x = 1:20, y = 1:20)
#' df$z <- with(df, sin(x / 3) * cos(y / 4))
#' ggplot(df, aes(x, y, fill = z)) +
#'   geom_tile() +
#'   scale_fill_jac_c(palette = "div", midpoint = 0)
scale_colour_jac_c <- function(palette = "seq", reverse = FALSE,
                               midpoint = NULL, ..., aesthetics = "colour") {
  check_ggplot2("scale_colour_jac_c")
  jac_continuous_scale(palette, reverse, midpoint, aesthetics, ...)
}

#' @rdname scale_colour_jac_c
#' @export
scale_color_jac_c <- scale_colour_jac_c

#' @rdname scale_colour_jac_c
#' @export
scale_fill_jac_c <- function(palette = "seq", reverse = FALSE,
                             midpoint = NULL, ..., aesthetics = "fill") {
  check_ggplot2("scale_fill_jac_c")
  jac_continuous_scale(palette, reverse, midpoint, aesthetics, ...)
}

# Internal scale builders ----------------------------------------------------

#' Build the palette function a discrete scale calls with the number of levels
#'
#' Arguments are validated now, when the scale is created, so mistakes such as
#' a misspelt palette are reported where the user wrote them, not later when
#' the plot is drawn. Only the "too many levels" check has to wait until the
#' data is known.
#' @noRd
jac_discrete_palette <- function(palette, reverse) {
  check_palette(palette)
  check_flag(reverse, "reverse")
  function(n) jac_pal(palette, n = n, reverse = reverse)
}

#' Shared implementation of the continuous colour and fill scales
#' @noRd
jac_continuous_scale <- function(palette, reverse, midpoint, aesthetics,
                                 ...) {
  check_palette(
    palette,
    allowed_types = c("sequential", "diverging"),
    hint = "Use scale_colour_jac_d() or scale_fill_jac_d() for discrete data."
  )
  check_flag(reverse, "reverse")
  if (!is.null(midpoint) &&
        (!is.numeric(midpoint) || length(midpoint) != 1L ||
           !is.finite(midpoint))) {
    jac_abort("`midpoint` must be NULL or a single finite number.",
              class = "jacarandr_error_midpoint")
  }

  colours <- jac_pal(palette, reverse = reverse)
  args <- list(colours = colours, aesthetics = aesthetics, ...)
  if (!is.null(midpoint)) {
    args$rescaler <- rescale_around(midpoint)
  }
  do.call(ggplot2::scale_colour_gradientn, args)
}

#' A rescaler that places `mid` at the centre of the output range
#'
#' Behaves like `scales::rescale_mid()`, written out here so jacarandr does
#' not need the 'scales' package. The signature matches what
#' `ggplot2::continuous_scale()` expects of its `rescaler` argument.
#' @param mid The data value to map to the middle of `to`.
#' @noRd
rescale_around <- function(mid) {
  force(mid)
  function(x, to = c(0, 1), from = range(x, na.rm = TRUE)) {
    extent <- 2 * max(abs(from - mid))
    if (!is.finite(extent) || extent == 0) {
      # Every value equals the midpoint: put them all at the centre.
      return(ifelse(is.na(x), NA_real_, mean(to)))
    }
    (x - mid) / extent * diff(to) + mean(to)
  }
}
