#!/bin/bash

set -e

echo "Remove the devops docker containers"
docker rm jenkins gerrit nexus gitlab