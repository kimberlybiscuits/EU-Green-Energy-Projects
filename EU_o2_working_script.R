# Working in terminal previously, didn't save script. Bad practice but here we go. 
# Previously, I loaded data, created new dataframes with just the cols I needed in each dataset

# Now it's time to get all the data into one file for overall cleaning and analysis

# For combining rows/observations, stack/bind
all_orgs <- bind_rows(orgs_2020_clean, orgs_2021_clean)
euro_sci_voc <- bind_rows(euro_sci_voc_20_clean,euro_sci_voc_21_clean)

# Change type to integer to allow binding
euro_sci_voc_20_clean$projectID <- as.integer(euro_sci_voc_20_clean$projectID)
euro_sci_voc <- bind_rows(euro_sci_voc_20_clean,euro_sci_voc_21_clean)
all_projects <- bind_rows(projects_h2020_clean,projects_h2021_clean)

# Change key names across files to be consistent (id, couuntry_code)
all_orgs <- rename(all_orgs, id = projectID)
euro_sci_voc <- rename(euro_sci_voc, id = projectID)
country_codes_names_clean <- rename_all(country_codes_names_clean, tolower)
country_codes_names_clean <- rename(country_codes_names_clean, country_name = "country name")
horizon_data <- rename(horizon_data, country_code = country)
co2_data_clean <- rename(co2_data_clean, country_name = country)
energy_horizon_projects <- rename(energy_horizon_projects, topic = euroSciVocTitle)

# Join data frames to combine columns by a consistent 'key'
orgs_projects <- inner_join(all_orgs, all_projects, by="id")
horizon_data <- inner_join(orgs_projects, euro_sci_voc, by="id")
horizon_data <- inner_join(horizon_data, country_codes_names_clean, by="country_code") # The inner join here also removed non-eu observations from horizon_data: happy accident but watch for this (choose correct join method)


# Let's isolate the energy projects
energy_horizon_projects <- horizon_data %>% filter(grepl("energy", euroSciVocTitle, ignore.case = TRUE))

# Let's clean up the column names using the janitor library, converts to snake_case
energy_horizon_projects <- clean_names(energy_horizon_projects)

# Let's group projects IDs by topic
horizon_energy_data_grouped <- energy_horizon_projects %>% 
  group_by(id) %>% 
  mutate(topic = paste(topic, collapse = ", ")) %>%
  distinct(id, .keep_all = TRUE) # It's usually good practice to ungroup() afterwards, but since we want this grouping for the final file, we wont

#Let's rename some weird looking row observations
horizon_energy_data_grouped <- horizon_energy_data_grouped %>% 
  mutate(country_name = recode(country_name, "Germany (including former GDR from 1991)" = "Germany"))

# Final join of Co2 data
horizon_data_final <- horizon_energy_data_grouped %>% left_join(co2_data, by = c("country_name" = "country", "start_year" = "year"))

# I've decided to omit the NAs in the cumulative Co2 col (406 of them), since the analysis is based on this figure
eu_horizon_co2 <- na.omit(horizon_data_final)

# Export csv
write_csv(eu_horizon_co2, file = "EU_Horizon_Co2.csv")


