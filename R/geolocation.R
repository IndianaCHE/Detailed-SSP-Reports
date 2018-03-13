suppressPackageStartupMessages(library("tidyverse"))
suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("ggmap"))

geolocation_source_plan <- drake_plan(strings_in_dots = "literals",
  geo_location_source = "dsk",
  geo_source_pretty_fn = function(geo_location_source){
    case_when(
      geo_location_source == "dsk" ~ "Data Science Toolkit",
      geo_location_source == "google" ~ "Google Maps",
      )
  },
  geo_source_pretty = geo_source_pretty_fn(geo_location_source)
  )

geolocation_data_plan <- drake_plan(strings_in_dots = "literals",
  address_data = schools_table_clean %>%
    select("SchoolID", "Address", "City", "State", "Zip") %>%
    mutate(location_string = paste(
        Address, City, State, Zip
        )),
    geo_data = geocode(
      location = address_data[["location_string"]],
      output = "more",
      messaging = FALSE,
      source = geo_location_source
      ),
    schools_table_location = bind_cols(address_data, geo_data)
    )

google_api_key <- read_lines("google_maps_api_key.txt")
register_google(
  key = google_api_key,
  account_type = "standard",
  second_limit = 5
  )

geolocation_file_plan <- bind_rows(
  geolocation_source_plan,
  geolocation_data_plan
  )