#!/bin/bash

set -e

CONTAINER="hotel-postgres"
USER="postgres"
DB="hoteldb"

LATEST_BACKUP=$(ls -t backups/*.sql | head -n1)

echo "Using backup:"
echo "$LATEST_BACKUP"

docker exec "$CONTAINER" dropdb \
-U "$USER" \
--if-exists \
"$DB"

docker exec "$CONTAINER" createdb \
-U "$USER" \
"$DB"

cat "$LATEST_BACKUP" | docker exec -i "$CONTAINER" psql \
-U "$USER" \
-d "$DB"

echo "Restore completed successfully."