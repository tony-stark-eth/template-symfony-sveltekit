-- Creates the test database used by the integration test suite.
-- This script runs automatically on first container startup via
-- /docker-entrypoint-initdb.d/. It runs as the POSTGRES_USER (app).

CREATE DATABASE app_test;
GRANT ALL PRIVILEGES ON DATABASE app_test TO app;
