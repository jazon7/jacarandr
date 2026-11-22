# continuous scales reject discrete palettes and bad midpoints

    Code
      scale_colour_jac_c("main")
    Condition
      Error:
      ! Palette "main" is discrete, but only "seq", "div" can be used here. Use scale_colour_jac_d() or scale_fill_jac_d() for discrete data.

# scales give install advice when ggplot2 is missing

    Code
      scale_fill_jac_d()
    Condition
      Error:
      ! `scale_fill_jac_d()` needs the 'ggplot2' package. Install it with install.packages("ggplot2").

