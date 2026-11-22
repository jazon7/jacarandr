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
#   first three colours (jacaranda, gum leaf, flame tree) are the most
#   distinct, and each colour after that is the one that adds the most
#   contrast. Lightness was deliberately varied between hues (for example the
#   gum leaf green is much darker than the flame tree red) so the colours stay
#   distinguishable for readers with red-green colour vision deficiency. The
#   CIEDE2000 distance between every pair is at least 10 under simulated
#   deuteranopia, protanopia and tritanopia; a test guards this.
# * "light" mixes each "main" colour about halfway towards white in CIELAB,
#   with one hand-tuned value (red cedar) so its pairs stay apart. It keeps the
#   same names and order as "main" so the two can be paired.
# * "seq" is built in HCL space around the jacaranda hue with strictly
#   decreasing lightness. Its middle anchor is exactly the "main" jacaranda.
# * "div" mirrors lightness either side of a near-neutral centre: jacaranda
#   violet on the low side and gum leaf green on the high side.

#' @noRd
jac_palettes <- list(
  main = list(
    type = "discrete",
    colours = c(
      jacaranda  = "#8E73C9", # jacaranda bloom, the core colour
      gum_leaf   = "#2F5E3D", # eucalyptus canopy
      flame_tree = "#E5603F", # Illawarra flame tree flowers
      wattle     = "#EFC23A", # golden wattle blossom
      blue_gum   = "#9CC0CF", # juvenile blue gum leaves
      red_cedar  = "#A3521B", # Australian red cedar timber
      paperbark  = "#D9C7A7", # paperbark (Melaleuca) bark
      twilight   = "#352862"  # jacaranda at dusk
    )
  ),
  light = list(
    type = "discrete",
    colours = c(
      jacaranda  = "#C2B0E2",
      gum_leaf   = "#89A48F",
      flame_tree = "#FBA992",
      wattle     = "#FDDD97",
      blue_gum   = "#C9DCE4",
      red_cedar  = "#C4906F",
      paperbark  = "#EBE0CE",
      twilight   = "#8D81A6"
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
      "#4A357C", "#7F6DAA", "#B8AED2", "#F1F1EE", "#9BBBA3", "#4B835B",
      "#024D23"
    )
  )
)
