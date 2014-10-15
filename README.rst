Mareframe MFDB Workspace
========================

This repository aids development of the MFDB package, it is not essential for
MFDB usage. It will keep mfdb and associated R packages locally in
``Rpackages``, so they don't need to be installed on the system

Installing
----------

Firstly, ensure you have all requried dependencies. If using Debian / Ubuntu:

    aptitude install postgresql-9.3 postgresql-server-9.3 libpq-dev

If using CentOS / Fedora:

    yum install postgresql-server postgresql-devel

And then run make:

    make

This will download the ``mfdb`` package, install required dependencies, run
``CMD check`` and finally install into ``Rpackages``.

Creating a database
-------------------

You can create a database in the local directory for mfdb to use. In a new
window, run:

    make db_start

Then, run:

    make db_create

Finally, you can use:

    make db_shell

...to connect to the database. To actually create data tables, see the mfdb
package documentation.

Development
-----------

You can run ``make test`` and ``make check`` to run unit tests and ``R CMD
check`` on the mfdb package.

Integration tests
-----------------

There are also tests you can run against the database you created with
``db_create``, run ``make inttest`` to run these.

*NB:* These will destroy any data stored in the database first.
