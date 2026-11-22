# ggplot2 is only suggested, so every test here that builds a plot first
# checks that it is installed.

# The fill colours ggplot2 actually rendered for the first layer.
built_fill <- function(plot) {
  ggplot2::ggplot_build(plot)$data[[1]]$fill
}

# Discrete scales ------------------------------------------------------------

test_that("discrete scales are ggplot2 discrete scales on the right aesthetic", {
  skip_if_not_installed("ggplot2")
  expect_s3_class(scale_colour_jac_d(), "ScaleDiscrete")
  expect_s3_class(scale_fill_jac_d(), "ScaleDiscrete")
  expect_identical(scale_colour_jac_d()$aesthetics, "colour")
  expect_identical(scale_fill_jac_d()$aesthetics, "fill")
  expect_identical(
    scale_fill_jac_d(aesthetics = c("colour", "fill"))$aesthetics,
    c("colour", "fill")
  )
})

test_that("discrete scales map levels to the first n palette colours", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = c("a", "b", "c"), y = 1:3)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = x)) +
    ggplot2::geom_col()

  expect_identical(built_fill(p + scale_fill_jac_d()), jac_pal(n = 3))
  expect_identical(built_fill(p + scale_fill_jac_d(reverse = TRUE)),
                   jac_pal(n = 3, reverse = TRUE))
  expect_identical(built_fill(p + scale_fill_jac_d(palette = "light")),
                   jac_pal("light", n = 3))
})

test_that("continuous palettes work in discrete scales for ordered data", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = factor(letters[1:12]), y = 1)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = x)) +
    ggplot2::geom_col() +
    scale_fill_jac_d(palette = "seq")
  # 12 levels is more than a discrete palette allows, but fine here.
  expect_identical(built_fill(p), jac_pal("seq", n = 12))
})

test_that("more than 8 levels with a discrete palette errors at build time", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = letters[1:9], y = 1)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = x)) +
    ggplot2::geom_col() +
    scale_fill_jac_d()
  expect_error(ggplot2::ggplot_build(p), class = "jacarandr_error_too_many")
})

test_that("discrete scales check their arguments when created", {
  skip_if_not_installed("ggplot2")
  # Mistakes are reported straight away, not when the plot is printed.
  expect_error(scale_fill_jac_d("purple"), class = "jacarandr_error_palette")
  expect_error(scale_colour_jac_d(reverse = "no"),
               class = "jacarandr_error_flag")
})

test_that("extra arguments are passed on to ggplot2", {
  skip_if_not_installed("ggplot2")
  s <- scale_fill_jac_d(name = "Group", na.value = "grey80")
  expect_identical(s$name, "Group")
  expect_identical(s$na.value, "grey80")
})

# Continuous scales ----------------------------------------------------------

test_that("continuous scales are ggplot2 continuous scales", {
  skip_if_not_installed("ggplot2")
  expect_s3_class(scale_colour_jac_c(), "ScaleContinuous")
  expect_s3_class(scale_fill_jac_c(), "ScaleContinuous")
  expect_identical(scale_colour_jac_c()$aesthetics, "colour")
  expect_identical(scale_fill_jac_c()$aesthetics, "fill")
})

test_that("continuous scales span the palette from end to end", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = 1:3, y = 1, z = c(0, 5, 10))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = z)) +
    ggplot2::geom_tile()

  seq_cols <- jac_pal("seq")
  fills <- built_fill(p + scale_fill_jac_c())
  expect_identical(fills[c(1, 3)], seq_cols[c(1, length(seq_cols))])

  fills_rev <- built_fill(p + scale_fill_jac_c(reverse = TRUE))
  expect_identical(fills_rev[c(1, 3)], seq_cols[c(length(seq_cols), 1)])
})

test_that("midpoint puts the diverging centre colour at that value", {
  skip_if_not_installed("ggplot2")
  # Skewed data: without a midpoint, 0 would not be at the centre.
  df <- data.frame(x = 1:3, y = 1, z = c(-2, 0, 8))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = z)) +
    ggplot2::geom_tile()

  div_cols <- jac_pal("div")
  centre <- div_cols[(length(div_cols) + 1) / 2]

  fills <- built_fill(p + scale_fill_jac_c(palette = "div", midpoint = 0))
  expect_identical(fills[2], centre)
  # The far side of the midpoint reaches the end of the palette.
  expect_identical(fills[3], div_cols[length(div_cols)])

  fills_plain <- built_fill(p + scale_fill_jac_c(palette = "div"))
  expect_false(identical(fills_plain[2], centre))
})

test_that("continuous scales reject discrete palettes and bad midpoints", {
  skip_if_not_installed("ggplot2")
  expect_error(scale_fill_jac_c("main"), class = "jacarandr_error_palette")
  expect_snapshot(scale_colour_jac_c("main"), error = TRUE)
  for (m in list("0", NA_real_, Inf, c(0, 1))) {
    expect_error(scale_fill_jac_c("div", midpoint = m),
                 class = "jacarandr_error_midpoint", info = deparse(m))
  }
})

# Shared behaviour -----------------------------------------------------------

test_that("American spellings are aliases", {
  expect_identical(scale_color_jac_d, scale_colour_jac_d)
  expect_identical(scale_color_jac_c, scale_colour_jac_c)
})

test_that("scales give install advice when ggplot2 is missing", {
  local_mocked_bindings(is_ggplot2_installed = function() FALSE)
  for (fn in list(scale_colour_jac_d, scale_fill_jac_d, scale_colour_jac_c,
                  scale_fill_jac_c)) {
    expect_error(fn(), class = "jacarandr_error_ggplot2")
  }
  expect_snapshot(scale_fill_jac_d(), error = TRUE)
})

# rescale_around() ------------------------------------------------------------

test_that("rescale_around() centres the midpoint and is symmetric", {
  r <- rescale_around(0)
  # The extent is twice the furthest distance from the midpoint (2 * 8), so
  # -2 maps to 0.5 - 2 / 16.
  expect_identical(r(c(-2, 0, 8)), c(0.375, 0.5, 1))
  expect_identical(r(c(-4, 0, 4)), c(0, 0.5, 1))
  expect_identical(r(5, to = c(0, 10), from = c(-5, 5)), 10)
})

test_that("rescale_around() handles a midpoint outside the data range", {
  r <- rescale_around(10)
  expect_identical(r(c(0, 5)), c(0, 0.25))
})

test_that("rescale_around() handles constant data and missing values", {
  r <- rescale_around(3)
  expect_identical(r(c(3, 3, NA)), c(0.5, 0.5, NA))
  expect_identical(r(c(1, NA, 5)), c(0, NA, 1))
})
