#!/bin/bash

# Set absolute paths for logs and backup directories
backup_dir_frontend=/home/erp_next_user/erp_next_backups/frontend
backup_dir_backend=/home/erp_next_user/erp_next_backups/backend
log_file=/home/erp_next_user/erp_next_backups/backup_operations.log
frappe_docker_folder_name=frappe_docker_old
frappe_docker_folder_path=/home/erp_next_user/$frappe_docker_folder_name

# Ensure directories exist
mkdir -p "$backup_dir_frontend"
mkdir -p "$backup_dir_backend"

# Function to log messages with timestamp
log_message() {
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >> "$log_file"
}

# Change directory to where Docker Compose file is located
cd $frappe_docker_folder_path

# Function to perform backup and log output
perform_backup() {
    local service=$1
    local backup_dir=$2

    log_message "Performing backup for $service..."
    docker compose exec "$service" bench backup >> "$log_file" 2>&1
    if [ $? -eq 0 ]; then
        log_message "Backup for $service successful."
    else
        log_message "Backup for $service failed."
    fi
}

# Function to copy latest backup from Docker volume to local host
copy_latest_backup() {
    local service=$1
    local backup_dir=$2
    
    # Copy latest backup file
    latest_backup=$(docker cp "$service-1:$(docker exec "$service-1" find /home/frappe/frappe-bench/sites/frontend/private/backups -type f -name '*.sql.gz' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2)" "$backup_dir/" 2>&1)

    if [ $? -eq 0 ]; then
        log_message "Successfully copied latest backup for $service."
    else
        log_message "Failed to copy latest backup for $service: $latest_backup"
    fi

    # Copy site_config.json file
    site_config_copy=$(docker cp "$service-1:/home/frappe/frappe-bench/sites/frontend/site_config.json" "$backup_dir/" 2>&1)

    if [ $? -eq 0 ]; then
        log_message "Successfully copied site_config.json for $service."
    else
        log_message "Failed to copy site_config.json for $service: $site_config_copy"
    fi
}

# Perform backups and copy operations
perform_backup frontend "$backup_dir_frontend"
perform_backup backend "$backup_dir_backend"

copy_latest_backup $frappe_docker_folder_name-frontend "$backup_dir_frontend"
copy_latest_backup $frappe_docker_folder_name-backend "$backup_dir_backend"

# Optionally, backup for db service (uncomment and adjust paths as needed)
#docker cp frappe_docker-db-1:/path/to/backups /path/on/your/host/backups
