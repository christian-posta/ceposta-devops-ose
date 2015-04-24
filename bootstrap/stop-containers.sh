#!/bin/bash

set -e

echo "Stopping the devops docker containers"
docker stop jenkins gerrit nexus gitlab