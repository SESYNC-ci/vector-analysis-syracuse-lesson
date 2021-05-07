---
editor_options: 
  chunk_output_type: console
---

## Summary

Rapid tour of packages providing tools for manipulation and analysis of
vector data in R.

===

- [sf](){:.rlib}
  - `st_sf`: make a simple features data frame
  - `st_read`: read a file into a simple features data frame
  - `st_join`: match tables on their geometry columns
- [gstat](){:.rlib}
  - `variogram`: distance lagged correlation for points
  - `fit.variogram`: autocorrelation model
  - `krige`: smooth interpolation over points
  
===

- [sp](){:.rlib}: a low level package with useful `Spatial*` class objects
- [spdep](){:.rlib}
  - `moran.plot`: infer autocorrelation from residual scatter plots
  - `poly2nb`, `nb2listw`: calculate spatial neighbors and their weights
- [spatialreg](){:.rlib}
  - `lagsarlm`: SAR model estimation
