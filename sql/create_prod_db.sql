-- Terminate activity on DB before dropping it. See https://stackoverflow.com/questions/7073773/drop-postgresql-database-through-command-line
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='iatlas';
-- Drop the dev database if it already exists.
DROP DATABASE IF EXISTS iatlas;

-- Create the dev database (used for development).
CREATE DATABASE iatlas;

-- Connect to the database.
\connect iatlas

-- Include the common table building SQL.
\ir create_enums.sql
