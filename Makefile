R = R_LIBS=$(shell pwd)/Rpackages R --vanilla
CRAN_REPOS = c("http://cran.uk.r-project.org")

PGDIR = $(shell dirname `ls -1 /usr/lib/postgresql/9.*/bin/initdb /usr/bin/initdb /bin/initdb 2>/dev/null | head -1`)
PGDATA = pgdata
PGNAME = mf
PGSOCKET = /tmp/pg_mfdb

all: dependencies check install

mfdb/:
	[ ! -d mfdb/.git ] && { git clone git://github.com/mareframe/mfdb.git ; cd mfdb && git remote set-url --push origin git@github.com:mareframe/mfdb.git; } || true
	cd mfdb && git pull

$(PGDATA):
	$(PGDIR)/initdb -D $(PGDATA)

db_start: $(PGDATA)
	rmdir $(PGSOCKET) || true
	mkdir $(PGSOCKET)
	$(PGDIR)/postmaster -D "$(PGDATA)" \
	                    --unix_socket_directories="$(PGSOCKET)" \
	                    --listen_addresses=""

db_create:
	$(PGDIR)/createdb -h $(PGSOCKET) $(PGNAME)

db_shell:
	$(PGDIR)/psql -h $(PGSOCKET) $(PGNAME)

# One can't install one thing locally and another from repo, so install
# dependencies manually
dependencies: mfdb/
	/bin/echo -E 'install.packages(Filter(nzchar, unlist(strsplit(read.dcf("mfdb/DESCRIPTION")[,"Imports"], "\\W+"))), dependencies = TRUE, repos = $(CRAN_REPOS))' | $(R)
	/bin/echo -E 'install.packages(Filter(nzchar, unlist(strsplit(read.dcf("mfdb/DESCRIPTION")[,"Suggests"], "\\W+"))), dependencies = TRUE, repos = $(CRAN_REPOS))' | $(R)

mfdb_1.0.tar.gz: R/*.R tests/*.R tests/testthat/*.R
	$(R) CMD build mfdb

check: mfdb_1.0.tar.gz
	$(R) CMD check mfdb_1.0.tar.gz

install:
	$(R) CMD INSTALL --install-tests --html --example mfdb

test: install
	/bin/echo -E "for (f in list.files('mfdb/tests', full.names = TRUE)) source(f, chdir = TRUE)" | $(R) --slave

shell: install
	R_DEVPKG=mfdb R_LIBS=$(shell pwd)/Rpackages R --no-save --no-environ

# Individual R files require no comilation
R/*.R: 

tests/*.R:

tests/testthat/*.R:

.PHONY: dependencies check install test db_start db_create db_shell
