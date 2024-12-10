CONTAINER_NAME="frappe_docker-backend-1"
NEW_PASSWORD="1234"

echo "Entering Docker container: $CONTAINER_NAME"
sudo docker exec -it "$CONTAINER_NAME" bash -c "
    cd /home/frappe/frappe-bench/sites &&
    bench set-admin-password $NEW_PASSWORD
"
