# Integrity of the palette definitions themselves. These tests protect the
# design properties described in R/palettes.R, so that a future edit to a hex
# value cannot silently break them.

hex_lightness <- function(colours) {
  # CIELAB L* using only base R, so this runs even without Suggests.
  rgb <- t(grDevices::col2rgb(colours)) / 255
  grDevices::convertColor(rgb, from = "sRGB", to = "Lab")[, "L"]
}

test_that("every palette has a valid type and valid, unique hex colours", {
  for (name in names(jac_palettes)) {
    pal <- jac_palettes[[name]]
    expect_true(pal$type %in% c("discrete", "sequential", "diverging"),
                info = name)
    expect_match(pal$colours, "^#[0-9A-F]{6}$", info = name)
    expect_false(anyDuplicated(pal$colours) > 0, info = name)
  }
})

test_that("the expected palettes exist, with the expected types", {
  types <- vapply(jac_palettes, `[[`, character(1), "type")
  expect_identical(
    types,
    c(main = "discrete", light = "discrete", seq = "sequential",
      div = "diverging")
  )
})

test_that("discrete palettes have 8 colours with matching names and order", {
  expected <- c("jacaranda", "gum_leaf", "flame_tree", "wattle", "blue_gum",
                "red_cedar", "paperbark", "twilight")
  expect_named(jac_palettes$main$colours, expected)
  expect_named(jac_palettes$light$colours, expected)
})

test_that("jacaranda is the first main colour and the seq midpoint", {
  core <- jac_palettes$main$colours[["jacaranda"]]
  expect_identical(unname(jac_palettes$main$colours[1]), core)
  seq_cols <- jac_palettes$seq$colours
  expect_identical(seq_cols[(length(seq_cols) + 1) / 2], core)
})

test_that("each light colour is lighter than its main counterpart", {
  expect_true(all(
    hex_lightness(jac_palettes$light$colours) >
      hex_lightness(jac_palettes$main$colours)
  ))
})

test_that("the sequential palette gets strictly darker", {
  expect_true(all(diff(hex_lightness(jac_palettes$seq$colours)) < 0))
})

test_that("the diverging palette is lightest in the middle and symmetric", {
  l <- hex_lightness(jac_palettes$div$colours)
  mid <- (length(l) + 1) / 2
  expect_equal(which.max(l), mid)
  expect_true(all(diff(l[seq_len(mid)]) > 0)) # rising to the centre
  expect_true(all(diff(l[mid:length(l)]) < 0)) # falling after it
  # Mirrored steps should have near-equal lightness, so neither side looks
  # more extreme than the other.
  expect_lt(max(abs(l - rev(l))), 3)
})

test_that("discrete colours stay distinguishable under simulated CVD", {
  skip_if_not_installed("colorspace")
  skip_if_not_installed("farver")

  min_delta_e <- function(cols) {
    lab <- farver::decode_colour(cols)
    d <- farver::compare_colour(lab, lab, "rgb", method = "cie2000")
    min(d[upper.tri(d)])
  }
  simulations <- list(
    normal = identity,
    deutan = colorspace::deutan,
    protan = colorspace::protan,
    tritan = colorspace::tritan
  )
  # CIEDE2000 of about 10 is a clear difference between small marks; the
  # light palette is meant for large areas, where smaller gaps still read.
  thresholds <- c(main = 10, light = 7)

  for (pal in names(thresholds)) {
    cols <- unname(jac_palettes[[pal]]$colours)
    for (sim in names(simulations)) {
      expect_gte(
        min_delta_e(simulations[[sim]](cols)),
        thresholds[[pal]],
        label = paste0('min CIEDE2000 of "', pal, '" under ', sim)
      )
    }
  }
})
