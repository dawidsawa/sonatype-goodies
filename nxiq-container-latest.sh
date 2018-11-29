#!/bin/bash

# This scripts attempts to find and update an existing container of Nexus IQ Server
# or will create a new one using the latest image.

# To preserve the data between updates, it will set up a volume mounted on /nexus-data if not done so yet.
# The connection port used by Nexus will be preserved or port 1234 will be used by default.

set -o nounset
set -o pipefail

CONTAINER=$( docker ps -q --filter "ancestor=sonatype/nexus-iq-server" )

# Find existing container
if [ ! -z "$CONTAINER" ]
then
  NAME=$( docker inspect -f '{{ .Name }}' "$CONTAINER" | awk '{print substr($1,2); }' )
  PORT=$( docker inspect -f '{{(index (index .NetworkSettings.Ports "8070/tcp") 0).HostPort}}' "$CONTAINER" )
  echo "Found existing container: $NAME ($CONTAINER) running on port $PORT"

  echo "Stopping and removing old container"
  docker container kill "$CONTAINER"
  docker container rm "$CONTAINER"
fi

docker pull "sonatype/nexus-iq-server"
docker run -d -p "${PORT:-2003}":8070 --name "${NAME:-nxiq}" --restart=unless-stopped "sonatype/nexus-iq-server"
