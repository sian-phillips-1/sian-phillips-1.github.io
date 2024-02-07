# This script creates a choropleth map with WMCA's Childcare costs. To do so,
# and besides the csv with childcare costs, we need another dataset with the
# geometries with WMCA's administrative boundaries.


# Childcare costs ---------------------------------------------------------

# Dataset provided by guest lecturer, Si Chun Lam:
# https://github.com/sichunlam/sichunlam.github.io/blob/master/childcare-costs/wmca-childcare-costs.csv
childcare_costs <- read.csv("wmca-childcare-costs.csv")

# Explore dataset
head(childcare_costs)

# This dataset contains a column, GeographyID, that contains the codes for the
# regions, and two columns: one with actual costs, in £, and the percentage.
# Regretfully, it has the following issues:
# 1. Long column names
# 2. Values are strings, due to having character symbols: £ and %.
# 3. GeographyID contains codes for different types of regions (we'll see that 
# later)

# Rename columns to address problem #1
colnames(childcare_costs)[2:3] <- c("cost", "percent")

# Convert to numbers after removing non numeric characters (problem #2)
childcare_costs$cost <- as.numeric(gsub("[^0-9.-]", "", childcare_costs$cost))
childcare_costs$percent <- as.numeric(gsub("[^0-9.-]", "", childcare_costs$percent))

head(childcare_costs)


# Spatial data ------------------------------------------------------------

# To create a map we need a file containing the boundaries (polygons) of the
# administrative regions within WMCA. This file has been provided to you. IF you
# want to know how it was generated refer to data_preparation.R

library(sf)

wmca_lsoas <- st_read("wca_lsoas.gpkg")

plot(wmca_lsoas["LSOA21CD"])


# Joining data -------------------------------------------------------------

# We need to merge the two datasets (a regular dataframe with the data, and a sf object with the boundaries). To do so, we need to merge them by a shared attribute/column. It's worth no
childcare_costs_lsoas <- merge(wmca_lsoas, childcare_costs, 
                               by.x = "LSOA21CD", by.y = "GeographyID")


# Plot the map ------------------------------------------------------------

# sf extends base R's plot(), so we can use the parameters we are familiar with. 
# More info: https://r-spatial.github.io/sf/articles/sf5.html

plot(childcare_costs_lsoas["cost"], main = "childcare cost")

# As you know, this map can be dramatically improved to better communicate our
# findings, i.e., colour scale, cutters, legend, title...


# Plotting a map with mapsf -----------------------------------------------

# For the sake of comparing defaults, this is an alternative, more opinionated
# (and probably less customisable) approach.
# More info: https://riatelab.github.io/mapsf/

library(mapsf)

mf_map(x = childcare_costs_lsoas, type = "choro",
       var = "cost", method = "quantile", border=FALSE)
mf_map(x = childcare_costs_lsoas, type = "choro",
			 var = "percent", method = "quantile", border=FALSE)
