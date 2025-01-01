#!/bin/sh

# Wait for the database to be ready
echo "Waiting for the database to be ready..."
while ! nc -z db 5432; do
  sleep 1
done
echo "Database is ready."

# Run database migrations
echo "Running database migrations..."
mix ecto.migrate

# Start the Phoenix server
echo "Starting the Phoenix server..."
exec mix phx.server
