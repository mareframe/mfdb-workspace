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
	[ -e "$(PGDIR)/initdb" ] || { "Cannot find initdb"; exit 1; }
	$(PGDIR)/initdb -D $(PGDATA)

db_start: $(PGDATA)
	[ -e "$(PGDIR)/postmaster" ] || { "Cannot find postmaster"; exit 1; }
	rmdir $(PGSOCKET) || true
	mkdir $(PGSOCKET)
	$(PGDIR)/postmaster -D "$(PGDATA)" \
	                    -c log_statement=all \
	                    --unix_socket_directories="$(PGSOCKET)" \
	                    --listen_addresses=""

db_create:
	[ -e "$(PGDIR)/createdb" ] || { "Cannot find createdb"; exit 1; }
	$(PGDIR)/createdb -h $(PGSOCKET) $(PGNAME)

db_shell:
	[ -e "$(PGDIR)/psql" ] || { "Cannot find psql"; exit 1; }
	$(PGDIR)/psql -h $(PGSOCKET) $(PGNAME)

# One can't install one thing locally and another from repo, so install
# dependencies manually
dependencies: mfdb/
	/bin/echo -E 'install.packages(Filter(nzchar, unlist(strsplit(read.dcf("mfdb/DESCRIPTION")[,"Imports"], "\\W+"))), dependencies = TRUE, repos = $(CRAN_REPOS))' | $(R)
	/bin/echo -E 'install.packages(Filter(nzchar, unlist(strsplit(read.dcf("mfdb/DESCRIPTION")[,"Suggests"], "\\W+"))), dependencies = TRUE, repos = $(CRAN_REPOS))' | $(R)

check: R/*.R tests/*.R
	rm mfdb_*.tar.gz 2>/dev/null || true
	$(R) CMD build mfdb && $(R) CMD check mfdb_*.tar.gz

install:
	$(R) CMD INSTALL --install-tests --html --example mfdb

test: install
	/bin/echo -E "for (f in list.files('mfdb/tests', full.names = TRUE)) source(f, chdir = TRUE)" | $(R) --slave

inttest: test
	for f in */demo/inttest-*.R; do echo "=== $$f ============="; Rscript $$f || break; done

example-iceland example-datras: install
	rm -r $@-model || true
	mkdir $@-model
	cp $@-model.baseline/timings $@-model/timings
	echo -n $$(git --git-dir=mfdb/.git log --pretty=format:'%h %s %d' --abbrev-commit HEAD^..HEAD) >> $@-model/timings
	R_LIBS=$(shell pwd)/Rpackages \
	    time -ao$@-model/timings \
	         --format=" %U user %S system %E elapsed %P CPU" \
	         R --vanilla < mfdb/demo/$@.R > $@-model/stdout
	find $@-model -type f -print0 | xargs -0 sed -ri 's/^(\; Generated by mfdb).*/\1/'
	git diff --no-index --color-words $@-model.baseline $@-model

shell: install
	R_DEVPKG=mfdb R_LIBS=$(shell pwd)/Rpackages R --no-save --no-environ

documentation: install
	cp -vr Rpackages/mfdb mareframe.github.io/packages/
	cd mareframe.github.io && git add -A && git commit -av

# Individual R files require no comilation
R/*.R: 

tests/*.R:

.PHONY: dependencies check install test db_start db_create db_shell
