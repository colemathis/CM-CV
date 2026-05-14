require(vitae)
require(bookdown)
require(lubridate)
require(rmarkdown)
require(knitr)

source("convert_talks_to_bib.R")

bookdown::render_book("index.Rmd")