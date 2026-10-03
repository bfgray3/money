## money

## Run the database

Requires Docker and `make`.

```bash
make build
MYSQL_ROOT_PASSWORD='choose-a-strong-password' make run
```

The database is available at `127.0.0.1:3306` and is named `money`. Connect
with a MySQL client using the root password you supplied:

```bash
mysql -h 127.0.0.1 -P 3306 -u root -p money
```

Data persists in Docker's `money-db-data` volume. The schema and example data
are loaded only when that volume is first created.
