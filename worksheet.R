## Introduction

# In this exercise, we perform common spatial queries and vector processing on
# census data at the block group and census track levels. The overall goal is to
# explore the distribution of metals and its association with various population
# groups. As a geospatial analyst and EPA consultant for the city of Syracuse,
# your task is to investigate the relationship between metal concentration (in
# particular lead) and population. In particular, research suggests higher
# concentration of metals in minorities. In addition, children are more at risk
# of lead poisoning.

# GOAL: Use non-spatial and spatial queries, table and spatial joins to subset
# datasets and explore at risk population in urban settings, specifically lead
# poisoning in Syracuse, NY.

# # PART I: EXPLORE DATA READ AND DISPLAY INPUTS In this section, you perform
# multiple operations to explore the datasets. First, examine the number of rows
# and column for the spatial polygons (blocks, block groups and census tracks).
# Manipulate the datasets provided to join information using common table keys.
# To combine datasets, a spatial aggregation of the block group to census level
# is performed. Visualization of vector spatial data is illustrated with plot
# and ggplot commands for sf objects.

## Simple Features
library(magrittr)
library(sf)

lead <- read.csv('data/SYR_soil_PB.csv')
lead[['geometry']] <- st_sfc(
  ...
  crs = 32618)

lead[[1, 'geometry']] <- ...(
  c(...,
    ...),
  dim = 'XY')

lead <- ...

lead <- read.csv('data/SYR_soil_PB.csv')
lead <- ...(lead,
  ...,
  crs = 32618)

plot(lead['ppm'])

library(ggplot2)
ggplot(data = lead,
       mapping = aes(...)) +
  ...()

## Feature Collections

blockgroups <- read_sf('data/bg_00')

## Table Operations

ggplot(blockgroups,
       aes(...)) +
   ...()

census <- ...('data/SYR_census.csv')
census <- within(census, {
  ...
})

library(dplyr)

census_blockgroups <- ...(
  ..., census,
  by = c('BKG_KEY'))

ggplot(...,
       aes(fill = POP2000)) +
  geom_sf()

census_tracts <- census_blockgroups %>%
  group_by(...) %>%
  ...(
    POP2000 = sum(POP2000),
    perc_hispa = sum(HISPANIC) / POP2000)

tracts <- ...('data/ct_00')
ggplot(...,
       aes(fill = POP2000)) +
  geom_sf() +
  geom_sf(...,
          color = 'red', fill = NA)

# # PART II: SPATIAL QUERY AND AGGREGATION Join metals data to census tract
# polygons using the common key ID. Add lead data to the datasets by converting
# the textfile of sample lead concentration into a spatial object. This is done
# by assigning coordinates to the data frame containing x and y coordinates and
# converting to a spatial object. Perform a spatial query using the “st_join”
# function and summarize average lead by census tracts.

## Spatial Join

ggplot(...,
       aes(fill = POP2000)) +
  geom_sf() +
  geom_sf(..., color = 'red',
          fill = NA, size = 0.1)

lead_tracts <- lead %>%
    st_join(...) %>%
    ...()

lead_tracts <- lead %>%
    st_join(census_tracts) %>%
    st_drop_geometry() %>%
    ... %>%
    ...

census_lead_tracts <- census_tracts %>%
  inner_join(...)

ggplot(...,
       aes(fill = ...)) +
  geom_sf() +
  scale_fill_gradientn(
    colors = heat.colors(7))

library(mapview)
mapview(census_tracts,
        legend = FALSE,
        viewer.suppress = TRUE) +
  mapview(lead['ppm'])

# # PART III :  KRIGING SURFACES Generate a gridded layer (surface) from lead
# point measurements and aggregate lead levels at the census track levels. To
# generate a kriged surface, you will need to fit a variogram model to the
# sample lead measurements. The grid spatial resolution is derived from
# the extent of the region and the application (coarser or finer depending on
# the use).

## The Semivariogram

library(gstat)

lead_xy <- read.csv('data/SYR_soil_PB.csv')

v_ppm <- ...(
  ppm ~ 1,
  locations = ~ x + y,
  data = lead_xy)
plot(v_ppm)

v_ppm_fit <- ...(
  v_ppm,
  model = ...)
plot(v_ppm, v_ppm_fit)

## Kriging

pred_ppm <- ...(
  lead, cellsize = 400,
  what = 'centers')
idx <- unlist(
  ...(census_tracts, pred_ppm))
pred_ppm <- ...

ggplot(...,
       aes(fill = POP2000)) +
  geom_sf() +
  geom_sf(..., color = 'red', fill = NA)

pred_ppm <- ...(
  ...,
  locations = lead,
  newdata = pred_ppm,
  ...)

pred_ppm_tracts <-
  pred_ppm %>%
  ...(census_tracts) %>%
  st_drop_geometry() %>%
  group_by(TRACT) %>%
  summarise(...)
census_lead_tracts <- 
  census_lead_tracts %>%
  ...(pred_ppm_tracts)

ggplot(...,
       aes(x = ..., y = ...)) +
  geom_point()

# # PART IV : SPATIAL AUTOCORRELATION AND REGRESSION Examine spatial
# autocorrelation in lead data and perform a spatial regression between lead and
# percentage of Hispanic population. To do so, you will need to generate list of
# neighbors and weights for use in the Moran’ I. Moran’I s. Clustering is
# indicated by a Moran’s I greater than zero while negative Moran’s I signifies
# a “repulsion” process. Generate both measurements of Moran’s I and a
# scatterplot of its values.  The list of weights is also used in the spatial
# regression.

## Regression

ppm.lm <- ...(pred_ppm ~ perc_hispa,
  census_lead_tracts)

census_lead_tracts <- census_lead_tracts %>%
  mutate(...)
plot(census_lead_tracts['lm.resid'])

library(sp)
library(spdep)
tracts <- as(
  st_geometry(census_tracts), 'Spatial')
tracts_nb <- ...(tracts)

plot(census_lead_tracts['lm.resid'],
     reset = FALSE)
plot.nb(tracts_nb, coordinates(tracts),
        add = TRUE)

tracts_weight <- ...(tracts_nb)

...(
  census_lead_tracts[['lm.resid']],
  ...,
  labels = census_lead_tracts[['TRACT']],
  pch = 19)

ppm.sarlm <- ...(
  pred_ppm ~ perc_hispa,
  data = census_lead_tracts,
  tracts_weight,
  tol.solve = 1.0e-30)

# dev.off() # uncomment to try this if moran.plot below fails

moran.plot(
  ...,
  tracts_weight,
  labels = census_lead_tracts[['TRACT']],
  pch = 19)
