---
output: 
  html_document: 
    keep_md: yes
    self_contained: no
---

## Simple Features

A standardized set of geometric shapes are the essence of vector data. 
The [sf](){:.rlib} puts sets of shapes in a tabular structure so that we can manipulate and analyze them.



~~~r
library(sf)

lead <- read.csv('data/SYR_soil_PB.csv')
lead[['geometry']] <- st_sfc(
  st_point(),
  crs = 32618)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

We read in a data frame called `lead` from an external CSV file, then create a new column called `geometry`. 
The `lead` data frame now has the "simple feature column", which `st_sfc` creates from a CRS and a geometry type 
(in this case a point geometry, `st_point()`). For now, each point is "EMPTY". The empty geometry is 
equivalent to a NA value. *Note*: you must call this column `geometry` so that other [sf](){:.rlib} functions
will recognize it as the simple feature column.
{:.notes}



~~~r
> head(lead)
~~~
{:title="Console" .input}


~~~
         x       y ID      ppm    geometry
1 408164.3 4762321  0 3.890648 POINT EMPTY
2 405914.9 4767394  1 4.899391 POINT EMPTY
3 405724.0 4767706  2 4.434912 POINT EMPTY
4 406702.8 4769201  3 5.285548 POINT EMPTY
5 405392.3 4765598  4 5.295919 POINT EMPTY
6 405644.1 4762037  5 4.681277 POINT EMPTY
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

Each element of the simple feature column is a simple feature geometry, here
created from the "x" and "y" elements of a given feature.

Here we use the first entry in the existing `x` and `y` columns of the `lead` 
data frame to fill in the empty `geometry` slot in the first row of the data frame.
The `dim = 'XY'` argument specifies a two-dimensional point.
{:.notes}



~~~r
lead[[1, 'geometry']] <- st_point(
  c(x = lead[[1, 'x']],
    y = lead[[1, 'y']]),
  dim = 'XY')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}




~~~r
> head(lead)
~~~
{:title="Console" .input}


~~~
         x       y ID      ppm                 geometry
1 408164.3 4762321  0 3.890648 POINT (408164.3 4762321)
2 405914.9 4767394  1 4.899391              POINT EMPTY
3 405724.0 4767706  2 4.434912              POINT EMPTY
4 406702.8 4769201  3 5.285548              POINT EMPTY
5 405392.3 4765598  4 5.295919              POINT EMPTY
6 405644.1 4762037  5 4.681277              POINT EMPTY
~~~
{:.output}


===

The whole data frame must be cast to a simple feature object, which causes
functions like `print` and `plot` to use methods introduced by the `sf` library.



~~~r
lead <- st_sf(lead)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

For example, the `print` method automatically shows the CRS and truncates the
number of records displayed.



~~~r
> lead
~~~
{:title="Console" .input}


~~~
Simple feature collection with 3149 features and 4 fields (with 3149 geometries empty)
Geometry type: POINT
Dimension:     XY
Bounding box:  xmin: NA ymin: NA xmax: NA ymax: NA
CRS:           EPSG:32618
First 10 features:
          x       y ID      ppm                 geometry
1  408164.3 4762321  0 3.890648 POINT (408164.3 4762321)
2  405914.9 4767394  1 4.899391              POINT EMPTY
3  405724.0 4767706  2 4.434912              POINT EMPTY
4  406702.8 4769201  3 5.285548              POINT EMPTY
5  405392.3 4765598  4 5.295919              POINT EMPTY
6  405644.1 4762037  5 4.681277              POINT EMPTY
7  409183.1 4763057  6 3.364148              POINT EMPTY
8  407945.4 4770014  7 4.096946              POINT EMPTY
9  406341.4 4762603  8 4.689880              POINT EMPTY
10 404638.1 4767636  9 5.422257              POINT EMPTY
~~~
{:.output}


===

Naturally, there is a shortcut to creating an `sf` object from a data frame with
point coordinates. We use `st_as_sf()` with the `coords` argument to specify
which columns represent the x and y coordinates of each point.
The CRS must be specified with the argument `crs` via EPSG integer or proj4 string.



~~~r
lead <- read.csv('data/SYR_soil_PB.csv')
lead <- st_as_sf(lead,
  coords = c('x', 'y'),
  crs = 32618)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}




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

Now that the data frame is an `sf` object, the data are easily displayed as a map.

Here, the points are colored by lead concentration (`ppm`).
{:.notes}



~~~r
plot(lead['ppm'])
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/read/unnamed-chunk-9-1.png" %})
{:.captioned}

===

For [ggplot2]({:.rlib}) figures, use `geom_sf` to draw maps. In the `aes` mapping for feature collections, 
the "x" and "y" variables are automatically assigned to the "geometry" column, 
while other attributes can be assigned to visual elements like `fill` or `color`.

===



~~~r
library(ggplot2)

ggplot(data = lead,
       mapping = aes(color = ppm)) +
  geom_sf()
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/read/unnamed-chunk-10-1.png" %})
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
blockgroups <- read_sf('data/bg_00')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

The `geometry` column contains projected UTM coordinates of the polygon vertices.



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
# A tibble: 147 x 4
   BKG_KEY   Shape_Leng Shape_Area                                      geometry
   <chr>          <dbl>      <dbl>                                 <POLYGON [m]>
 1 36067000…     13520.   6135184. ((403476.4 4767682, 403356.7 4767804, 403117…
 2 36067000…      2547.    301840. ((406271.7 4770188, 406186.1 4770270, 406107…
 3 36067000…      2678.    250998. ((406730.3 4770235, 406687.8 4770205, 406650…
 4 36067000…      3392.    656276. ((406436.1 4770029, 406340 4769973, 406307.2…
 5 36067000…      2224.    301086. ((407469 4770033, 407363.9 4770035, 407233.4…
 6 36067000…      3263.    606495. ((408398.6 4769564, 408283.1 4769556, 408181…
 7 36067000…      2878.    274532. ((407477.4 4769773, 407401 4769767, 407320.2…
 8 36067000…      3606.    331035. ((407486 4769507, 407443.5 4769504, 407405.6…
 9 36067001…      2951.    376786. ((410704.4 4769103, 410625.2 4769100, 410542…
10 36067001…      2868.    265836. ((409318.3 4769203, 409299.6 4769535, 409231…
# … with 137 more rows
~~~
{:.output}


===

Also note the table dimensions show that there are 147 features in the collection.



~~~r
> dim(blockgroups)
~~~
{:title="Console" .input}


~~~
[1] 147   4
~~~
{:.output}


===

Simple feature collections are data frames.



~~~r
> class(blockgroups)
~~~
{:title="Console" .input}


~~~
[1] "sf"         "tbl_df"     "tbl"        "data.frame"
~~~
{:.output}


===

The `blockgroups` object is a `data.frame`, but it also has the class attribute
of `sf`. This additional class extends the `data.frame` class in ways useful for
feature collection. For instance, the geometry column becomes "sticky" in most
table operations, like subsetting. This means that the geometry column is retained
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
# A tibble: 5 x 2
  BKG_KEY                                                               geometry
  <chr>                                                            <POLYGON [m]>
1 3606700010… ((403476.4 4767682, 403356.7 4767804, 403117.2 4768027, 402892.7 …
2 3606700030… ((406271.7 4770188, 406186.1 4770270, 406107.9 4770345, 406079.9 …
3 3606700030… ((406730.3 4770235, 406687.8 4770205, 406650.9 4770179, 406601 47…
4 3606700020… ((406436.1 4770029, 406340 4769973, 406307.2 4769954, 406206.5 47…
5 3606700040… ((407469 4770033, 407363.9 4770035, 407233.4 4770036, 407235.1 47…
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
![ ]({% include asset.html path="images/read/unnamed-chunk-16-1.png" %})
{:.captioned}

===

Merging with a regular data frame is done by normal merging on non-spatial
columns found in both tables.



~~~r
census <- read.csv('data/SYR_census.csv')
census <- within(census, {
     BKG_KEY <- as.character(BKG_KEY)
})
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


Here, we read in a data frame called `census` with demographic characteristics
of the Syracuse block groups.
As usual, there's the difficulty that CSV files do not include metadata on data
types, which have to be set manually. We do this here by coercing the `BKG_KEY`
column to character format using `as.character()`.
{:.notes}

===

Merge tables on a unique identifier (our primary key is "BKG_KEY"), but let the
"sf" object come first or its special attributes get lost.

The `inner_join()` function from [dplyr](){:.rlib} joins two data frames on a
common key specified with the `by` argument, keeping only the rows from each data 
frame with matching keys in the other data frame and discarding the rest.
{:.notes}



~~~r
library(dplyr)

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
[1] "sf"         "tbl_df"     "tbl"        "data.frame"
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
![ ]({% include asset.html path="images/read/unnamed-chunk-20-1.png" %})
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
tracts <- read_sf('data/ct_00')
ggplot(census_tracts,
       aes(fill = POP2000)) +
  geom_sf() +
  geom_sf(data = tracts,
          color = 'red', fill = NA)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/read/unnamed-chunk-22-1.png" %})
{:.captioned}

===

By default, the sticky geometries are summarized with `st_union`. The
alternative `st_combine` does not dissolve internal boundaries. Check
`?summarise.sf` for more details.
