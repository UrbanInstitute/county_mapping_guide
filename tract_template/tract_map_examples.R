# Load packages
library(tidyverse)
library(tidycensus)
library(crsuggest)
library(sf)
library(tigris)

# Tell R where to find your census API key so that you can use tidycensus
source(here::here("census_api_key.R"))

# Retrieve census tract level data from tidycensus
tc_tracts <- get_acs(
  geography = "tract",
  variables = c(<NAME OF VARIABLE HERE> = "<CENSUS VARIABLE ID HERE>"),
  state = <STATE FIPS CODE HERE>,
  county = <COUNTY FIPS CODE HERE>,
  year = 2019,
  geometry = TRUE,
  progress_bar = FALSE
)

# Pull county shapefile to include county border in map
<NAME OF COUNTY HERE>_county <- tigris::counties(state = <STATE FIPS CODE HERE>, year = 2019, cb = TRUE, progress_bar = FALSE) %>%
  filter(COUNTYFP == "<COUNTY FIPS CODE HERE>")

# Figure out best projection for data
recommended_crs <- crsuggest::suggest_crs(tc_tracts, limit = 1)

# Create map
ggplot() +
  geom_sf(data = tc_tracts,
          mapping = aes(fill = estimate),
          color = "white",
          size = 0.1) +
  geom_sf(data = <NAME OF COUNTY HERE>_county,
          fill = NA,
          color = "magenta",
          size = 0.4) +
  coord_sf(crs = recommended_crs$crs_gcs) +
  scale_fill_gradientn(colors = c("#132B43", "#56B1F7"),
                       labels = scales::dollar) +
  labs(title = "<NAME OF VARIABLE HERE> in <NAME OF COUNTY, STATE ABBREVIATION HERE> by census tract",
       fill = "<NAME OF VARIABLE HERE>") +
  theme_void()

# Save plot
ggsave("tract_tidycensus.png", plot = last_plot(), width = 8, height = 5, units = "in")