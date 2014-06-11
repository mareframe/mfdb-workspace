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
