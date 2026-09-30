library(tidycensus)
# total_population_10 <- get_decennial(
#   geography = "state", 
#   variables = "P001001",
#   year = 2010
# )
# 
# dec20 <- load_variables(year = 2020, dataset = "pl")
# total_population_20 <- get_decennial(
#   geography = "state", 
#   variables = "P1_001N",
#   year = 2020
# )

utah_migration_19 <- get_flows(
  geography = "county",
  state = "UT",
  year = 2019
)

utah_migration_20 <- get_flows(
  geography = "county",
  state = "UT",
  year = 2020
)

utah_migration_21 <- get_flows(
  geography = "county",
  state = "UT",
  year = 2021
)

utah_migration_22 <- get_flows(
  geography = "county",
  state = "UT",
  year = 2022
)

utah_migration <- rbind(utah_migration_19 |> mutate(year = 2019), 
                        utah_migration_20 |> mutate(year = 2020),
                        utah_migration_21|> mutate(year = 2021),
                        utah_migration_22|> mutate(year = 2022))

utah_population_20 <- get_decennial(
  geography = "county", 
  state="UT",
  variables = "P1_001N",
  year = 2020,
  geometry = TRUE
)

library(tigris)

#ut_counties <- counties(state="UT")

#ut_counties |> ggplot() + geom_sf() + ggthemes::theme_map()


ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME, year) |>
  summarize(
    move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
    move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
  )

ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))


