# Packages we're going to need
library(tidyverse)
library(qualtr)


qualtr:::register_options()

??share_surveys

df_group_survey_01 <- read_csv("data/groups-and-surveys_09-23.csv")

df_group_survey_02 <- df_group_survey_01 |> janitor::clean_names()

df_group_names <- df_group_survey_02 |>
    select(group_name, group_id) |>
    filter(!is.na(group_name))

df_group_survey_03 <- df_group_survey_02 |>
    select(-group_name) |>
    left_join(df_group_names, by = "group_id")

df_group_survey_data <- df_group_survey_03 |>
    filter(group_name != "FSC Survey Review")

df_group_survey_review <- df_group_survey_03 |>
    filter(group_name == "FSC Survey Review")

# Handle groups with normal perms first
gs_review_response <- df_group_survey_review |>
    select(survey_id, recipient_id = group_id) |>
    share_surveys()

gs_review_response |>
    left_join(df_group_names, by = c("recipient_id" = "group_id")) |>
    select(-response) |>
    View()

df_attempt_status_01 <- gs_review_response |>
    left_join(df_group_survey_03 |> select(survey_id, survey_name)) |>
    left_join(df_group_names, by = c("recipient_id" = "group_id"))

df_attempt_status_02 <- df_attempt_status_01 |>
    mutate(status_code = response |> map_chr("status_code")) |>
    select(group_name, group_id = recipient_id, survey_name, survey_id, status_code)

df_attempt_status_02 |> write_csv("output/data-share_status-codes.csv")

# Then deal with fsc survey review
fsc_review_custom_permissions <- list(
    response = list(
        editSurveyResponses = FALSE,
        createResponseSets = FALSE,
        viewResponseId = FALSE,
        useCrossTabs = FALSE,
        useScreenouts = FALSE
    ),
    result = list(
        downloadSurveyResults = FALSE,
        viewSurveyResults = FALSE,
        filterSurveyResults = FALSE,
        viewPersonalData = FALSE
    )
)

gs_review_response <- df_group_survey_review |>
    select(survey_id, recipient_id = group_id) |>
    share_surveys(custom_permissions = fsc_review_custom_permissions)

gs_review_response |>
    left_join(df_group_names, by = c("recipient_id" = "group_id")) |>
    select(-response) |>
    View()

df_review_attempt_status_01 <- gs_review_response |>
    left_join(df_group_survey_03 |> select(survey_id, survey_name)) |>
    left_join(df_group_names, by = c("recipient_id" = "group_id"))

df_review_attempt_status_02 <- df_review_attempt_status_01 |>
    mutate(status_code = response |> map_chr("status_code")) |>
    select(group_name, group_id = recipient_id, survey_name, survey_id, status_code)

df_review_attempt_status_02 |> write_csv("output/review-share_status-codes.csv")