# Derivation of the jacarandr palettes ---------------------------------------
#
# This script documents how the hex values in R/palettes.R were chosen and
# checked. It is not part of the built package (see .Rbuildignore) and needs
# the 'colorspace' and 'farver' packages. Re-run it after changing any colour,
# then copy the printed values into R/palettes.R.

library(colorspace)
library(farver)

# Minimum pairwise CIEDE2000 distance, as seen by normal vision and under
# simulated deuteranopia, protanopia and tritanopia.
min_delta_e <- function(cols) {
  sims <- list(
    normal = cols,
    deutan = deutan(cols),
    protan = protan(cols),
    tritan = tritan(cols)
  )
  vapply(sims, function(x) {
    lab <- decode_colour(x)
    d <- compare_colour(lab, lab, "rgb", method = "cie2000")
    min(d[upper.tri(d)])
  }, numeric(1))
}

# Main discrete palette ------------------------------------------------------
# Hand-picked, then tuned by grid search until every pair is at least 10
# apart under all three simulations. The constraints that bind:
# * Green vs orange under protanopia. Red-blind readers see red and orange
#   as darker, so the fig leaf green (L* 47) must stay clearly darker than the
#   flame tree orange (L* 66). A lighter green fails this check.
# * Pink vs deep blue under protanopia, where lilly pilly looks bluish. Blue
#   quandong is kept darker (L* 38) than lilly pilly (L* 52).
# * Wattle vs flame tree under deuteranopia, which is why wattle is a slightly
#   lighter, yellower gold than a pure wattle colour.
main <- c(
  jacaranda = "#8E73C9", fig_leaf = "#3A7E2F", flame_tree = "#F28249",
  wattle = "#F2C83A", blue_gum = "#9CC0CF", lilly_pilly = "#C85382",
  blue_quandong = "#42598B", twilight = "#352862"
)
round(min_delta_e(main), 1)
for (k in 3:8) print(round(min_delta_e(main[seq_len(k)]), 1))

# Light companion ------------------------------------------------------------
# Mix each colour towards white in CIELAB. Mixing all eight by the same amount
# flattens their lightness differences and they collapse under CVD, so each
# gets its own amount, found by random search to maximise the minimum
# distance (rounded here so the result is reproducible).
mix <- c(0.45, 0.27, 0.42, 0.27, 0.47, 0.33, 0.31, 0.34)
lab <- convert_colour(decode_colour(main), "rgb", "lab")
lab <- lab * (1 - mix) + outer(mix, c(100, 0, 0))
light <- setNames(encode_colour(convert_colour(lab, "lab", "rgb")), names(main))
light
round(min_delta_e(light), 1)

# Sequential -----------------------------------------------------------------
# HCL with the jacaranda hue (about 276 degrees), strictly decreasing
# lightness and chroma peaking at the jacaranda anchor itself.
hcl_hex <- function(l, c, h) hex(polarLUV(l, c, h), fixup = TRUE)
seq_pal <- hcl_hex(
  l = c(96, 84, 70, 54, 40, 27, 16),
  c = c(10, 32, 55, 67, 55, 42, 30),
  h = c(285, 280, 278, 276, 274, 272, 270)
)
seq_pal[4] <- main[["jacaranda"]] # use the exact core colour as the midpoint
seq_pal

# Diverging ------------------------------------------------------------------
# Lightness mirrored around a near-neutral centre (L* 95), jacaranda hue
# on the low side and the fig leaf hue on the high side.
fig_hue <- coords(as(hex2RGB(main[["fig_leaf"]]), "polarLUV"))[, "H"]
div_pal <- hcl_hex(
  l = c(28, 50, 73, 95, 73, 50, 28),
  c = c(50, 48, 28, 2, 24, 40, 40),
  h = c(274, 276, 277, 90, fig_hue, fig_hue, fig_hue)
)
div_pal
