# Let's start analysing the data!

library(ggplot2)
library(jsonlite)
library(dplyr)
library(readxl)

eu_horizon_co2 <- read.csv("Data/Working/EU_Horizon_Co2.csv")
org_types <- read_excel("Data/External/org_types_vocab.xlsx")

# 0. Get data that I need that wasn't origainlly included to dataset
# Stack 2020 and 2021 projects
p20 <-fromJSON("Data/External/project_h2020.json")
p21 <- fromJSON("Data/External/project_h2021.json")
project_data <- bind_rows(p20, p21) 

#Add activizty type col
eu_horizon_co2 <- inner_join(eu_horizon_co2, org_types, by = "activity_type")

# Keep col I need
missing_cols <- project_data %>% select(id, ecMaxContribution)

# Join to master data
eu_horizon_co2 <- inner_join(eu_horizon_co2, missing_cols, by="id")


# 1. Identify countries with the most universtiy involvement in green projects
# Aggregate number of projects and plot data with a stacked bar chart


eu_horizon_co2$ecMaxContribution <- as.integer(eu_horizon_co2$ecMaxContribution)
projects_by_country <- eu_horizon_co2 %>% 
  group_by(country_name) %>% 
  summarise(total = sum(ecMaxContribution))



# 2. Identify most active EU-based universities involved in green projects
# Aggregate number of projects and plot data with a bar chart
horizon_unis <- eu_horizon_co2 %>% filter(activity_type == "HES") # Filter for universities


# 3. Identify trends in started projets per ountry per year
# Plot data with a line plot


# 4. Explore relationship between number of projects per university, energy project funding per uni, and a country's Co2 emission
# Filter plot data with a parallel co-ordinates plot
