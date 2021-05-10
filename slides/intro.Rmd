---
---

## Introduction

Vector data is a way to represent features on Earth's surface, which can be points (e.g. the 
locations of ice cream shops), polygons (e.g. the boundaries of countries), or lines (e.g. streets or rivers).
This lesson is a whirlwind tour through a set of tools in R that we can use to manipulate 
vector data and do data analysis on them to uncover spatial patterns.

The example dataset in this lesson is a set of measurements of soil lead levels in the 
city of Syracuse, New York, collected as part of a study investigating the relationship
between background lead levels in the environment and lead levels in children's blood. 
As a geospatial analyst and EPA consultant for the city of Syracuse,
your task is to investigate the relationship between metal concentration (in
particular lead) and population. In particular, research suggests higher
concentration of metals in minorities.
{:.notes}

===

## Lesson Objectives

- Dive into scripting vector data operations
- Manipulate spatial feature collections like data frames
- Address autocorrelation in point data
- Understand the basics of spatial regression

===

## Specific Achievements

- Read CSVs and shapefiles
- Intersect and dissolve geometries
- Smooth point data with Kriging
- Include autocorrelation in a regression on polygon data

