R = R_LIBS=$(shell pwd)/Rpackages R --vanilla
CRAN_REPOS = c("http://cran.uk.r-project.org")

# One can't install one thing locally and another from repo, so install
# dependencies manually
dependencies:
	echo 'install.packages(Filter(nzchar, unlist(strsplit(read.dcf("mfdb/DESCRIPTION")[,"Imports"], "\\\\W+"))), dependencies = TRUE, repos = $(CRAN_REPOS))' | $(R)

mfdb_1.0.tar.gz: R/*.R tests/*.R tests/testthat/*.R
	$(R) CMD build mfdb

check: mfdb_1.0.tar.gz
	$(R) CMD check mfdb_1.0.tar.gz

install:
	$(R) CMD INSTALL --install-tests --html --example mfdb

test: install
	echo "library(testthat); library(mfdb); test_package('mfdb')" | $(R)

shell: install
	R_DEVPKG=mfdb R_LIBS=$(shell pwd)/Rpackages R --no-save --no-environ

# Individual R files require no comilation
R/*.R: 

tests/*.R:

tests/testthat/*.R:

.PHONY: dependencies check install test
