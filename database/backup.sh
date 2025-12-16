#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
BACKUP_FILE="db_backup_$DATE.sql"
DB_USER="realworld"
DB_NAME="realworld"
DB_HOST="localhost"
COMPRESSION="gzip"
LOG_FILE="$BACKUP_DIR/backup_log.log"

until pg_isready -h $DB_HOST -p 5432; do
    echo "waiting for database to start..." | tee -a $LOG_FILE
    sleep 2
done


echo "Starting database backup..." | tee -a $LOG_FILE
if pg_dump -U $DB_USER -h $DB_HOST -F c $DB_NAME > "$BACKUP_DIR/$BACKUP_FILE"; then
    echo "Database dump completed successfully." | tee -a $LOG_FILE
    if $COMPRESSION "$BACKUP_DIR/$BACKUP_FILE"; then
        echo "Backup file compressed successfully to $BACKUP_FILE.$COMPRESSION" | tee -a $LOG_FILE
    else
        echo "Error during compression of backup file." | tee -a $LOG_FILE
        exit 1
    fi
else
    echo "Error during database dump." | tee -a $LOG_FILE
    exit 1
fi

echo "Sending push notification..." | tee -a $LOG_FILE
curl -d "Database backup completed: $DB_NAME at $DATE" \
     -X POST https://ntfy.sh/database-backups | tee -a $LOG_FILE

echo "Database backup process completed..." | tee -a $LOG_FILE