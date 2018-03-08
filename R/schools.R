library("magrittr")
library("drake")
library("readr")
library("ggmap")
library("stringr")

school_spec <- cols(
  SchoolID = col_integer(),
  School = col_character(),
  Address = col_character(),
  City = col_character(),
  State = col_character(),
  Zip = col_character(),
  `School Type` = col_integer(),
  Corporation = col_character(),
  `CHE Region` = col_character(),
  County = col_character()
)

schools_plan <- drake_plan(
  strings_in_dots = "literals",
  schools_table_raw = read_csv(
    file_in("schools.csv"),
    na = na_spec,
    col_types = school_spec),
  schools_table_clean = schools_table_raw %>%
    mutate_if(is_character, str_trim),
  schools_list = schools_table %>% select(School)
)

make(schools_plan)

geolocation_plan <- drake_plan(
  schools_table_location = schools_table_clean %>%
    select(SchoolID, Address, City, State, Zip) %>%
    #TODO Implement ggmap geocoding
    mutate()
  )

master_plan <- bind_rows(
  master_plan,
  levels_plan
  )
