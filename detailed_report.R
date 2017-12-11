library("tidyverse")
library("ggridges")
library("DT")
library("lubridate")

period_start <- if_else(
  month(today()) < 9,
  ymd(paste(year(today()) - 1, "0701")),
  ymd(paste(year(today()), "0701"))
  )

data_file <- file.path("ssp_record.csv")
record_data <- read_csv(
  file = data_file,
  na = c("", "NA", "NULL"),
  col_type = cols(
    hs_grad_year = col_integer(),
    school = col_factor(levels = NULL),
    address = col_character(),
    city = col_character(),
    state = col_factor(levels = NULL),
    zip = col_integer(),
    school_type = col_factor(levels = NULL),
    corporation = col_factor(levels = NULL),
    che_region = col_factor(levels = NULL),
    county = col_factor(levels = NULL),
    ssps_complete = col_integer(),
    ssp1 = col_logical(),
    ssp2 = col_logical(),
    ssp3 = col_logical(),
    ssp4 = col_logical(),
    ssp5 = col_logical(),
    ssp6 = col_logical(),
    ssp7 = col_logical(),
    ssp8 = col_logical(),
    ssp9 = col_logical(),
    ssp10 = col_logical(),
    ssp11 = col_logical(),
    ssp12 = col_logical(),
    ninth_complete = col_logical(),
    tenth_complete = col_logical(),
    eleventh_complete = col_logical(),
    twelfth_complete = col_logical(),
    ninth_tenth_complete = col_logical(),
    ninth_eleventh_complete = col_logical(),
    ninth_twelfth_complete = col_logical(),
    ssp1_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp2_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp3_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp4_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp5_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp6_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp7_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp8_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp9_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp10_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp11_date = col_date(format = "%Y-%m-%d %H:%M:%OS"),
    ssp12_date = col_date(format = "%Y-%m-%d %H:%M:%OS")
    )
  )

summary_table <- record_data %>%
  filter(county == "Marion") %>%
  filter(hs_grad_year <= 2021) %>%
  group_by(hs_grad_year, school) %>%
  select(hs_grad_year, school, contains("_date")) %>%
  gather(key = ssp, value = date, -hs_grad_year, -school) %>%
  filter(!is.na(date)) %>%
  # summarise(
  #   address = unique(address),
  #   city = unique(city),
  #   school_type = unique(school_type),
  #   corporation = unique(corporation),
  #   che_region = unique(che_region),
  #   county = unique(county),
  #   ssps_complete_mean = mean(ssps_complete)
  #   ) %>%
  print()

ggplot(
  summary_table,
  aes(
    x = date,
    y = ssp,
    fill = ssp,
    color = ssp
    )
  ) +
scale_color_brewer(palette = "Paired")+
scale_fill_brewer(palette = "Paired")+
geom_density_ridges(
  # bandwidth = 1/2,
  stat = "binline",
  binwidth = 1,
  alpha = 0.5,
  scale = 4
  ) +
scale_x_date(
  limits = c(period_start, today()),
  date_breaks = "1 month",
  date_labels = "%b"
  ) +
geom_vline(xintercept = today() - 7) +
geom_vline(xintercept = today() %m+% months(-1)) +
geom_vline(xintercept = today() %m+% months(-1)) +
facet_wrap("hs_grad_year", ncol = 1)

ggplot(
  filter(summary_table, hs_grad_year == 2018),
  aes(
    x = date,
    fill = hs_grad_year,
    color = hs_grad_year
    )
  ) +
scale_color_brewer(palette = "Paired")+
scale_fill_brewer(palette = "Paired")+
geom_histogram(binwidth = 1) +
scale_x_date(
  limits = c(period_start, today()),
  date_breaks = "1 month",
  date_labels = "%b"
  ) +
geom_vline(xintercept = today() - 7) +
geom_vline(xintercept = today() %m+% months(-1)) +
geom_vline(xintercept = today() %m+% months(-1)) +
facet_wrap("ssp", ncol = 3)


# Did any of your schools hold an event for SSP completion in mid-late october?
# 9:58 AM
# Hey Alex
# North Central HS
# George Washington
# McKenzie Center for Innovation JAG (which encompasses Lawrence Central and North
