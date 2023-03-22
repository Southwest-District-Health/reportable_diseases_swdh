library(tidyverse)
library(here)
library(readxl)
library(lubridate)
source("get_data.R")


# Import Data -------------------------------------------------------------
epi_data <- read_excel(get_data_path(data_name = "All Disease Data.xlsx"))


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

full_data <- tidy_data

for (disease in unique(tidy_data$condition)){
  for (place in unique(tidy_data$county)){
    for (this_year in unique(tidy_data$year)){
      for (this_month in unique(tidy_data$month)){
        print(paste('Checking', disease, place, this_year, this_month))
        if (nrow(filter(tidy_data, 
                        condition == disease & 
                        county == place & 
                        year == this_year &
                        month == this_month)) == 0) {
          missing_row <- tibble('condition' = disease, 
                                'county' = place, 
                                'year' = this_year, 'month' = this_month, 
                                'n' = 0)
        full_data  <- bind_rows(full_data, missing_row)
          
        }
      }
    }
  }
}
# Export Data ------------------------------------------------------------

# Write data to CSV
write_csv(full_data, here('data', 'disease_count.csv'))

