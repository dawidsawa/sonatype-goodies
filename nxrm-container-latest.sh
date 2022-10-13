#!/bin/bash

# This scripts attempts to find and update an existing container of Nexus or will create a new one using the latest image.
# To preserve the data between updates, it will set up a volume mounted on /nexus-data if not done so yet.
# The connection port used by Nexus will be preserved or port 1234 will be used by default.

set -o nounset
set -o pipefail

CONTAINER=$( docker ps -q --filter "ancestor=sonatype/nexus3" )

# Find existing container
if [ ! -z "$CONTAINER" ]
then
  NAME=$( docker inspect -f '{{ .Name }}' "$CONTAINER" | awk '{print substr($1,2); }' )
  PORT=$( docker inspect -f '{{(index (index .NetworkSettings.Ports "8081/tcp") 0).HostPort}}' "$CONTAINER" )
  echo "Found existing container: $NAME ($CONTAINER) running on port $PORT"

  # Create data volume if absent
  VOLUME=$(docker inspect -f '{{ range .Mounts }}{{ .Name }}:{{ .Destination }}{{printf "\n"}}{{end}}' "$CONTAINER" | grep -E ':/nexus-data$' | cut -d':' -f1)
  if [ -z "$VOLUME" ]
  then
    VOLUME="$NAME-data"
    echo "Creating a new volume: $VOLUME"
    docker volume create --name "$VOLUME"
  fi

  echo "Stopping and removing old container"
  docker container kill "$CONTAINER"
  docker container rm "$CONTAINER"
fi

docker pull "sonatype/nexus3"
docker run -d -p "${PORT:-1234}":8081 --name "${NAME:-nexus}" -v "${VOLUME:-nexus-data}":/nexus-data -v "$PWD/nexus.properties":/nexus-data/etc/nexus.properties --restart=unless-stopped "sonatype/nexus3"
