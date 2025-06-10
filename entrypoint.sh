#!/bin/bash
set -e

echo "Waiting for PostgreSQL to become available..."

until pg_isready -h "$DATABASE_HOST" -p 5432 -U "$POSTGRES_USER"; do
  sleep 1
done

echo "PostgreSQL is available. Starting the app..."

# Run migrations
bundle exec rails db:prepare

# Run the main container command (e.g., Puma)
exec "$@"
