---
---

## The Semivariogram

To correct for the bias introduced by uneven sampling of soil lead
concentrations across space, we will generate a gridded layer (surface) from lead
point measurements and aggregate the gridded values at the census tract level.
To generate the surface, you will need to fit a variogram model to the
sample lead measurements. 
{:.notes}

A semivariogram quantifies the effect of distance on the correlation between
values from different locations. *On average*, measurements of the same variable
at two nearby locations are more similar (lower variance) than when those
locations are distant.
{:.notes}

The [gstat](){:.rlib} library, a geospatial analogue to the [stats](){:.rlib}
library, provides variogram estimation, among several additional tools.



~~~r
library(gstat)
lead_xy <- read.csv('data/SYR_soil_PB.csv')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

The empirical semivariogram shown below is a windowed average of the squared
difference in lead concentrations between sample points.
As expected, the difference increases as distance between points increases and
eventually flattens out at large distances.



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

Here we use the formula `ppm ~ 1` to specify that lead concentration `ppm` is
the dependent variable, and we are not fitting any trend (1 means intercept only).
We pass another formula to the `locations` argument, `locations = ~ x + y`,
to specify the x and y coordinate of each location.
{:.notes}

===

Fitting a model semivariogram tidies up the information about autocorrelation
in the data, so we can use it for interpolation.



~~~r
v_ppm_fit <- fit.variogram(
  v_ppm,
  model = vgm(model = "Sph", psill = 1, range = 900, nugget = 1))
plot(v_ppm, v_ppm_fit)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/smooth/unnamed-chunk-3-1.png" %})
{:.captioned}

We use `fit.variogram()` to fit a model to our empirical variogram `v_ppm`. The type of 
model is specified with the argument `model = vgm(...)`.
The parameters of `vgm()`, which we use to fit the variogram,
are the `model` type, here `"Sph"` for spherical meaning equal trends in all directions,
the `psill` or height of the plateau where the variance flattens out, the `range` or distance 
until reaching the plateau, and the `nugget` or intercept.
A more detailed description is outside the scope of this
lesson; for more information check out the [gstat documentation](https://cran.r-project.org/web/packages/gstat/index.html) 
and the references cited there.
{:.notes}

===

## Kriging

The modeled semivariogram acts as a parameter when performing Gaussian process regression, commonly known as kriging, to
interpolate predicted values for locations near our observed data. 
The steps to perform kriging with the [gstat](){:.rlib} library are:

1. Generate a modeled semivariogram
1. Generate new locations for "predicted" values
1. Call `krige` with the data, locations for prediction, and semivariogram

===

Generate a low resolution (for demonstration) grid of points overlaying the
bounding box for the lead data and trim it down to the polygons of interest.
Remember, the goal is aggregating lead concentrations within each census tract.



~~~r
pred_ppm <- st_make_grid(
  lead, cellsize = 400,
  what = 'centers')
pred_ppm <- pred_ppm[census_tracts]
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


Here, `st_make_grid()` creates a grid of points, `pred_ppm`, at the center of 400-meter squares over the
extent of the `lead` geometry. We can specify `cellsize = 400` because the CRS of `lead` is
in units of meters, and `what = 'centers'` means we want the points at the center of each
grid cell. The grid spatial resolution is derived from the extent of the region and the
application (coarser or finer depending on the use). Next, we find only the points contained
within census tract polygons using the shorthand `pred_ppm[census_tracts]`. This is shorthand for
using `st_intersects()` to find which grid points are contained within the polygons, then subsetting the 
grid points accordingly.
{:.notes}

===

Map the result to verify that we have only points contained in our census tracts.



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

The first argument of `krige` specifies the model for the means, which is constant according to our 
formula for lead concentrations (again, `~ 1` means no trend). 
The observed ppm values are in the `locations` data.frame along with the point geometry. 
The result is a data frame with predictions for lead concentrations at the points in `newdata`.



~~~r
pred_ppm <- krige(
  formula = ppm ~ 1,
  locations = lead,
  newdata = pred_ppm,
  model = v_ppm_fit)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Verify that `krige` generated predicted values for each of the grid points.



~~~r
ggplot() + 
  geom_sf(data = census_tracts,
          fill = NA) +
  geom_sf(data = pred_ppm,
          aes(color = var1.pred))
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/smooth/unnamed-chunk-7-1.png" %})
{:.captioned}

===

And the same commands that joined lead concentrations to census tracts apply to
joining the predicted concentrations too.



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


Here, we find the predicted lead concentration value for each census tract
by taking the means of the kriged grid point values (`var1.pred`), 
grouped by `TRACT`.
{:.notes}

===

The predictions should be, and are, close to the original averages with
deviations that correct for autocorrelation.



~~~r
ggplot(census_lead_tracts,
       aes(x = pred_ppm, y = avg_ppm)) +
  geom_point() +
  geom_abline(slope = 1)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/smooth/unnamed-chunk-9-1.png" %})
{:.captioned}

===

The effect of paying attention to autocorrelation is subtle, but it is noticeable and had the expected effect in tract 5800. The pred_ppm value is a little higher than the average.



~~~r
> census_lead_tracts %>% filter(TRACT == 5800)
~~~
{:title="Console" .input}


~~~
Simple feature collection with 1 feature and 5 fields
Geometry type: POLYGON
Dimension:     XY
Bounding box:  xmin: 405633.1 ymin: 4762867 xmax: 406445.9 ymax: 4764711
CRS:           32618
# A tibble: 1 x 6
  TRACT POP2000 perc_hispa                             geometry avg_ppm pred_ppm
* <int>   <int>      <dbl>                        <POLYGON [m]>   <dbl>    <dbl>
1  5800    2715     0.0302 ((406445.9 4762893, 406017.5 476286…    5.44     5.53
~~~
{:.output}

