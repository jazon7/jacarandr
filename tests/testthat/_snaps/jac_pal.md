# requesting more than 8 discrete colours is an informative error

    Code
      jac_pal("main", n = 9)
    Condition
      Error:
      ! Palette "main" has 8 colours, but n = 9 were requested. More than 8 categorical colours are hard to tell apart; consider grouping categories, or use the "seq" palette for ordered categories.

# invalid palette names are rejected with the valid choices

    Code
      jac_pal("purple")
    Condition
      Error:
      ! Unknown palette "purple". Available palettes are: "main", "light", "seq", "div".

# jac_colours() rejects unknown names, listing the valid ones

    Code
      jac_colours("jacaranda", "purple", "green")
    Condition
      Error:
      ! Unknown colour names: "purple", "green". Available names are: "jacaranda", "fig_leaf", "flame_tree", "wattle", "blue_gum", "lilly_pilly", "blue_quandong", "twilight".

# jac_colours() only accepts discrete palettes

    Code
      jac_colours(palette = "div")
    Condition
      Error:
      ! Palette "div" is diverging, but only "main", "light" can be used here. Use jac_pal() for the continuous palettes.

