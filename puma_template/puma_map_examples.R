###############################################################################
# MAPPING AT PUMA LEVEL USING TIDYCENSUS DATA
###############################################################################
# Retrieve PUMA data
tc_puma <- get_acs(
  geography = "public use microdata area",
  variables = c(<NAME OF VARIABLE HERE> = "<CENSUS VARIABLE ID HERE>"),
  state = <STATE FIPS CODE HERE>,
  year = 2019,
  geometry = TRUE,
  progress_bar = FALSE
)


# Pull county shapefiles to filter PUMA observations to a single county of interest
<NAME OF COUNTY HERE>_county <- tigris::counties(state = <STATE FIPS CODE HERE>, year = 2019, cb = TRUE, progress_bar = FALSE) %>% 
  filter(COUNTYFP == "<COUNTY FIPS CODE HERE>")

# Now we can join the pumas to counties, and then filter to the county we're interested in
pumas_of_interest <- sf::st_join(fairfax_county, tc_puma, join = st_intersects) %>%
  pull(GEOID.y)

my_data <- tc_puma %>%
  filter(GEOID %in% pumas_of_interest)

# Figure out best projection for data
recommended_crs <- crsuggest::suggest_crs(my_data, limit = 1)

# Create map
ggplot() +
  geom_sf(data = my_data,
          mapping = aes(fill = estimate),
          color = "white",
          size = 0.1) +
  geom_sf(data = fairfax_county,
          fill = NA,
          color = "magenta",
          size = 0.4) +
  coord_sf(crs = recommended_crs$crs_gcs) +
  scale_fill_gradientn(colors = c("#132B43", "#56B1F7"),
                       labels = scales::dollar) +
  labs(title = "<NAME OF VARIABLE HERE> in <NAME OF COUNTY, STATE ABBREVIATION HERE> by PUMA",
       fill = "<NAME OF VARIABLE HERE>") +
  theme_void()

# Save plot
ggsave("puma_tidycensus.png", plot = last_plot(), width = 8, height = 5, units = "in")


###############################################################################
# MAPPING AT PUMA LEVEL USING ORIGINAL DATA
###############################################################################
# Load in original data
ss_inc <- read_csv(here::here("mean_ssinc_oh_2019.csv"))

# Pull the spatial data from tigris
pumas <- tigris::pumas(state = <STATE FIPS CODE HERE>, year = 2019, cb = TRUE, progress_bar = FALSE) %>%
  rename(puma = PUMACE10) %>%
  transmute(puma = as.numeric(puma))

# Join the puma shapefiles to our original puma-level data so we can map it
ss_inc_puma <- left_join(pumas, ss_inc, by = "puma")

# Pull county shapefiles to filter PUMA observations to a single county of interest
<NAME OF COUNTY HERE>_county <- tigris::counties(state = <STATE FIPS CODE HERE>, year = 2019, cb = TRUE, progress_bar = FALSE) %>% 
  filter(COUNTYFP == "<COUNTY FIPS CODE HERE>")

# Now we can join the pumas to counties, and then filter to the county we're interested in
my_data <- sf::st_join(ss_inc_puma, franklin_county, join = st_intersects) %>% 
  filter(COUNTYFP == "<COUNTY FIPS CODE HERE>")

# Figure out best projection for data
recommended_crs <- crsuggest::suggest_crs(my_data, limit = 1)

# Create map
ggplot() +
  geom_sf(data = my_data,
          mapping = aes(fill = mean_ssinc),
          color = "white",
          size = 0.1) +
  geom_sf(data = <NAME OF COUNTY HERE>_county,
          fill = NA,
          color = "magenta",
          size = 0.4) +
  coord_sf(crs = recommended_crs$crs_gcs) +
  scale_fill_gradientn(colors = c("#132B43", "#56B1F7"),
                       labels = scales::dollar) +
  labs(title = "<NAME OF VARIABLE HERE> in <NAME OF COUNTY, STATE ABBREVIATION HERE> by PUMA",
       fill = "<NAME OF VARIABLE HERE>") +
  theme_void()

# Save plot
ggsave("puma_own_data.png", plot = last_plot(), width = 8, height = 8, units = "in")
