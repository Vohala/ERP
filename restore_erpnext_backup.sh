#!/bin/bash

# Set absolute paths for backups and Docker volume directories
user=erp-next-admin
backup_dir_frontend=/home/$user/erp_next_backups/frontend
backup_dir_backend=/home/$user/erp_next_backups/backend
log_file=/home/$user/erp_next_backups/restore_operations.log
yml_folder_name=frappe_docker
yml_folder_path=/home/$user/$yml_folder_name

# Function to log messages with timestamp
log_message() {
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >> "$log_file"
}

# Function to find latest backup file in local storage
find_latest_backup() {
    local backup_dir=$1

    # Find latest modified backup file in local storage
    latest_backup=$(find "$backup_dir" -type f -name '*.sql.gz' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2)

    echo "$latest_backup"
}

# Function to copy latest backup to Docker container and restore
restore_backup() {
    local service=$1
    local backup_file=$2
    local site_config=$3
    local temp_backup_file=/home/frappe/frappe-bench/temp_backup.sql.gz

    # Copy latest backup file to Docker container
    docker cp "$backup_file" "$yml_folder_name-$service-1:$temp_backup_file" >> "$log_file" 2>&1
    docker cp "$site_config" "$yml_folder_name-$service-1:/home/frappe/frappe-bench/sites/frontend/site_config.json" >> "$log_file" 2>&1

    if [ $? -eq 0 ]; then
        log_message "Copied backup file $backup_file to $service container."
        
        # Change directory to where YML/YAML file is located
        cd $yml_folder_path

        # Restore backup in Docker container
	# docker cp "$backup_file" "$yml_folder_name-$service-1:$temp_backup_file" 2>&1 | tee -a "$log_file"
        docker exec "$yml_folder_name-$service-1" bench restore $temp_backup_file --db-root-password admin >> "$log_file" 2>&1

        if [ $? -eq 0 ]; then
            log_message "Restore for $service successful."
        else
            log_message "Failed to restore for $service. Check logs for details."
        fi

        # Delete temp backup to free up storage space
        docker exec "$yml_folder_name-$service-1" rm $temp_backup_file
        log_message "Deleted $temp_backup_file in $service container to free up space."
    else
        log_message "Failed to copy backup file $backup_file to $service container."
    fi
}

# Restore backups for frontend and backend services
latest_backup_frontend=$(find_latest_backup "$backup_dir_frontend")
if [ -n "$latest_backup_frontend" ]; then
    restore_backup frontend "$latest_backup_frontend" "$backup_dir_frontend/site_config.json"
else
    log_message "No backup found in $backup_dir_frontend for frontend service."
fi

latest_backup_backend=$(find_latest_backup "$backup_dir_backend")
if [ -n "$latest_backup_backend" ]; then
    restore_backup backend "$latest_backup_backend" "$backup_dir_backend/site_config.json"
else
    log_message "No backup found in $backup_dir_backend for backend service."
fi

# Add more restore operations if needed for other services
# latest_backup_<service_name>=$(find_latest_backup "<backup_dir>")
# restore_backup <service_name> "$latest_backup_<service_name>"

echo "Backup restore process completed."

