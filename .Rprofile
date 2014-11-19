if (file.exists("~/.Rprofile"))
    source("~/.Rprofile")

.libPaths("./Rpackages")

if (nzchar(Sys.getenv('R_DEVPKG'))) {
    cat("Loading", Sys.getenv('R_DEVPKG'), "library, run reinstall() to reinstall\n")
    library(Sys.getenv('R_DEVPKG'), character.only = TRUE)
}

reinstall <- function (name = Sys.getenv('R_DEVPKG')) {
    pkg <- paste0("package:", name)
    if (pkg %in% search()) {
        detach(name = pkg, unload=TRUE, character.only = TRUE)
    }
    utils::install.packages(name, repos=NULL, lib="./Rpackages")
    library(name, character.only = TRUE)
}

library(logging)
addHandler(writeToConsole, logger='mfdb', level='DEBUG')

import_generated_survey <- function (mdb, data_source, count) {
    choose <- function(t, n) {
        t[sample.int(length(t), n, replace = TRUE), "name"]
    }

    mfdb_import_survey(mdb,
        data.frame(
            year = sample(1990:1999, 1, replace = TRUE), # NB: All in the same year
            month = sample(1:12, count, replace = TRUE),
            areacell = sample(c('a','b','c','d','e','f'), count, replace = TRUE),
            species = choose(mfdb::species, 2),
            age = sample(10:100, count, replace = TRUE),
            sex = choose(mfdb::sex, count),
            length = sample(100:1000, count, replace = TRUE),
            weight = sample(100:1000, count, replace = TRUE),
            count = 1),
        institute = choose(mfdb::institute, 1),
        gear = choose(mfdb::gear, 1),
        vessel = choose(mfdb::vessel, 1),
        sampling_type = choose(mfdb::sampling_type, 1),
        data_source = data_source)
}
