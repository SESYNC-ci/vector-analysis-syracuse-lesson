---
output: 
  html_document: 
    keep_md: yes
    self_contained: no
---

## Simple Features

A standardized set of geometric shapes are the essence of vector data. 
The [sf](){:.rlib} package puts sets of shapes in a tabular structure so that we can manipulate and analyze them.



~~~r
library(sf)

lead <- read.csv('data/SYR_soil_PB.csv')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

We read in a data frame with point coordinates called `lead` from an external CSV file, 
then create an `sf` object from the data frame. 
We use `st_as_sf()` with the `coords` argument to specify
which columns represent the `x` and `y` coordinates of each point.
The CRS must be specified with the argument `crs` via EPSG integer or proj4 string.



~~~r
lead <- st_as_sf(lead,
  coords = c('x', 'y'),
  crs = 32618)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

The `lead` data frame now has a "simple feature column" called `geometry`,
which `st_as_sf` creates from a CRS and a geometry type. 

Each element of the simple feature column is a simple feature geometry, here
created from the `"x"` and `"y"` elements of a given feature.
In this case, `st_as_sf` creates a point geometry because we supplied a 
single `x` and `y` coordinate for each feature, but vector features
can be points, lines, or polygons. 
{:.notes}



~~~r
> lead
~~~
{:title="Console" .input}


~~~
Simple feature collection with 3149 features and 2 fields
Geometry type: POINT
Dimension:     XY
Bounding box:  xmin: 401993 ymin: 4759765 xmax: 412469 ymax: 4770955
CRS:           EPSG:32618
First 10 features:
   ID      ppm                 geometry
1   0 3.890648 POINT (408164.3 4762321)
2   1 4.899391 POINT (405914.9 4767394)
3   2 4.434912   POINT (405724 4767706)
4   3 5.285548 POINT (406702.8 4769201)
5   4 5.295919 POINT (405392.3 4765598)
6   5 4.681277 POINT (405644.1 4762037)
7   6 3.364148 POINT (409183.1 4763057)
8   7 4.096946 POINT (407945.4 4770014)
9   8 4.689880 POINT (406341.4 4762603)
10  9 5.422257 POINT (404638.1 4767636)
~~~
{:.output}


===

| geometry | description |
|----------+-------------|
| `st_point` | a single point |
| `st_linestring` | sequence of points connected by straight, non-self-intersecting line pieces |
| `st_polygon` | one [or more] sequences of points in a closed, non-self-intersecting ring [with holes] |
| `st_multi*` | sequence of `*`, either `point`, `linestring`, or `polygon` |

===

Now that our data frame is a simple feature object, calling
functions like `print` and `plot` will use methods introduced by the `sf` package.

For example, the `print` method we just used automatically shows the CRS and truncates the
number of records displayed.

===

Using the `plot` method, the data are easily displayed as a map.

Here, the points are colored by lead concentration (`ppm`).
{:.notes}



~~~r
plot(lead['ppm'])
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/read/unnamed-chunk-4-1.png" %})
{:.captioned}

===

For [ggplot2]({:.rlib}) figures, use `geom_sf` to draw maps. In the `aes` mapping for feature collections, 
the `x` and `y` variables are automatically assigned to the `geometry` column, 
while other attributes can be assigned to visual elements like `fill` or `color`.

===



~~~r
library(ggplot2)

ggplot(data = lead,
       mapping = aes(color = ppm)) +
  geom_sf()
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/read/unnamed-chunk-5-1.png" %})
{:.captioned}

===

## Feature Collections

More complicated geometries are usually not stored in CSV files, but they are
usually still read as tabular data. We will see that the similarity of feature
collections to non-spatial tabular data goes quite far; the usual data
manipulations done on tabular data work just as well on `sf` objects. 
Here, we read the boundaries of the [Census block groups](https://www.census.gov/programs-surveys/geography/about/glossary.html#par_textimage_4)
in the city of Syracuse from a shapefile.
{:.notes}



~~~r
blockgroups <- st_read('data/bg_00')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
Reading layer `bg_00' from data source `/nfs/public-data/training/bg_00' using driver `ESRI Shapefile'
Simple feature collection with 147 features and 3 fields
Geometry type: POLYGON
Dimension:     XY
Bounding box:  xmin: 401938.3 ymin: 4759734 xmax: 412486.4 ymax: 4771049
CRS:           32618
~~~
{:.output}


===

The `geometry` column contains projected UTM coordinates of the polygon vertices.

Also note the table dimensions show that there are 147 features in the collection.



~~~r
> blockgroups
~~~
{:title="Console" .input}


~~~
Simple feature collection with 147 features and 3 fields
Geometry type: POLYGON
Dimension:     XY
Bounding box:  xmin: 401938.3 ymin: 4759734 xmax: 412486.4 ymax: 4771049
CRS:           32618
First 10 features:
        BKG_KEY Shape_Leng Shape_Area                       geometry
1  360670001001  13520.233  6135183.6 POLYGON ((403476.4 4767682,...
2  360670003002   2547.130   301840.0 POLYGON ((406271.7 4770188,...
3  360670003001   2678.046   250998.4 POLYGON ((406730.3 4770235,...
4  360670002001   3391.920   656275.6 POLYGON ((406436.1 4770029,...
5  360670004004   2224.179   301085.7 POLYGON ((407469 4770033, 4...
6  360670004001   3263.257   606494.9 POLYGON ((408398.6 4769564,...
7  360670004003   2878.404   274532.3 POLYGON ((407477.4 4769773,...
8  360670004002   3605.653   331034.9 POLYGON ((407486 4769507, 4...
9  360670010001   2950.688   376786.4 POLYGON ((410704.4 4769103,...
10 360670010003   2868.260   265835.7 POLYGON ((409318.3 4769203,...
~~~
{:.output}


===

Simple feature collections are data frames.



~~~r
> class(blockgroups)
~~~
{:title="Console" .input}


~~~
[1] "sf"         "data.frame"
~~~
{:.output}


===

The `blockgroups` object is a `data.frame`, but it also has the class attribute
of `sf`. This additional class extends the `data.frame` class in ways useful for
feature collection. For instance, the `geometry` column becomes "sticky" in most
table operations, like subsetting. This means that the `geometry` column is retained
even if it is not explicitly named.
{:.notes}



~~~r
> blockgroups[1:5, 'BKG_KEY']
~~~
{:title="Console" .input}


~~~
Simple feature collection with 5 features and 1 field
Geometry type: POLYGON
Dimension:     XY
Bounding box:  xmin: 402304.2 ymin: 4767421 xmax: 407469 ymax: 4771049
CRS:           32618
       BKG_KEY                       geometry
1 360670001001 POLYGON ((403476.4 4767682,...
2 360670003002 POLYGON ((406271.7 4770188,...
3 360670003001 POLYGON ((406730.3 4770235,...
4 360670002001 POLYGON ((406436.1 4770029,...
5 360670004004 POLYGON ((407469 4770033, 4...
~~~
{:.output}


===

## Table Operations

We can plot the polygon features using [ggplot2](){:.rlib} or do common
data wrangling operations:
{:.notes}

- plot
- merge or join
- "split-apply-combine" or group-by and summarize

===



~~~r
> ggplot(blockgroups,
+        aes(fill = Shape_Area)) +
+   geom_sf()
~~~
{:title="Console" .input}
![ ]({% include asset.html path="images/read/unnamed-chunk-10-1.png" %})
{:.captioned}

===

Merging with a regular data frame is done by normal merging on non-spatial
columns found in both tables.



~~~r
library(dplyr)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~

Attaching package: 'dplyr'
~~~
{:.output}


~~~
The following objects are masked from 'package:stats':

    filter, lag
~~~
{:.output}


~~~
The following objects are masked from 'package:base':

    intersect, setdiff, setequal, union
~~~
{:.output}


~~~r
census <- read.csv('data/SYR_census.csv')
census <- mutate(census, 
     BKG_KEY = as.character(BKG_KEY)
)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


Here, we read in a data frame called `census` with demographic characteristics
of the Syracuse block groups.
As usual, there's the difficulty that CSV files do not include metadata on data
types, which have to be set manually. We do this here by changing the `BKG_KEY`
column to character type using `as.character()`.
{:.notes}

===

Merge tables on a unique identifier (our primary key is `"BKG_KEY"`), but let the
`sf` object come first or its special attributes get lost.

The `inner_join()` function from [dplyr](){:.rlib} joins two data frames on a
common key specified with the `by` argument, keeping only the rows from each data 
frame with matching keys in the other data frame and discarding the rest.
{:.notes}



~~~r
census_blockgroups <- inner_join(
  blockgroups, census,
  by = c('BKG_KEY'))
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}




~~~r
> class(census_blockgroups)
~~~
{:title="Console" .input}


~~~
[1] "sf"         "data.frame"
~~~
{:.output}


===

The census data is now easily visualized as a map.



~~~r
ggplot(census_blockgroups,
       aes(fill = POP2000)) +
  geom_sf()
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/read/unnamed-chunk-14-1.png" %})
{:.captioned}

===

Feature collections also cooperate with the common "split-apply-combine" sequence of steps in data manipulation.

- *split* -- group the features by some factor
- *apply* -- apply a function that summarizes each subset, including their geometries
- *combine* -- return the results as columns of a new feature collection

===



~~~r
census_tracts <- census_blockgroups %>%
  group_by(TRACT) %>%
  summarise(
    POP2000 = sum(POP2000),
    perc_hispa = sum(HISPANIC) / POP2000)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


Here, we use the [dplyr](){:.rlib} function `group_by` to specify that we are doing an operation
on all block groups within a [Census tract](https://www.census.gov/programs-surveys/geography/about/glossary.html#par_textimage_13).
We can use `summarise()` to calculate as many summary statistics as we want, each one separated by a comma.
Here `POP2000` is the sum of all block group populations in each tract and `perc_hispa` is the sum of the Hispanic 
population divided by the total population (because now we have redefined `POP2000` to be the population total). 
The `summarise()` operation automatically combines the block group polygons from each tract!
{:.notes}

===

Read in the census tracts from a separate shapefile to confirm that the
boundaries were dissolved as expected.



~~~r
tracts <- st_read('data/ct_00')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
Reading layer `ct_00' from data source `/nfs/public-data/training/ct_00' using driver `ESRI Shapefile'
Simple feature collection with 57 features and 7 fields
Geometry type: POLYGON
Dimension:     XY
Bounding box:  xmin: 401938.3 ymin: 4759734 xmax: 412486.4 ymax: 4771049
CRS:           32618
~~~
{:.output}


~~~r
ggplot(census_tracts,
       aes(fill = POP2000)) +
  geom_sf() +
  geom_sf(data = tracts,
          color = 'red', fill = NA)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/read/unnamed-chunk-16-1.png" %})
{:.captioned}

===

By default, the sticky geometries are summarized with `st_union`. The
alternative `st_combine` does not dissolve internal boundaries. Check
`?summarise.sf` for more details.
