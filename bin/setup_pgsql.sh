#!/bin/sh

user=pearlbee_user
password=G0P3arlB33G0
database=pearlbee

psql -c "CREATE USER $user WITH LOGIN ENCRYPTED PASSWORD '$password';"
createdb $database --owner $user
psql -d $database -c "ALTER ROLE $user SET search_path TO 'public';"
psql -d $database -U $user -f db_patches/setup_pgsql.sql
psql -d $database -c "GRANT USAGE ON SCHEMA public TO $user;"
psql -d $database -c "GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA public TO $user;"
