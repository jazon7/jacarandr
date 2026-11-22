# Regenerate the README images ------------------------------------------------
#
# The README gallery is drawn by vignettes/gallery.Rmd, so the vignette is the
# only place the plot code lives. This script knits that vignette to a
# throwaway Markdown file (knitr alone, so pandoc is not needed) and keeps the
# figures, named man/figures/gallery-<chunk label>-1.png.
#
# Run from the package root after changing a palette or a gallery plot:
#   Rscript data-raw/readme-figures.R

pkgload::load_all(quiet = TRUE)

old <- list.files("man/figures", pattern = "^gallery-", full.names = TRUE)
unlink(old)

# Sharper than the vignette's default, for high-resolution screens. The
# vignette reads this option because its own setup chunk would otherwise
# override a dpi set here.
options(jacarandr.gallery.dpi = 150)
knitr::opts_chunk$set(fig.path = "man/figures/gallery-", dev = "png")
out <- tempfile(fileext = ".md")
invisible(knitr::knit("vignettes/gallery.Rmd", output = out, quiet = TRUE,
            envir = new.env()))
unlink(out)

cat(list.files("man/figures", pattern = "^gallery-"), sep = "\n")

# The jac_show() preview shown in the README's "See the colours" section.
grDevices::png("man/figures/README-main.png", width = 1600, height = 500,
               res = 200)
jac_show("main")
invisible(grDevices::dev.off())
