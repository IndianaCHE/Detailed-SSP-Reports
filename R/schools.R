suppressPackageStartupMessages(library("tidyverse"))
suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("ggmap"))
suppressPackageStartupMessages(library("stringr"))

school_spec_plan <- drake_plan(strings_in_dots = "literals",
  school_spec = cols(
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
  )

schools_plan <- drake_plan(strings_in_dots = "literals",
  schools_table_raw = read_csv(
    file_in("schools.csv"),
    na = na_spec,
    col_types = school_spec),
  schools_table_clean = schools_table_raw %>%
    mutate_if(is_character, str_trim),
  schools_list = schools_table_clean %>% select("School") %>% distinct(),
  corp_list = schools_table_clean %>% select("Corporation") %>% distinct(),
  region_list = schools_table_clean %>% select("CHE Region") %>% distinct(),
  county_list = schools_table_clean %>% select("County") %>% distinct(),
  state_list = schools_table_clean %>% select("State") %>% distinct(),
)

geolocation_plan <- drake_plan(strings_in_dots = "literals",
  geo_location_source = {
    #including to cause a dependency
    schools_table_clean
    if_else(
    goog_day_limit() > nrow(schools_table_clean),
    "google",
    "dsk"
    )
    },
  geo_source_pretty_fn = function(geo_location_source){
    case_when(
    geo_location_source == "dsk" ~ "Data Science Toolkit",
    geo_location_source == "google" ~ "Google Maps",
    )
  },
  geo_source_pretty = geo_source_pretty_fn(geo_location_source),
  schools_table_location = schools_table_clean %>%
    select("SchoolID", "Address", "City", "State", "Zip") %>%
    mutate("location_string" := paste(
        Address, City, State, Zip
        )) %>%
    mutate_geocode(
      location = UQ(as.name("location_string")),
      output = "more",
      messaging = FALSE,
      source = geo_location_source
      ) %>%
    as.tibble()
    )

google_api_key <- read_lines("google_maps_api_key.txt")
register_google(
  key = google_api_key,
  account_type = "standard",
  second_limit = 5
  )

schools_file_plan <- bind_rows(
  school_spec_plan,
  schools_plan,
  geolocation_plan
  )
