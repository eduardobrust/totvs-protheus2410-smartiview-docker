#!/bin/bash
set -e

echo "🛠️ Recriando template1 com WIN1252 e C..."

psql --username "$POSTGRES_USER" <<-EOSQL
    UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';
    DROP DATABASE template1;
    CREATE DATABASE template1 WITH ENCODING = 'WIN1252' LC_COLLATE = 'C' LC_CTYPE = 'C' template = template0;
    UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';
EOSQL
