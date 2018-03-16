suppressPackageStartupMessages(library("drake"))
suppressPackageStartupMessages(library("tidyverse"))

loadd(combined_levels_list)

analysis_functions_plan <- drake_plan(strings_in_dots = "literals",
  # This function expects to be already grouped by a date column
  count_by_date = function(.data, date_table){
    count_data <- .data %>%
      summarize(n = n())
    foo <- date_table %>%
      dplyr::full_join(
        x = ., y = count_data,
        by = c("date" = group_vars(.data))
        ) %>%
      arrange_at("date") %>%
      mutate(n = coalesce(n, 0L)) %>%
      mutate(cumn = cumsum(n))
    return(foo)
  },

  make_ts_plot = function(series = list(), date_table = seq_this_year){
    plot_data <- NULL
    for (i in seq_along(series)){
      plot_data <- plot_data %>%
        dplyr::bind_rows(mutate(series[[i]], label = names(series)[[i]]))
    }
    date_table <- rename(date_table, "equivilent_date" = "date")
    plot_data <- plot_data %>%
      left_join(
        x = ., y = date_table,
        by = "day_count") %>%
      group_by_at(c("label", "equivilent_date")) %>%
      summarize(
        n = sum(n),
        cumn = max(cumn)
        )
    browser()
    ts_plot <- plot_data %>%
      ggplot(
        data = .,
        aes(
          x = equivilent_date,
          y = cumn,
          label = label,
          color = label,
          fill = label
          )
        ) +
      geom_line()
  return(ts_plot)
  }

  )

middle_school_plan_template <- drake_plan(strings_in_dots = "literals",
  apps_this_year = ms_data_TK_refcode_TK %>%
    dplyr::filter_at(
      .vars = "SubmittedDateTime",
      .vars_predicate = any_vars(. >= rollover_date)
      ),
    apps_last_year = ms_data_TK_refcode_TK %>%
      dplyr::filter_at(
        .vars = "SubmittedDateTime",
        .vars_predicate = any_vars(. >= rollover_last_year)
        ) %>%
    dplyr::filter_at(
      .vars = "SubmittedDateTime",
      .vars_predicate = any_vars(. <= last_year)
      ),
    apps_this_year_count = apps_this_year_TK_refcode_TK %>%
      group_by_at("SubmittedDateTime") %>%
      count_by_date(.data = ., date_table = seq_this_year),
    apps_last_year_count = apps_last_year_TK_refcode_TK %>%
      group_by_at("SubmittedDateTime") %>%
      count_by_date(.data = ., date_table = seq_last_year),
    apps_ts_plot = make_ts_plot(
      series = list(
        "This Year" = apps_this_year_count_TK_refcode_TK,
        "Last Year" = apps_last_year_count_TK_refcode_TK
        ),
      date_table = seq_this_year
      )
    )

middle_school_plan <- evaluate_plan(
  plan = middle_school_plan_template,
  rules = list(
    "TK_refcode_TK" = combined_levels_list[["refcode"]]
    )
  )

ms_analysis_file_plan <- bind_rows(
  analysis_functions_plan,
  middle_school_plan
  )
