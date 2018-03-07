library("magrittr")
library("drake")
library("readr")

schools_plan <- drake_plan(
  strings_in_dots = "literals",
  schools_table = read_csv(file_in("schools.csv")),
  schools_tidy = gather(schools_table, "level", "value", -"SchoolID"),
  state_list = filter(schools_tidy, level == "State") %>% pull("value")
)

vis_drake_graph(drake_config(schools_plan))
make(schools_plan)
