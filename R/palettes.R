# Palette definitions --------------------------------------------------------
#
# This file is the single source of truth for every colour in the package.
# All user-facing functions read from `jac_palettes`; nothing else hard-codes
# hex values.
#
# How the colours were chosen (the full, reproducible derivation is in
# `data-raw/palettes.R`):
#
# * "main" is ordered so that any prefix is a good palette on its own: the
#   first three colours (jacaranda, fig leaf, flame tree) are the most
#   distinct, and later colours add contrast to those before them. Lightness
#   was deliberately varied between hues (for example the fig leaf green,
#   L* 47, is darker than the orange flame tree, L* 66) so the colours stay
#   distinguishable for readers with red-green colour vision deficiency, who
#   tell red and green apart mainly by lightness. The CIEDE2000 distance
#   between every pair is at least 10 under simulated deuteranopia,
#   protanopia and tritanopia; a test guards this.
# * "light" mixes each "main" colour towards white in CIELAB. The amount
#   differs per colour (27% to 47%), because an equal mix flattens the
#   lightness differences that keep the colours apart. It keeps the same names
#   and order as "main" so the two can be paired.
# * "seq" is built in HCL space around the jacaranda hue with strictly
#   decreasing lightness. Its middle anchor is exactly the "main" jacaranda.
# * "div" mirrors lightness either side of a near-neutral centre: jacaranda
#   violet on the low side and fig leaf green on the high side.

#' @noRd
jac_palettes <- list(
  main = list(
    type = "discrete",
    colours = c(
      jacaranda     = "#8E73C9", # jacaranda bloom, the core colour
      fig_leaf      = "#3A7E2F", # glossy Moreton Bay fig leaves
      flame_tree    = "#F28249", # Illawarra flame tree flowers
      wattle        = "#F2C83A", # golden wattle blossom
      blue_gum      = "#9CC0CF", # juvenile blue gum leaves
      lilly_pilly   = "#C85382", # lilly pilly berries
      blue_quandong = "#42598B", # blue quandong fruit
      twilight      = "#352862"  # jacaranda at dusk
    )
  ),
  light = list(
    type = "discrete",
    colours = c(
      jacaranda     = "#C2B0E2",
      fig_leaf      = "#71A065",
      flame_tree    = "#FFB793",
      wattle        = "#FAD675",
      blue_gum      = "#CBDDE5",
      lilly_pilly   = "#DE8EA9",
      blue_quandong = "#7D89AE",
      twilight      = "#786A95"
    )
  ),
  seq = list(
    type = "sequential",
    colours = c(
      "#F7F1FF", "#DACBF4", "#B79FE6", "#8E73C9", "#66539A", "#433771",
      "#282051"
    )
  ),
  div = list(
    type = "diverging",
    colours = c(
      "#4A357C", "#7F6DAA", "#B8AED2", "#F1F1EE", "#9FBB9D", "#54824E",
      "#144D05"
    )
  )
)
