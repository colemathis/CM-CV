require(vitae)
require(bookdown)
require(lubridate)
require(rmarkdown)
require(knitr)

# Never let a failed LaTeX build install or update TeX packages on its own:
# tinytex's auto-repair can run `tlmgr update --all`, which broke TinyTeX once.
# Install missing packages deliberately with tinytex::tlmgr_install("<pkg>").
options(tinytex.install_packages = FALSE)

source("convert_talks_to_bib.R")

bookdown::render_book("index.Rmd")