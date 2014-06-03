mfdb_1.0.tar.gz: R/*.R tests/*.R tests/testthat/*.R
	R_LIBS=$(shell pwd)/Rpackages R CMD build mfdb

check: mfdb_1.0.tar.gz
	R_LIBS=$(shell pwd)/Rpackages R CMD check mfdb_1.0.tar.gz

install:
	R CMD INSTALL --install-tests mfdb

test: install
	echo "library(testthat); library(mfdb); test_package('mfdb')" | R_LIBS=$(shell pwd)/Rpackages R --vanilla

# Individual R files require no comilation
R/*.R: 

tests/*.R:

tests/testthat/*.R:

.PHONY: check install test
