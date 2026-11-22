# jac_pal() -------------------------------------------------------------------

test_that("the default is the full main palette, unnamed", {
  out <- jac_pal()
  expect_identical(out, unname(jac_palettes$main$colours))
  expect_null(names(out))
})

test_that("every palette returns its defined colours when n is NULL", {
  for (name in names(jac_palettes)) {
    expect_identical(jac_pal(name), unname(jac_palettes[[name]]$colours),
                     info = name)
  }
})

test_that("discrete palettes return the first n colours", {
  main <- unname(jac_palettes$main$colours)
  for (n in 1:8) {
    expect_identical(jac_pal("main", n = n), main[seq_len(n)], info = n)
  }
  expect_identical(jac_pal("light", n = 2),
                   unname(jac_palettes$light$colours[1:2]))
})

test_that("n = 0 returns an empty character vector", {
  expect_identical(jac_pal("main", n = 0), character(0))
  expect_identical(jac_pal("seq", n = 0), character(0))
})

test_that("reverse flips the order but keeps the same colours", {
  expect_identical(jac_pal(reverse = TRUE), rev(jac_pal()))
  # For a subset, the first n colours are chosen and then reversed, so the
  # core jacaranda colour is still included.
  expect_identical(jac_pal(n = 3, reverse = TRUE), rev(jac_pal(n = 3)))
  expect_identical(jac_pal("seq", n = 5, reverse = TRUE),
                   rev(jac_pal("seq", n = 5)))
})

test_that("requesting more than 8 discrete colours is an informative error", {
  expect_error(jac_pal("main", n = 9), class = "jacarandr_error_too_many")
  expect_error(jac_pal("light", n = 20), class = "jacarandr_error_too_many")
  expect_snapshot(jac_pal("main", n = 9), error = TRUE)
})

test_that("continuous palettes interpolate any n, keeping both ends", {
  for (name in c("seq", "div")) {
    anchors <- unname(jac_palettes[[name]]$colours)
    for (n in c(2, 7, 25, 256)) {
      out <- jac_pal(name, n = n)
      expect_length(out, n)
      expect_match(out, "^#[0-9A-F]{6}$")
      expect_identical(out[1], anchors[1], info = paste(name, n))
      expect_identical(out[n], anchors[length(anchors)],
                       info = paste(name, n))
    }
  }
})

test_that("interpolated colours pass exactly through every anchor", {
  # With n = 7 every output position is an anchor; with n = 13 every other
  # one is. Anchors must come back as their exact hex codes, not shifted by
  # the colour-space round trip.
  for (name in c("seq", "div")) {
    anchors <- unname(jac_palettes[[name]]$colours)
    expect_identical(jac_pal(name, n = length(anchors)), anchors)
    odd <- seq(1, 2 * length(anchors) - 1, by = 2)
    expect_identical(jac_pal(name, n = 2 * length(anchors) - 1)[odd],
                     anchors)
  }
})

test_that("interpolated colours change lightness monotonically for seq", {
  lab <- grDevices::convertColor(
    t(grDevices::col2rgb(jac_pal("seq", n = 50))) / 255,
    from = "sRGB", to = "Lab"
  )
  expect_true(all(diff(lab[, "L"]) < 0))
})

test_that("a single continuous colour is the start of the palette", {
  expect_identical(jac_pal("seq", n = 1), jac_pal("seq")[1])
  expect_identical(jac_pal("seq", n = 1, reverse = TRUE),
                   jac_pal("seq")[7])
})

test_that("n can be given as a double or an integer", {
  expect_identical(jac_pal(n = 3), jac_pal(n = 3L))
})

test_that("invalid n is rejected", {
  bad_n <- list(-1, 1.5, NA, NA_integer_, Inf, "3", c(1, 2), TRUE)
  for (n in bad_n) {
    expect_error(jac_pal(n = n), class = "jacarandr_error_n",
                 info = deparse(n))
  }
})

test_that("invalid palette names are rejected with the valid choices", {
  expect_error(jac_pal("jacaranda"), class = "jacarandr_error_palette")
  expect_error(jac_pal(NA_character_), class = "jacarandr_error_palette")
  expect_error(jac_pal(c("main", "seq")), class = "jacarandr_error_palette")
  expect_error(jac_pal(1), class = "jacarandr_error_palette")
  # No partial matching: "ma" must not silently mean "main".
  expect_error(jac_pal("ma"), class = "jacarandr_error_palette")
  expect_snapshot(jac_pal("purple"), error = TRUE)
})

test_that("invalid reverse is rejected", {
  for (r in list(NA, "yes", c(TRUE, FALSE), 1)) {
    expect_error(jac_pal(reverse = r), class = "jacarandr_error_flag",
                 info = deparse(r))
  }
})

test_that("errors are also ordinary R errors", {
  # Callers using tryCatch(error = ...) should not need to know our classes.
  expect_error(jac_pal("purple"), class = "error")
  expect_error(jac_pal("purple"), class = "jacarandr_error")
})

# jac_colours() ---------------------------------------------------------------

test_that("jac_colours() returns the named main palette by default", {
  expect_identical(jac_colours(), jac_palettes$main$colours)
})

test_that("jac_colours() looks up colours by name, in the order given", {
  out <- jac_colours("flame_tree", "jacaranda")
  expect_identical(
    out,
    c(flame_tree = "#F28249", jacaranda = "#8E73C9")
  )
  # Repeats are allowed, which is useful for highlighting.
  expect_length(jac_colours("blue_gum", "jacaranda", "blue_gum"), 3)
  # A character vector works as well as separate arguments.
  expect_identical(jac_colours(c("flame_tree", "jacaranda")), out)
})

test_that("jac_colours() supports the light palette", {
  expect_identical(jac_colours("wattle", palette = "light"),
                   jac_palettes$light$colours["wattle"])
})

test_that("jac_colours() rejects unknown names, listing the valid ones", {
  expect_error(jac_colours("purple"), class = "jacarandr_error_colour_name")
  expect_error(jac_colours(1), class = "jacarandr_error_colour_name")
  expect_error(jac_colours(NA_character_),
               class = "jacarandr_error_colour_name")
  expect_snapshot(jac_colours("jacaranda", "purple", "green"), error = TRUE)
})

test_that("jac_colours() only accepts discrete palettes", {
  expect_error(jac_colours(palette = "seq"), class = "jacarandr_error_palette")
  expect_snapshot(jac_colours(palette = "div"), error = TRUE)
})

test_that("jac_colors() is an alias of jac_colours()", {
  expect_identical(jac_colors, jac_colours)
})
