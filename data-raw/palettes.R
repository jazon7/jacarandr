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
# Hand-picked, then tuned until every pair is at least 10 apart under all
# three simulations. Red and green were given very different lightness
# (L* 57 vs 36) because equal lightness makes them merge under deuteranopia.
main <- c(
  jacaranda = "#8E73C9", gum_leaf = "#2F5E3D", flame_tree = "#E5603F",
  wattle = "#EFC23A", blue_gum = "#9CC0CF", red_cedar = "#A3521B",
  paperbark = "#D9C7A7", twilight = "#352862"
)
round(min_delta_e(main), 1)
for (k in 3:8) print(round(min_delta_e(main[seq_len(k)]), 1))

# Light companion ------------------------------------------------------------
# Mix 45% towards white in CIELAB. A uniform-lightness pastel set
# collapses under CVD, so mixing keeps the lightness ordering of "main".
lab <- convert_colour(decode_colour(main), "rgb", "lab")
lab <- lab * 0.55 + matrix(c(100, 0, 0), nrow(lab), 3, byrow = TRUE) * 0.45
light <- setNames(encode_colour(convert_colour(lab, "lab", "rgb")), names(main))
# The mixed red cedar sat too close to flame tree; nudged darker and browner.
light[["red_cedar"]] <- "#C4906F"
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
# on the low side and gum leaf hue (about 137 degrees) on the high side.
div_pal <- hcl_hex(
  l = c(28, 50, 73, 95, 73, 50, 28),
  c = c(50, 48, 28, 2, 22, 36, 34),
  h = c(274, 276, 277, 90, 137, 137, 137)
)
div_pal
