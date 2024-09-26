## Sold Price Model

library(dplyr)
library(ggplot2)
library(tidyverse)
library(caret)
library(vetiver)
library(pins)
library(plumber)

con <- DBI::dbConnect(
  duckdb::duckdb(), 
  dbdir = "my-db.duckdb")

housing_data <- dplyr::tbl(con, "housing")

housing_data |> 
  ggplot() + 
  geom_histogram(mapping = aes(x = Sold.Price)) +
  scale_x_log10()

housing_data |>
  ggplot(mapping = aes(x = Total.SqFt., y = Sold.Price)) +
  geom_point() +
  geom_smooth()   

housing_data |> 
  ggplot(mapping = aes(x = Geo.Lon, y = Geo.Lat, color = Sold.Price)) +
  geom_point() +
  scale_color_viridis_c(trans = "log10")


sold_price_model <- train(Sold.Price ~ .,
                          data = housing_data,
                          method = "knn",
                          tuneGrid = data.frame(k=15))

v_model = vetiver_model(sold_price_model, model_name = 'sold_price_model')

model_board <- board_temp(versioned = TRUE)
model_board |> vetiver_pin_write(v_model)

pr() |>
  vetiver_api(v_model) |>
  pr_run(port = 8080)

DBI::dbDisconnect(con)









