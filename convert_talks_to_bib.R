library(tidyverse)
library(lubridate)

# Read CSV
talks <- read_csv("data/talk.csv", show_col_types = FALSE)

# Parse "YY-Mon" (e.g. "22-Aug") into a date
talks <- talks %>%
  mutate(
    date_parsed = parse_date_time(when, orders = "y-b"),
    year_num    = year(date_parsed),
    month_bib   = tolower(month(date_parsed, label = TRUE, abbr = TRUE))
  )

# Generate a BibTeX key slug from a title
make_slug <- function(title) {
  s <- gsub("^(The|A|An) ", "", title, ignore.case = TRUE)
  s <- gsub("[^a-zA-Z0-9 ]", "", s)
  words <- strsplit(trimws(s), "\\s+")[[1]]
  words <- words[nchar(words) > 0][1:min(2, length(words))]
  paste(tolower(words), collapse = "_")
}

talks <- talks %>%
  mutate(
    slug     = map_chr(what, make_slug),
    key_base = paste0("mathis", year_num, "_", slug)
  ) %>%
  # Disambiguate duplicate keys with a suffix
  group_by(key_base) %>%
  mutate(
    key = if (n() > 1) paste0(key_base, "_", row_number()) else key_base
  ) %>%
  ungroup()

# Format one entry as a BibTeX string
bib_entry <- function(key, title, year, month, with, where, why) {
  lines <- c(
    paste0("@misc{", key, ","),
    "  author    = {Mathis, Cole},",
    paste0("  title     = {{", title, "}},"),
    paste0("  year      = {", year, "},"),
    paste0("  month     = ", month, ",")
  )
  if (!is.na(with) && nchar(trimws(with)) > 0) {
    lines <- c(lines, paste0("  publisher = {", with, "},"))
  }
  if (!is.na(where) && nchar(trimws(where)) > 0) {
    lines <- c(lines, paste0("  address   = {", where, "},"))
  }
  if (!is.na(why) && nchar(trimws(why)) > 0) {
    lines <- c(lines, paste0("  note      = {", why, "},"))
  }
  paste(c(lines, "}", ""), collapse = "\n")
}

# Write a data frame of talks to a .bib file (newest first)
write_bib_file <- function(df, path) {
  df <- arrange(df, desc(date_parsed))
  entries <- pmap_chr(
    list(df$key, df$what, df$year_num, df$month_bib,
         df$with, df$where, df$why),
    bib_entry
  )
  writeLines(entries, path)
  message("Wrote ", nrow(df), " entries to ", path)
}

write_bib_file(filter(talks, invited == "Y"),  "bib/invited_talks.bib")
write_bib_file(filter(talks, invited != "Y" | is.na(invited)), "bib/other_talks.bib")
