library(tidyverse)
library(here)
library(readxl)
library(lubridate)
source("get_data.R")


# Import Data -------------------------------------------------------------
epi_data <- read_excel(point_data_path(data_name = "All Disease Data.xlsx"))


# Tidy Data ---------------------------------------------------------------
# Combine HIV and AIDS types
epi_data$Condition[epi_data$Condition == "HIV" | epi_data$Condition == "AIDS"] <- "HIV or AIDS"

# Combine Salmonellosis types into one type
epi_data$Condition[epi_data$Condition == "Salmonellosis - prior to 2018" | epi_data$Condition == "Salmonellosis (excl S. Typhi and S. Paratyphi)" | epi_data$Condition == "Salmonellosis 2018 (excl paratyphoid and typhoid)"] <- "Salmonellosis"

# Combine Hepatitis B types
epi_data$Condition[epi_data$Condition == "Hepatitis B virus infection, Chronic" | epi_data$Condition == "Hepatitis B, acute"] <- "Hepatitis B"

# Create vector of counties to include in table
list_of_counties <- c(
  "adams",
  "canyon",
  "gem",
  "owyhee",
  "payette",
  "washington"
)

#Create tidy dataset
tidy_data <- epi_data %>%
  select(
    "investigation_date" = `Investigation Start Date`,
    "condition" = Condition,
    "county" = County
  ) %>%
  mutate(
    county = str_replace_all(str_to_lower(county), " county", ""),
    "year" = year(investigation_date),
    "month" = month(investigation_date)
  ) %>%
  filter(county %in% list_of_counties & condition != "Rabies, animal") %>% 
  select(-investigation_date) %>% 
  group_by(condition, county, year, month) %>% 
  summarize('n' = n())

# group the data by disease, place, year, and month, and calculate the sum of cases
full_data <- tidy_data %>% 
  group_by(condition, county, year, month) %>% 
  summarize(n = sum(n)) %>% 
  ungroup()

combinations <- expand.grid(unique(tidy_data$condition), 
                            unique(tidy_data$county), 
                            unique(tidy_data$year), 
                            unique(tidy_data$month))
colnames(combinations) <- c('condition', 'county', 'year', 'month')

#merge with the grouped data to fill in missing values with zeros
full_data <- full_data %>% 
  right_join(combinations, by = c('condition', 'county', 'year', 'month')) %>% 
  replace_na(list(n = 0)) %>% 
  select(condition, county, year, month, n)
# Export Data ------------------------------------------------------------

# Write data to CSV
write_csv(full_data, here('data', 'disease_count.csv'))

