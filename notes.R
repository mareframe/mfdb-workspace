# TMPDIR=$(fullpath tmp) R
# install.packages("RPostgreSQL", lib="./Rpackages/")
# install.packages("logging", lib="./Rpackages/")
# install.packages("futile.logger", lib="./Rpackages/")
library(DBI, lib.loc="./Rpackages/")
library(RPostgreSQL, lib.loc="./Rpackages/")

# drv <- dbDriver("PostgreSQL")
# con <- dbConnect(drv, dbname="dw0605", user="dst2w", host="/tmp/")

con <- dbConnect(dbDriver("PostgreSQL"),
    dbname="dw0605",
    user="mfdb",
    host="/srv/devel/work/mareframe.mfdb/sock/")

names(dbGetInfo(con))

rs <- dbSendQuery(con, "SELECT ")


###### Development tools
# aptitude install libcurl3-openssl-dev
install.packages("devtools", lib="./Rpackages/")
library(devtools, lib.loc="./Rpackages/")

# install_github won't let you set lib
.libPaths(new = c("./Rpackages/", "/usr/local/lib/R/site-library", "/usr/lib/R/site-library", "/usr/lib/R/library"))
install_github("pryr")
library(pryr)

# Loading individual files
source("R/gadgetfile.R")

# Run all tests
library(devtools, lib.loc="./Rpackages/")
test()

# Re-load all code within R/
library(devtools, lib.loc="./Rpackages/")
load_all()

# Run individual test
source('tests/testthat/test_gadgetcomponent.R')


###### Generic functions
# Can look up what methods are available:-
methods(str)


test_run <- function(mdb) {
    load_all()
    mfdb_get_meanlength(mdb, params = list(
            years = c(2000),
            areas = c("101", "102", "103"),
            species = "COD",
            lengthcellmin = 250,
            lengthcellmax = 500,
            agemin = 2,
            agemax = 3,
            lengthcell = 30))
}
