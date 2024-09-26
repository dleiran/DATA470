con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "my-db.duckdb")
DBI::dbWriteTable(con, "housing", housing_data)
DBI::dbDisconnect(con)