# money

## Run the database

Requires Docker and `make`.

```bash
make build
MYSQL_ROOT_PASSWORD='choose-a-strong-password' make run
```

Data persists in Docker's `money-db-data` volume. The schema and example data are loaded only when that volume is first created.

## Test

Run the MySQL integration suite in Docker Compose:

```bash
make test
```

Compose starts an isolated database container, waits for its health check, and runs the Python tests from a separate container. Dependencies are managed with `uv`; the tests connect to MySQL asynchronously through `aiomysql`.
