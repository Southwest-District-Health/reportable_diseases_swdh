library(tidyverse)
library(readxl)
library(here)
source('get_data.R')

# Import Data -------------------------------------------------------------

# Import county census estimates from 2010 to 2019
county_pop_1019 <- point_data_path(
  data_type = "raw",
  data_name = "co-est2019-annres-16.xlsx"
) %>%
  read_excel(range = "A4:M49")

# Import county census from 2020
county_pop_2021 <- point_data_path(
  data_type = "raw",
  data_name = "co-est2021-pop-16.xlsx"
) %>%
  read_excel(range = "A4:D49")

# Import disease count data

disease_count <- read_csv(here("data", "disease_count.csv")) %>%
  select("county_name" = county, everything())
# Set up stable data ------------------------------------------------------

county_pop_1019 <- county_pop_1019 %>%
  select(-`Estimates Base`, -`2010`) %>% 
  select("county" = ...1, "2010" = Census, everything()) %>%
  filter(county != "Idaho") %>%
  mutate("county_name" = str_to_lower(str_extract(county, "(?<=\\.)[A-Za-z]+"))) %>%
  select(-county) 

county_pop_2021 <- county_pop_2021 %>%
  select(-`2020`) %>% 
  select("county" = ...1, "2020" = ...2, everything()) %>%
  filter(county != "Idaho") %>%
  mutate("county_name" = str_to_lower(str_extract(county, "(?<=\\.)[A-Za-z]+"))) %>%
  select(-county) %>%
  select(county_name, everything())

# Merge 2017 to 2021 data
county_pop <- county_pop_1019 %>%
  left_join(county_pop_2021) %>%
  filter(county_name %in% c(
    "adams",
    "canyon",
    "gem",
    "owyhee",
    "payette",
    "washington"
  )) %>%
  pivot_longer(
    cols = -county_name,
    names_to = "year",
    values_to = "population"
  ) %>%
  mutate("year" = as.numeric(year))


# Add missing years to population data if they are behind disease data.
# This takes latest year of population data and puts that number as estimate for
# population for all missing years in county population data.

if (max(county_pop$year) < max(disease_count$year)) {
  missing_years <- (max(county_pop$year) + 1):max(disease_count$year)
  for (county in unique(county_pop$county_name)) {
    for (this_year in missing_years) {
      latest_county_pop <- county_pop %>%
        filter(county_name == county) %>%
        filter(year == max(year)) %>%
        select(population)
      
      missing_row <- tibble(
        "county_name" = county,
        "year" = this_year,
        latest_county_pop
      )
      county_pop <- bind_rows(county_pop, missing_row)
    }
  }
}

write_csv(county_pop, './data/county_population.csv')
