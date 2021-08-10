## SETUP
library(sf)
library(dplyr)

lead <- read.csv('data/SYR_soil_PB.csv')

lead <- st_as_sf(lead,
                 coords = c('x', 'y'),
                 crs = 32618)

blockgroups <- st_read('data/bg_00')

census <- read.csv('data/SYR_census.csv')
census <- mutate(census, 
                 BKG_KEY = as.character(BKG_KEY)
)

census_blockgroups <- inner_join(
  blockgroups, census,
  by = c('BKG_KEY'))

census_tracts <- census_blockgroups %>%
  group_by(TRACT) %>%
  summarise(
    POP2000 = sum(POP2000),
    perc_hispa = sum(HISPANIC) / POP2000)

lead_tracts <- lead %>%
  st_join(census_tracts) %>%
  st_drop_geometry() %>%
  group_by(TRACT) %>%
  summarise(avg_ppm = mean(ppm))

census_lead_tracts <- census_tracts %>%
  inner_join(lead_tracts)


# Areal interpolation lead ------------------------------------------------

# common interpolation grid for all the methods
pred_grid <- st_make_grid(
  lead, cellsize = 400,
  what = 'centers')
pred_grid <- pred_grid[census_tracts]

lead_vor <- lead %>%
  st_union %>%
  st_voronoi %>%
  st_collection_extract %>%
  st_as_sf %>%
  st_join(lead)

library(ggplot2)
ggplot(lead_vor, aes(fill = ppm)) + geom_sf(color = NA)

# Create the regular interpolation grid and get the corresponding value from the interpolation
pred_vor <- pred_grid %>% 
  st_as_sf %>%
  st_join(lead_vor)
ggplot(pred_vor, aes(color = ppm)) + geom_sf()


# IDW interpolation lead --------------------------------------------------

library(gstat)

lead_idw <- idw(
  formula = ppm ~ 1,
  locations = lead,
  newdata = pred_grid)

ggplot() + 
  geom_sf(data = census_tracts,
          fill = NA) +
  geom_sf(data = lead_idw,
          aes(color = var1.pred))


# Kriging interpolation lead ----------------------------------------------

# Originally included in lesson, to compare
lead_xy <- read.csv('data/SYR_soil_PB.csv')

v_ppm <- variogram(
  ppm ~ 1,
  locations = ~ x + y,
  data = lead_xy)
plot(v_ppm)

v_ppm_fit <- fit.variogram(
  v_ppm,
  model = vgm(model = "Sph", psill = 1, range = 900, nugget = 1))
plot(v_ppm, v_ppm_fit)

lead_krig <- krige(
  formula = ppm ~ 1,
  locations = lead,
  newdata = pred_ppm,
  model = v_ppm_fit)


# Join up all methods -----------------------------------------------------

pred_all <- pred_vor %>%
  rename(pred_voronoi = ppm) %>%
  mutate(pred_idw = lead_idw$var1.pred,
         pred_krig = lead_krig$var1.pred)

# All agree fairly well but IDW appears to agree less well than other methods
cor(pred_all[, c('pred_voronoi','pred_idw','pred_krig')] %>% st_drop_geometry)

pred_ppm_tracts <-
  pred_all %>%
  st_join(census_tracts) %>%
  st_drop_geometry() %>%
  group_by(TRACT) %>%
  summarise(across(c(pred_voronoi, pred_idw, pred_krig), mean))

census_lead_tracts <- 
  census_lead_tracts %>%
  inner_join(pred_ppm_tracts)

census_lead_tracts %>% filter(TRACT == 5800)
