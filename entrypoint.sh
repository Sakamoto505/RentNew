#!/bin/bash
set -e

rm -f /app/tmp/pids/server.pid

export PGPASSWORD="VRu^FwGV5D%Twaz_forest"
until psql -h "db" -U "new_rent" -d "new_rent_development" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing commands"

# Создание и миграция базы данных
bundle exec rails db:create 2>/dev/null || true


exec "$@"
