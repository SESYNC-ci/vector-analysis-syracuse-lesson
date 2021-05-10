---
---

## Regression

Continuing the theme that vector data *is* tabular data, the natural
progression in statistical analysis is toward regression. Building a regression
model requires making good assumptions about relationships in your data:

- between *columns* as independent and dependent variables
- between *rows* as more-or-less independent observations

===

The following model assumes an association (in the linear least-squares sense),
between the Hispanic population and lead concentrations and assumes independence
of every census tract (i.e. row).



~~~r
ppm.lm <- lm(pred_ppm ~ perc_hispa,
  data = census_lead_tracts)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Is that model any good?



~~~r
census_lead_tracts <- census_lead_tracts %>%
  mutate(lm.resid = resid(ppm.lm))
plot(census_lead_tracts['lm.resid'])
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/regress/unnamed-chunk-2-1.png" %})
{:.captioned}

===

We can see that areas with negative and positive residuals are not randomly distributed.
They tend to cluster together in space: there is
autocorrelation. It is tempting to ask for a semivariogram plot of the
residuals, but that requires a precise definition of the distance between
polygons. A favored alternative for quantifying autoregression in non-point
feature collections is Moran's I. This analog to Pearson's correlation
coefficient quantifies autocorrelation rather than cross-correlation.
{:.notes}

Moran's I is the correlation between all pairs of features, weighted to
emphasize features that are close together. It does not dodge the problem of
distance weighting, but provides default assumptions for how to do it.

If you are interested in reading more, this [chapter](https://mgimond.github.io/Spatial/spatial-autocorrelation.html) from
the ebook [Intro to GIS and Spatial Analysis](https://mgimond.github.io/Spatial/index.html)
provides an accessible introduction to the Moran's I test.
{:.notes}



~~~r
library(sp)
library(spdep)
library(spatialreg)

tracts <- as(
  st_geometry(census_tracts), 'Spatial')
tracts_nb <- poly2nb(tracts)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


The function `poly2nb()` from [spdep](){:.rlib} generates a neighbor list from
a set of polygons. This object is a list of each polygon's neighbors that share
a border with it (in matrix form, this would be called an adjacency matrix).
Unfortunately, [spdep](){:.rlib} was created before [sf](){:.rlib}, so the two 
packages aren't compatible. That's why we first need to convert the geometry of `census_tracts` 
to an [sp](){:.rlib} object using `as(st_geometry(...), 'Spatial')`.
{:.notes}

===

The `neighbors` variable is the network of features sharing a boundary point.



~~~r
plot(census_lead_tracts['lm.resid'],
     reset = FALSE)
plot.nb(tracts_nb, coordinates(tracts),
        add = TRUE)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/regress/unnamed-chunk-4-1.png" %})
{:.captioned}

`plot.nb()` plots a network graph, given a `nb` object and a matrix of coordinates as 
arguments. We extract a coordinate matrix from the `Spatial` object `tracts` using
`coordinates()`.
{:.notes}

===

Add weights to the neighbor links.



~~~r
tracts_weight <- nb2listw(tracts_nb)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


By default, `nb2listw()` weights each neighbor of a polygon equally, although other
weighting options are available. For example, you could give a link between a pair
of neighbors a higher weight if their centroids are closer together.
{:.notes}

===

Visualize correlation between the residuals and the weighted average
of their neighbors with `moran.plot` from the
[spdep](){:.rlib} package. 

The positive trend line is consistent with the
earlier observation that features in close proximity have similar
residuals. In other words, the higher the residual
in a polygon, the higher the residual of its 
neighboring polygons---thus the slope of the line is positive. This is
a bad thing because a good regression model should not show any
trend in its residuals. So we can't be confident in the results of the
simple `lm()` that ignores spatial relationships.
{:.notes}



~~~r
moran.plot(
  census_lead_tracts[['lm.resid']],
  tracts_weight,
  labels = census_lead_tracts[['TRACT']],
  pch = 19)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/regress/unnamed-chunk-6-1.png" %})
{:.captioned}

The first argument to `moran.plot` is the vector of data values (in this case the residuals),
and the second argument is the weighted neighbor list. The `labels` argument in this
case is the vector of tract codes. By default `moran.plot` will flag and label values
that have high influence on the relationship (the diamond-shaped points labeled with 
census tract codes).
{:.notes}

===

There are many ways to use geospatial information about tracts to impose
assumptions about non-independence between observations in the regression. One
approach is a Spatial Auto-Regressive (SAR) model, which regresses each value against
the weighted average of neighbors.

In this SAR model, we are asking how much variation in soil lead concentration across
census tracts is explained by percent Hispanic population, just like in the simple
linear model we fit above. But the key difference is that the SAR model incorporates
an additional random effect that accounts for the tendency of neighboring tracts to
have similar lead concentration values --- that is, the lead concentration
values are spatially non-independent. For further reading, check out this
[chapter](https://keen-swartz-3146c4.netlify.app/spatial-regression.html) of the
ebook [Spatial Data Science](https://keen-swartz-3146c4.netlify.app/), which is 
a great resource in general.
{:.notes}




~~~r
ppm.sarlm <- lagsarlm(
  pred_ppm ~ perc_hispa,
  data = census_lead_tracts,
  tracts_weight,
  tol.solve = 1.0e-30)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


Here, `lagsarlm()` from [spatialreg](){:.rlib} uses the same formula as the `lm()` 
we did above, but we also need to supply the weighted neighbor list.
The `tol.solve` argument is needed for the numerical method the model uses.
{:.notes}

===

The Moran's I plot of residuals now shows less correlation; which means the SAR
model's assumption about spatial autocorrelation (i.e. between table rows) makes
the rest of the model more plausible.



~~~r
moran.plot(
  resid(ppm.sarlm),
  tracts_weight,
  labels = census_lead_tracts[['TRACT']],
  pch = 19)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/regress/unnamed-chunk-9-1.png" %})
{:.captioned}

===

For further confirmation, we can plot the spatial distribution of the residuals 
of the SAR model. Overall, residuals are lower and have less spatial structure 
compared to the original linear model.



~~~r
census_lead_tracts <- census_lead_tracts %>%
  mutate(sar.resid = resid(ppm.sarlm))
plot(census_lead_tracts['sar.resid'])
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/regress/unnamed-chunk-10-1.png" %})
{:.captioned}

===

Feeling more confident in the model, we can now take a look at the regression
coefficients and overall model fit.



~~~r
> summary(ppm.sarlm)
~~~
{:title="Console" .input}


~~~

Call:lagsarlm(formula = pred_ppm ~ perc_hispa, data = census_lead_tracts, 
    listw = tracts_weight, tol.solve = 1e-30)

Residuals:
      Min        1Q    Median        3Q       Max 
-0.992669 -0.210942  0.037845  0.246989  0.888440 

Type: lag 
Coefficients: (asymptotic standard errors) 
            Estimate Std. Error z value Pr(>|z|)
(Intercept)  1.16047    0.46978  2.4702   0.0135
perc_hispa   1.45285    0.95717  1.5179   0.1291

Rho: 0.7499, LR test value: 22.434, p-value: 2.175e-06
Asymptotic standard error: 0.095079
    z-value: 7.8871, p-value: 3.1086e-15
Wald statistic: 62.207, p-value: 3.1086e-15

Log likelihood: -29.16485 for lag model
ML residual variance (sigma squared): 0.14018, (sigma: 0.37441)
Number of observations: 57 
Number of parameters estimated: 4 
AIC: 66.33, (AIC for lm: 86.764)
LM test for residual autocorrelation
test value: 4.5564, p-value: 0.032797
~~~
{:.output}



