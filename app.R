library(here)
library(tidyverse)
library(readxl)
library(shiny)
library(lubridate)
library(maps)
library(ggdark)
library(ggiraph)
library(shinyWidgets)

last_updated <- "2024-02-06 09:23:24 MST"

# App parameters ----------------------------------------------------------

# County line colors
county_colors <- c(
  "owyhee" = "#deffff",
  "canyon" = "#f0daea",
  "gem" = "#fdf5cc",
  "payette" = "#dff6db",
  "washington" = "#ffbfbf",
  "adams" = "#ffe4ca"
)

# Select months app will be inclusive of. Should probably never change this.
months_inclusive <- c(
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
)

# Import Data -------------------------------------------------------------

# Import county map coordinates
county_map_data <- map_data("county", region = "idaho") %>%
  filter(subregion %in% c(
    "adams",
    "canyon",
    "gem",
    "owyhee",
    "payette",
    "washington"
  )) %>%
  select("county_name" = subregion, long, lat)

# Import disease count data
disease_count <- read_csv(here("data", "disease_count.csv")) %>%
  select("county_name" = county, everything())

# Import disease definitions and signs and symptoms
disease_definitions <- read_excel(here("data", "All disease definitions.xlsx"))

county_pop <- read_csv(here("data", "county_population.csv"))

years_inclusive <- c(min(disease_count$year):max(disease_count$year))
# Shiny app

# User interface ----------------------------------------------------------

ui <- fluidPage(
  titlePanel(
    h1(paste(
      "Reportable Diseases in Southwest Idaho",
      min(years_inclusive),
      "-",
      max(years_inclusive)
    ), style = "background-color:#004478;
                padding-left: 15px;
                color:#FFFFFF"),
    windowTitle = "Epidemiology - Southwest District Health"
  ),
  sidebarLayout(
    sidebarPanel(
      selectInput("disease",
        label = "Select a disease",
        choices = unique(disease_count$condition),
        selected = sample(unique(disease_count$condition), 1)
      ),
      awesomeCheckboxGroup(
        inputId = "years_selected",
        label = "Select years",
        choices = c(years_inclusive),
        selected = c(years_inclusive)
      ),
      awesomeCheckboxGroup(
        inputId = "months_selected",
        label = "Select months",
        choices = months_inclusive,
        selected = months_inclusive
      ),
      h1("Definitions", style = "background-color:#004478;
                padding-left: 0px;
                color:#FFFFFF"),
      textOutput("disease_definition"),
      h1("Symptoms", style = "background-color:#004478;
                padding-left: 0px;
                color:#FFFFFF"),
      textOutput("symptoms")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Map", ggiraphOutput("map_plot",
          width = "800px",
          height = "800px"
        )),
        tabPanel("Seasonality", ggiraphOutput("season_plot"))
      ),
      tags$div(
        style = "position:relative;",
        paste("Last updated:", last_updated)
      )
    )
  )
)

# Server ------------------------------------------------------------------
server <- function(input, output, session) {
  # Set up data for map plot
  disease_map_data <- reactive({
    disease_count %>%
      filter(condition == input$disease &
        year %in% input$years_selected &
        month %in% month(parse_date_time(input$months_selected,
          orders = "%B"
        ))) %>%
      left_join(county_pop, by = c("county_name", "year")) %>%
      group_by(county_name) %>%
      summarize(
        "rate" = (sum(n) / max(population)) * 10000,
        "count" = sum(n)
      ) %>%
      left_join(county_map_data, multiple = "all")
  })

  # Set up data for season count plot
  season_count_data <- reactive({
    disease_count %>%
      filter(condition == input$disease & year %in% input$years_selected) %>%
      group_by(month) %>%
      summarize("count" = sum(n))
  })

  # Create season bar plot
  plot_season <- reactive({
    ggplot(season_count_data(), aes(
      x = month(month, label = TRUE), y = count,
      data_id = count
    )) +
      geom_col_interactive(
        fill = "#004478",
        aes(tooltip = sprintf("Count: %.0f", count)),
        hover_nearest = TRUE
      ) +
      dark_theme_classic() +
      theme(text = element_text(size = 12)) +
      xlab("Month") +
      ylab("Number of Cases") +
      ggtitle("Seasonality of Cases Aggregated by Month")
  })

  output$season_plot <- renderggiraph({
    girafe(ggobj = plot_season(), width_svg = 8, height = 3)
  })

  # create map of district with counts of diseases
  plot <- reactive({
    ggplot(disease_map_data()) +
      geom_polygon_interactive(
        aes(
          data_id = county_name,
          x = long,
          y = lat,
          fill = rate,
          group = county_name,
          color = county_name,
          tooltip = sprintf(
            "Cumulative incidence rate per 10,000: %s\nCounty: %s",
            ifelse(count < 5, "Count < 5", as.character((round(rate, digits = 2)))), str_to_sentence(county_name)
          )
        ),
        linewidth = .75, hover_nearest = TRUE
      ) +
      coord_fixed(1.3) + # Makes map proportions look more correct
      ggtitle(paste(
        "Cumulative Incidence Rate by Disease",
        min(years_inclusive),
        "-",
        max(years_inclusive)
      )) +
      scale_fill_gradient(low = "grey", high = "red", "Incidence Rate") +
      scale_color_manual(
        values = county_colors, name = "County",
        labels = str_to_sentence(unique(disease_map_data()$county_name)),
        guide = "none"
      ) +
      dark_theme_void()
  })

  output$map_plot <- renderggiraph({
    plot <- girafe(ggobj = plot(), width_svg = 6, height_svg = 8)
    plot <- girafe_options(
      plot,
      opts_hover(
        css = "stroke-width:5;"
      )
    )
  })

  # Get definition of disease
  output$disease_definition <- renderText({
    definition <- disease_definitions %>%
      filter(Condition == input$disease) %>%
      select(Definition)
    definition$Definition
  })


  output$symptoms <- renderText({
    symptoms <- disease_definitions %>%
      filter(Condition == input$disease) %>%
      select(`Signs & Symptoms`)
    symptoms$`Signs & Symptoms`
  })
}
shinyApp(ui, server)
