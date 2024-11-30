# Important scripts for [Frappe ERP Next Docker](https://github.com/frappe/frappe_docker) LAN Setup 

### Note: All `.sh` scripts here are to be made executable by running `chmod +x <script_name>.sh`, and then run using `<script_path>.sh` (eg: `./restore_erpnext_backup.sh`)

## Steps for Default ERP Next Docker Deployment:
1. Install Docker on client machine using script using `curl -fsSL https://get.docker.com | bash`
2. Clone Frappe Docker repo and enter it: `git clone https://github.com/frappe/frappe_docker && cd frappe_docker`
3. Run `docker compose -f pwd.yml up -d`

## Steps for Custom ERP Next deployment:
1. Create custom image as per client requirements by running `custom_image_setup.sh`, save it to zip file using `docker save`
2. Create custom `YAML` file for Docker Compose as per above (refer `gin_erpnext_hrms.yaml` for an example)
3. Install Docker on client machine using script using `curl -fsSL https://get.docker.com | bash` (Bring along custom image and custom YAML for deployment)
4. Load Docker image using `docker load`
5. Run containers using `docker compose -f <custom_file>.yaml up -d` 
6. Create backup folder and schedule as per client requirements, make changes in create `create_erpnext_backup.sh` accordingly
7. (Optional) Restore backup using `restore_erpnext_backup.sh`, provide name of folder in which in `YAML` file is stored 

## Useful Commands:
1. `docker ps`: Show details of running containers (add `-a` flag for all containers)
2. `docker compose -f <custom_file>.yaml up`: Start ERP Next containers gracefully (Use `-d` flag at the end to run in background)
3. `docker compose -f <custom_file>.yaml down`: Stop running ERP Next containers gracefully
4. `docker images`: Show images present on system
5. `docker exec -it <container_name/id> bash`: open bash terminal to inspect particular container
6. `docker logs -f <container_name/id>`: follow logs of a particular container (remove `-f` to just view logs)
7. `docker save <image_name:image_tag> | gzip > <image_name-image_tag>.tar.gz`: save docker image to tar.gz compressed file
8. `docker load`: load docker image (run in the same folder where the docker save file is present)
9. `docker system prune`: prunes all stopped containers, dangling images, unused networks and unused build cache (-a for all images, -f for no warning prompt, --volumes to prune volumes too)
10. `docker container rm $(docker container ls -aq)`: delete all containers (use when compose down doesn't remove all containers)
11. `docker volume rm $(docker volume ls -q)`: delete all volumes (use when pruning doesnt remove all volumes)

## Troubleshooting:
1. Network not found error: `docker compose down`, `docker system prune` and then `docker compose up`. Use restore script to restore data, this should resolve the issue.
2. `create-site-1` container exiting with error code 1:
    * `docker compose -f <custom_file>.yaml down`
    * `docker system prune --volumes`
    * `docker container rm $(docker container ls -aq)`
    * `docker volume rm $(docker volume ls -q)`
    * `docker compose -f <file_name>.yaml up`
    * This method should lead to `create-site-1` container installing frappe, ERP Next and HRMS modules successfully, exiting with code 0
    * Finally run `restore_erpnext_backup.sh` to restore data (take care that backup should have same modules as installed system,eg: ERP next and HRMS)

## TODO:
1. Remove `get-app` commands from all yml/yaml files as it is not supposed to used with running containers, custom images already handle this
2. Make script for `install-app` and/or `create-site` for custom apps aside from ERPNext AFTER `db` starts and `create-site` or `configurator` exits (explained [here](https://github.com/frappe/frappe_docker/blob/main/docs/site-operations.md)). This is to ensure this command is performed in running containers. This also ensures that apps are added dynamically and restoring backups does not override them. (We will be running app restore scripts with backup restore so that user gets latest data as well as new apps). Ensure that following requirements are satisfied:
   - apps/sites installed in `frontend` container after confirming `db` service is running
   - `migrate` command is run in `backend` container to ensure all changes are ported and synced 
