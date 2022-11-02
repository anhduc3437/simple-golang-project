#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO
    \$\$
    BEGIN
        IF EXISTS (
            SELECT FROM pg_catalog.pg_roles WHERE  rolname = '$POSTGRES_USER')
        THEN
            RAISE NOTICE 'Role $POSTGRES_USER already exists.';
        ELSE
            CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
        END IF;

        CREATE EXTENSION IF NOT EXISTS dblink;
        IF EXISTS 
            (SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB') 
        THEN
            RAISE NOTICE 'Database already exists';
        ELSE
            PERFORM dblink_connect('host=localhost user=' || $POSTGRES_USER || ' password=' || $POSTGRES_PASSWORD || ' dbname=' || current_database());
            PERFORM dblink_exec('CREATE DATABASE ' || $POSTGRES_DB);
        END IF;
    END
    \$\$;

    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
EOSQL