FROM mysql:8.4.11

# Files in this directory run once, in alphabetical order, when MySQL first
# initializes an empty data directory.
COPY sql/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY sql/example_data.sql /docker-entrypoint-initdb.d/02-example-data.sql

EXPOSE 3306
