## ---- eval=FALSE, echo=FALSE--------------------------------------------------
#  remotes::install_github("paleolimbot/rbbt")
#  # run once to get citations
#  library(rbbt)
#  bbt_write_bib("vignettes/od.json", bbt_detect_citations("vignettes/od.Rmd"), overwrite = TRUE)
#  
#  # Previous attempts (all failed):
#  # system.time({
#  #   citr::tidy_bib_file(rmd_file = "vignettes/od.Rmd", messy_bibliography = "~/robinlovelace/static/bibs/allrefs.bib", file = "vignettes/od-references.bib")
#  # })
#  # in bash
#  # sudo pip3 install -U extract_bib
#  # extract_bib --bibtex-file ~/robinlovelace/static/bibs/allrefs.bib vignettes/od.Rmd vignettes/od.bib
#  # pandoc --filter pandoc-citeproc vignettes/od.Rmd -s -o vignettes/od.bib

## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = TRUE
)
options(stringsAsFactors = FALSE)

## ---- eval=FALSE--------------------------------------------------------------
#  install.packages("od")
#  # remotes::install_github("itsleeds/od") # for the dev version

## -----------------------------------------------------------------------------
library(od)

## -----------------------------------------------------------------------------
od_data_example = data.frame(
  o = "Leeds",
  d = "London"
)
od_data_example

## -----------------------------------------------------------------------------
od_data_example$trips_per_year = 10
od_data_example

## ---- eval=FALSE, echo=FALSE--------------------------------------------------
#  # get leeds and london locations
#  tmaptools::geocode_OSM("Leeds")
#  tmaptools::geocode_OSM("London")

## ----p-sf, eval=TRUE----------------------------------------------------------
p = sf::st_as_sf(
  data.frame(
    name = c("Leeds", "London"),
    lon = c(-1.5, -0.1),
    lat = c(53.8, 51.5)
    ),
  coords = c("lon", "lat"),
  crs = 4326
  )
p

## ---- eval=FALSE--------------------------------------------------------------
#  plot(p)
#  mapview::mapview(p)

## ----mapview-od, echo=FALSE, eval=TRUE----------------------------------------
knitr::include_graphics("https://user-images.githubusercontent.com/1825120/78998042-b18a2c00-7b3f-11ea-9d08-21be332633fc.png")

## -----------------------------------------------------------------------------
desire_line_example = od_to_sf(od_data_example, p)
desire_line_example

## ---- eval=FALSE--------------------------------------------------------------
#  mapview::mapview(desire_line_example)

## ----mapview-l, echo=FALSE, eval=TRUE-----------------------------------------
knitr::include_graphics("https://user-images.githubusercontent.com/1825120/78998661-f6fb2900-7b40-11ea-88a5-429f7dae31af.png")

## ----od-sf--------------------------------------------------------------------
# example data from the od package:
od = od::od_data_df
class(od)

## ----setup, eval=FALSE, echo=FALSE--------------------------------------------
#  library(stplanr)
#  library(dplyr)
#  od = stplanr::od_data_sample %>%
#    select(-matches("rail|name|moto|car|tax|home|la_")) %>%
#    top_n(n = 14, wt = all)
#  class(od)
#  od
#  od_all = od::od_data_df_medium
#  od = od_all[od_all$all > 700, ]

## -----------------------------------------------------------------------------
od

## -----------------------------------------------------------------------------
od[1:3]

## -----------------------------------------------------------------------------
od_matrix = od_to_odmatrix(od[1:3])
class(od_matrix)
od_matrix

## -----------------------------------------------------------------------------
lapply(c("all", "bicycle"), function(x) od_to_odmatrix(od[c("geo_code1", "geo_code2", x)]))

## -----------------------------------------------------------------------------
odmatrix_to_od(od_matrix)

## -----------------------------------------------------------------------------
(od_inter = od_interzone(od))
(od_intra = od_intrazone(od))

## -----------------------------------------------------------------------------
(od_min = tail(od, 3))
(od_oneway = od_oneway(od_min))

## -----------------------------------------------------------------------------
z = od::od_data_zones_min
class(z)
desire_lines = od_to_sf(od_inter, z)

## -----------------------------------------------------------------------------
class(desire_lines)
nrow(od) - nrow(desire_lines)
ncol(desire_lines) - ncol(od)

## -----------------------------------------------------------------------------
plot(desire_lines$geometry)

## -----------------------------------------------------------------------------
plot(desire_lines)

## ---- eval=FALSE--------------------------------------------------------------
#  library(tmap)
#  tmap_mode("view")
#  qtm(desire_lines)

## -----------------------------------------------------------------------------
od_geo_code2_3 = od$geo_code2[3]
od$geo_code2[3] = "nomatch"
od_to_sf(od, z)

## -----------------------------------------------------------------------------
od$geo_code2[3] = od_geo_code2_3

## -----------------------------------------------------------------------------
subzones = od_data_zones_small
od_disaggregated = od_disaggregate(od = od, z = z, subzones = subzones)
plot(od_data_zones_min$geometry, lwd = 3)
plot(od_data_zones_small$geometry, lwd = 1, add = TRUE)
plot(desire_lines$geometry, lwd = 5, col = "red", add = TRUE)
plot(od_disaggregated$geometry, lwd = 0.4, col = "blue", add = TRUE)
# plot(od_disaggregated$geometry[1:5])

## -----------------------------------------------------------------------------
sapply(3:10, function(i) sum(od[[i]]))
sapply(3:10, function(i) sum(od_disaggregated[[i]]))

## -----------------------------------------------------------------------------
od_disaggregated2 = od_disaggregate(od = od_data_df[1:2, ], z, od_data_buildings)
plot(od_data_buildings$geometry)
plot(od_disaggregated2$geometry, add = TRUE, lwd = 0.1)

## ---- echo=FALSE, eval=FALSE--------------------------------------------------
#  # various attempts highlighting possible issues with od_disaggregate
#  buildings = od_data_buildings
#  od_minimal = od_data_df[1:2]
#  od_disaggregated2 = od_disaggregate(od = od_minimal, z = z, subzones = buildings)
#  sub_points = sf::st_sample(x = z, size = rep(50, nrow(z)))
#  sub_points_sf = sf::st_as_sf(sub_points)
#  sub_zones_sf = sf::st_as_sf(sf::st_buffer(sub_points, dist = 0.001))
#  plot(z$geometry)
#  plot(sub_zones_sf, add = TRUE)
#  # currently only assigns to 1st point in each zone it seems:
#  # od_disaggregated2 = od_disaggregate(od, z, subpoints = sub_points_sf)
#  od_disaggregated2 = od_disaggregate(od, z, sub_zones_sf)
#  plot(od_disaggregated2$geometry, add = TRUE)
#  plot(od_disaggregated2[1:50, ])
#  # od_disaggregated2 = od_disaggregate(od = od, z = z, subzones = buildings) # error

