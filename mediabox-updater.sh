#!/bin/bash

# Pull the latest config from the repo.
git pull origin master

# Build the containers, and start them up in daemon mode.
docker-compose up -d --no-deps --build
