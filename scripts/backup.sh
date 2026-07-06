#!/bin/bash

set -e

CONTAINER="hotel-postgres"
USER="postgres"
DB="hoteldb"

BACKUP_DIR="backups"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

BACKUP_FILE="$BACKUP_DIR/hoteldb_${TIMESTAMP}.sql"

echo "Creating backup..."

docker exec "$CONTAINER" pg_dump \
-U "$USER" \
-d "$DB" \
> "$BACKUP_FILE"

echo "Backup created successfully."

echo "Location: $BACKUP_FILE"