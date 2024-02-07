# This script generates a file with the boundaries of WCA's LSOAs and Wards.


# Approach A: select only wards/lsoas from childcare dataset --------------

# In this case, we will use the childcare costs dataset as ground truth. We'll
# download all the lsoas/ward and only select those regions whose ID is listed
# in the csv. We will later save the resulting files in a geopackage.

library(sf)

# Load "ground truth" dataset.
childcare_costs <- read.csv("wmca-childcare-costs.csv")

# This dataset contains a column, GeographyID, that contains the codes for the
# regions. Regretfully, this field contains codes from ward and lsoas, according
# to ONS' lookup file:

# Rename columns
#colnames(childcare_costs)[3:3] <- c("cost", "percent")
# Convert to numbers
#childcare_costs$cost <- as.numeric(gsub("[^0-9.-]", "", childcare_costs$cost))
#childcare_costs$percent <- as.numeric(gsub("[^0-9.-]", "", childcare_costs$percent))


# Read all ward regions, downloaded from: https://geoportal.statistics.gov.uk/datasets/8070640af6f34c59913e3e57c436560a_0/explore?location=53.619587%2C-1.261687%2C7.09
ward <- st_read("data/raw/Wards_December_2023_Boundaries_UK_BFC_-7600351869067957253.gpkg")

# Select just wards from WCA
wca_ward <- ward[ward$WD23CD %in% childcare_costs$GeographyID,]

# Save to spatial file, in geopackage format:
st_write(wca_ward, "data/output/wca_ward.gpkg",  delete_dsn = TRUE)


# LSOA
# File downloaded from ONS: https://geoportal.statistics.gov.uk/datasets/ons::lsoa-dec-2021-boundaries-full-clipped-ew-bfc/about
lsoas <- st_read("data/raw/LSOA_Dec_2021_Boundaries_Full_Clipped_EW_BFC_2022_-6437031168783062454.gpkg")

# Select just lsoas within WCA
wca_lsoas <- lsoas[lsoas$LSOA21CD %in% childcare_costs$GeographyID,]

# Save to spatial file
st_write(wca_lsoas, "data/output/wca_lsoas.gpkg", delete_dsn = TRUE)


# Approach B: Spatial selection -------------------------------------------

# Overview:
# 1. Download combined authorities boundaries
# 2. Select only WCA boundary
# 3. Download all lsoas
# 4. Select lsoas that are contained within WCA boundary (not finished)

# Get WCA boundaries ------------------------------------------------------

# Combined authorities' boundaries can be downloaded from ONS' geoportal:
# https://geoportal.statistics.gov.uk/datasets/6dde9669f5954661800329668fe474c2_0/explore?location=53.507958%2C-1.281912%2C7.94
# Boundaries can be downloaded in different spatial formats: geopackages,
# shapefiles, geojson... While shapefiles may be a de facto standard, they are
# not the best file format (read http://switchfromshapefile.org/ for more info).
# We will be using geojson because a simple plain text file (technically, a json
# file).

library(sf)

# Read the json file downloaded from ONS.
ca_boundaries <- st_read("data/raw/Combined_Authorities_December_2022_EN_BGC_5631883247521478017.geojson")
ca_boundaries <- st_read("data/raw/Combined_Authorities_December_2022_EN_BGC_8201486104719190323.gpkg") 
st_set_crs()

wca_boundaries <- ca_boundaries |> 
  filter(CAUTH22NM == "West Midlands")


# Subsetting --------------------------------------------------------------

# The file contains all combined authorities, but we only need the West
# Midlands, so we will be subsetting. For more information refer to
# https://r-spatial.github.io/sf/articles/sf4.html#subsetting-feature-sets
wca_boundaries <- ca_boundaries[ca_boundaries$CAUTH22NM == "West Midlands",]


# Saving to a file --------------------------------------------------------

st_write(wca_boundaries, "data/output/wca_boundaries.gpkg", delete_dsn = TRUE)

# TODO: select the features within the boundary. Regretfully, the resolution is
# different, and there are some regions that are not fully contained within WCA.