# jacarandr 0.1.0

* Initial release.
* Four palettes: `"main"` (8 discrete colours), `"light"` (a softer companion
  to `"main"`), `"seq"` (sequential light to dark jacaranda) and `"div"`
  (diverging jacaranda to gum leaf).
* `jac_pal()` returns colours from any palette, with `n` and `reverse`.
* `jac_colours()` returns colours by name.
* `jac_show()` previews palettes with base graphics.
* ggplot2 scales: `scale_colour_jac_d()`, `scale_fill_jac_d()`,
  `scale_colour_jac_c()` and `scale_fill_jac_c()`, with `scale_color_*`
  aliases.
