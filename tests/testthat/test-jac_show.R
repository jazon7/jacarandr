test_that("the overview draws every palette and returns their colours", {
  local_null_device()
  out <- withVisible(jac_show())
  expect_false(out$visible)
  expect_named(out$value, names(jac_palettes))
  # Discrete palettes are shown as-is, continuous ones as a smooth ramp.
  expect_identical(out$value$main, jac_pal("main"))
  expect_length(out$value$seq, 64)
})

test_that("a single palette returns the colours drawn, invisibly", {
  local_null_device()
  out <- withVisible(jac_show("main", n = 4, reverse = TRUE))
  expect_false(out$visible)
  expect_identical(out$value, jac_pal("main", n = 4, reverse = TRUE))
  expect_identical(jac_show("seq", n = 9), jac_pal("seq", n = 9))
})

test_that("every palette can be shown, with and without labels", {
  local_null_device()
  for (name in names(jac_palettes)) {
    expect_no_error(jac_show(name))
    expect_no_error(jac_show(name, labels = FALSE))
  }
  # Many swatches: labels are skipped rather than overlapping.
  expect_no_error(jac_show("seq", n = 40))
})

test_that("jac_show() restores the graphics parameters it changes", {
  local_null_device()
  before <- graphics::par("mar")
  jac_show()
  expect_identical(graphics::par("mar"), before)
  jac_show("main")
  expect_identical(graphics::par("mar"), before)
})

test_that("jac_show() validates its arguments", {
  local_null_device()
  expect_error(jac_show("purple"), class = "jacarandr_error_palette")
  expect_error(jac_show(n = 3), class = "jacarandr_error_n")
  expect_error(jac_show("main", n = 0), class = "jacarandr_error_n")
  expect_error(jac_show("main", n = 9), class = "jacarandr_error_too_many")
  expect_error(jac_show(reverse = NA), class = "jacarandr_error_flag")
  expect_error(jac_show(labels = "yes"), class = "jacarandr_error_flag")
})

test_that("label_ink() picks readable text on light and dark swatches", {
  expect_identical(label_ink(c("#FFFFFF", "#000000")),
                   c("#1A1A1A", "#FFFFFF"))
  expect_identical(label_ink(c("#F7F1FF", "#282051")),
                   c("#1A1A1A", "#FFFFFF"))
})
