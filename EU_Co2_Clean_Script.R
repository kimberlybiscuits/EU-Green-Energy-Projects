# Load libraries
library(tidyverse)
library(janitor)

# 1. COMBINE DATASETS BY YEAR
# Stack observations from 2020 and 2021
all_orgs <- bind_rows(orgs_2020_clean, orgs_2021_clean) %>%
  rename(id = projectID)

euro_sci_voc <- bind_rows(
  euro_sci_voc_20_clean %>% mutate(projectID = as.integer(projectID)),
  euro_sci_voc_21_clean
) %>%
  rename(id = projectID)

all_projects <- bind_rows(projects_h2020_clean, projects_h2021_clean)

# 2. STANDARDIZE COLUMN NAMES
country_codes_names_clean <- country_codes_names_clean %>%
  rename_all(tolower) %>%
  rename(country_name = "country name")

horizon_data <- horizon_data %>%
  rename(country_code = country)

co2_data_clean <- co2_data_clean %>%
  rename(country_name = country)

# 3. JOIN DATASETS
horizon_data <- all_orgs %>%
  inner_join(all_projects, by = "id") %>%
  inner_join(euro_sci_voc, by = "id") %>%
  inner_join(country_codes_names_clean, by = "country_code") # Note: removes non-EU projects

# 4. FILTER TO ENERGY PROJECTS AND CLEAN
energy_horizon <- horizon_data %>%
  filter(grepl("energy", euroSciVocTitle, ignore.case = TRUE)) %>%
  clean_names() %>%
  # Group topics by project
  group_by(id) %>%
  mutate(topic = paste(topic, collapse = ", ")) %>%
  distinct(id, .keep_all = TRUE) %>%
  # Fix country name
  mutate(country_name = recode(country_name, 
                               "Germany (including former GDR from 1991)" = "Germany"
  ))

# 5. JOIN CO2 DATA AND FINALIZE
eu_horizon_co2 <- energy_horizon %>%
  left_join(co2_data_clean, by = c("country_name" = "country", "start_year" = "year")) %>%
  # Remove rows with missing CO2 data (406 NAs)
  drop_na(cumulative_co2)

# 6. EXPORT
write_csv(eu_horizon_co2, "EU_Horizon_Co2.csv")