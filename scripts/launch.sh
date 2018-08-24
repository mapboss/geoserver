#!/bin/bash

# Runtime configuration that should not be stored in the image
echo "Executing prelaunch script..."
/tmp/scripts/prelaunch.groovy "$GEOSERVER_DIR"

# If a database container is linked with name "db" and port 5432, wait for the database
if test -n "${DB_PORT_5432_TCP_ADDR}"; then
  echo "Waiting for database connection..."
  export TESTING_DB_URL="tcp://${DB_PORT_5432_TCP_ADDR}:${DB_PORT_5432_TCP_PORT}"

  # See http://tldp.org/LDP/abs/html/devref1.html for description of this syntax.
  while ! exec 6<>/dev/tcp/${DB_PORT_5432_TCP_ADDR}/${DB_PORT_5432_TCP_PORT}; do
    echo "$(date) - still trying to connect to database at ${TESTING_DB_URL}"
    sleep 1
  done
fi

for ext in `ls -d /geoserver-exts/*`; do
  cp "${ext}"/*.jar ${GEOSERVER_DIR}/WEB-INF/lib
done

# Run tomcat
echo "Starting GeoServer..."
/usr/local/tomcat/bin/catalina.sh run
