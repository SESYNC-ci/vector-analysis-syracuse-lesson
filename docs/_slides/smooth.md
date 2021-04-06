---
---
    
## The Semivariogram

A semivariogram quantifies the effect of distance on the correlation between
values from different locations. *On average*, measurements of the same variable
at two nearby locations are more similar (lower variance) than when those
locations are distant.
{:.notes}

The [gstat](){:.rlib} library, a geospatial analogue to the [stats](){:.rlib}
library provides variogram estimation among several additional tools.



~~~r
library(gstat)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
Registered S3 method overwritten by 'xts':
  method     from
  as.zoo.xts zoo 
~~~
{:.output}


~~~r
lead_xy <- read.csv('data/SYR_soil_PB.csv')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

The empirical semivariogram shown below is a windowed average of the squared
difference in lead concentrations between sample points.



~~~r
v_ppm <- variogram(
  ppm ~ 1,
  locations = ~ x + y,
  data = lead_xy)
plot(v_ppm)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/smooth/unnamed-chunk-2-1.png" %})
{:.captioned}

===

Fitting a model semivariogram tidies up the information about autocorrelation
in the data, so we can use it for interpolation.



~~~r
v_ppm_fit <- fit.variogram(
  v_ppm,
  model = vgm(1, "Sph", 900, 1))
plot(v_ppm, v_ppm_fit)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/smooth/unnamed-chunk-3-1.png" %})
{:.captioned}

===

## Kriging

The modeled semivariogram acts as a parameter when performing Guassian process regression, commonly known as kriging. The steps to perform Kriging with the [gstat](){:.rlib} library are:

1. Generate a modeled semivariogram
1. Generate new locations for "predicted" values
1. Call `krige` with the data, locations for prediction, and semivariogram

===

Generate a low resolution (for demonstration) grid of points overlaying the
bounding box for the lead data and trim it down to the polygons of interest.
Remember, that goal is aggregating lead concentrations within each census tract.



~~~r
pred_ppm <- st_make_grid(
  lead, cellsize = 400,
  what = 'centers')
idx <- unlist(
  st_intersects(census_tracts, pred_ppm))
pred_ppm <- pred_ppm[idx]
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Map the result to verify generated points.



~~~r
ggplot(census_tracts,
       aes(fill = POP2000)) +
  geom_sf() +
  geom_sf(data = pred_ppm,
          color = 'red', fill = NA)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/smooth/unnamed-chunk-5-1.png" %})
{:.captioned}

===

Almost done ...

1. Generate a modeled semivariogram
1. Generate new locations for "predicted" values
1. Call `krige` with the data, locations, and semivariogram

===

The first argument specifies the model for the means, which is constant according to our 
formula for lead concentrations. The observed ppm values are in the `locations` data.frame along with the point geometry. The result is a data frame with predictions for lead concentrations at the points in `newdata`.



~~~r
pred_ppm <- krige(
  formula = ppm ~ 1,
  locations = lead,
  newdata = pred_ppm,
  model = v_ppm_fit)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

And the same commands that joined lead concentrations to census tracts apply to
joining the predicted concentrations in too.



~~~r
pred_ppm_tracts <-
  pred_ppm %>%
  st_join(census_tracts) %>%
  st_drop_geometry() %>%
  group_by(TRACT) %>%
  summarise(pred_ppm = mean(var1.pred))
census_lead_tracts <- 
  census_lead_tracts %>%
  inner_join(pred_ppm_tracts)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

The predictions should be, and are, close to the original averages with
deviations that correct for autocorrelation.



~~~r
ggplot(census_lead_tracts,
       aes(x = pred_ppm, y = avg_ppm)) +
  geom_point()
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/smooth/unnamed-chunk-8-1.png" %})
{:.captioned}

===

The effect of paying attention to autocorrelation is subtle, but it is noticeable and had the expected effect in tract 5800. The pred_ppm value is a little higher than the average.



~~~r
> census_lead_tracts[52,]
~~~
{:title="Console" .input}


~~~
Simple feature collection with 1 feature and 5 fields
geometry type:  POLYGON
dimension:      XY
bbox:           xmin: 405633.1 ymin: 4762867 xmax: 406445.9 ymax: 4764711
epsg (SRID):    32618
proj4string:    +proj=utm +zone=18 +datum=WGS84 +units=m +no_defs
# A tibble: 1 x 6
  TRACT POP2000 perc_hispa                        geometry avg_ppm pred_ppm
  <int>   <int>      <dbl>                   <POLYGON [m]>   <dbl>    <dbl>
1  5800    2715     0.0302 ((406445.9 4762893, 406017.5 4…    5.44     5.53
~~~
{:.output}

