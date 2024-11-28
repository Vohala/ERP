#!/bin/bash

# Ensure you are in frappe_docker directory
cd ~/frappe_docker

# Customize APPS_JSON as per requirements. FOr now, its ERP Next and HRMS version-15
APPS_JSON='[
  {
    "url": "https://github.com/frappe/erpnext",
    "branch": "version-15"
  },
  {
    "url": "https://github.com/frappe/hrms",
    "branch": "version-15"
  }
]'

APPS_JSON_BASE64=$(echo ${APPS_JSON} | base64 -w 0)

# Export Custom image and tags for use in build command and compose.yaml
export CUSTOM_IMAGE=global_infocomm/erpnext_hrms
export CUSTOM_TAG=1.0.0
export PULL_POLICY=never # Ensures docker won't try to pull image from registry

# Build Custom image
docker build \
  --build-arg=APPS_JSON_BASE64=$APPS_JSON_BASE64 \
  --tag=$CUSTOM_IMAGE:$CUSTOM_TAG \
  --file=images/custom/Containerfile .
