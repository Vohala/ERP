#!/bin/bash

# Function to remove Docker
remove_docker() {
    echo "Removing Docker..."

    # Prune stopped containers
    docker container prune -f
    
    # Remove ERP next images
    docker image rm frappe/erpnext:v15.30.0 mariadb:10.6 redis:6.2-alpine
    
    # Stop Docker service if running
    sudo systemctl stop docker

    # Remove Docker packages
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io

    # Remove Docker data directory
    sudo rm -rf /var/lib/docker

    # Remove Docker group
    sudo groupdel docker

    # Clean up residual dependencies and configuration files
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y

    echo "Docker removal completed."
}

# Function to remove Frappe
remove_frappe() {
    echo "Removing Frappe..."

    # Frappe directory path
    FRAPPE_DIR="/home/erp-next-admin/frappe_docker"

    # Stop and remove Docker containers related to Frappe
    echo "Stopping and removing Frappe Docker containers..."
    docker-compose -f $FRAPPE_DIR/docker-compose.yml down

    # Remove Frappe directory
    echo "Removing Frappe directory..."
    sudo rm -rf $FRAPPE_DIR

    # Optionally remove Docker volumes associated with Frappe
    echo "Removing Frappe Docker volumes..."
    docker volume prune -f

    echo "Frappe removal completed."
}

# Call the functions
remove_docker
remove_frappe

echo "Uninstallation of Docker and Frappe completed."
