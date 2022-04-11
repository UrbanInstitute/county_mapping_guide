###############################################################################
# MAPPING AT ZCTA LEVEL USING TIDYCENSUS DATA
###############################################################################

# Fill in the blanks shown by < > to create a map for your own county.
# Be sure to replace the "<" and ">" themselves as well.

# Load packages
library(tidyverse)
library(tidycensus)
library(crsuggest)
library(sf)
library(tigris)

# Tell R where to find your census API key so that you can use tidycensus
source(here::here("census_api_key.R"))

# Retrieve ZCTA level data from tidycensus
tc_zcta <- get_acs(
  geography = "zcta",
  variables = c(<NAME OF VARIABLE HERE> = "<CENSUS VARIABLE ID HERE>"),
  state = <STATE FIPS CODE HERE>,
  year = 2019,
  geometry = TRUE,
  progress_bar = FALSE
) %>%
  rename(zcta = GEOID)

# Pull county shapefiles to filter ZCTA observations to a single county of interest
<NAME OF COUNTY HERE>_county <- tigris::counties(state = <STATE FIPS CODE HERE>, year = 2019, cb = TRUE, progress_bar = FALSE) %>%
  filter(COUNTYFP == "<COUNTY FIPS CODE HERE>")

# Now we can join the pumas to counties, and then filter to the county we're interested in
my_data <- sf::st_join(tc_zcta, <NAME OF COUNTY HERE>_county, join = st_intersects) %>% 
  filter(COUNTYFP == "<COUNTY FIPS CODE HERE>")

# Figure out best projection for data
recommended_crs <- crsuggest::suggest_crs(my_data, limit = 1)

# Create map
ggplot() +
  geom_sf(data = my_data,
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
  labs(title = "<NAME OF VARIABLE HERE> in <NAME OF COUNTY, STATE ABBREVIATION HERE> by ZCTA",
       fill = "<NAME OF VARIABLE HERE>") +
  theme_void()

# Save plot
ggsave("zcta_tidycensus.png", plot = last_plot(), width = 8, height = 5, units = "in")