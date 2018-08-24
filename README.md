# docker-geoserver-appschema

[![Docker Hub Badge](https://img.shields.io/badge/Docker-Hub%20Hosted-blue.svg)](https://hub.docker.com/r/wetransform/geoserver-appschema/)

Simple Dockerfile to build an image running GeoServer (plus app-schema extension) on Tomcat 8 and JRE 8.

## Configuration from host

Example of mounting a GeoServer data directory present on the Docker host:

```
docker run -it -p 8080:8080 -v /data/dir/on/host:/opt/webapps/geoserver/data wetransform/geoserver-appschema
```

## Waiting for the database

When running the image it will automatically wait for the database connection to a default PostGIS database being ready before starting GeoServer. This applies if you link a database container to this image as "db" with PostGIS default port 5432, for example:

```
docker run -it -p 8080:8080 --link mydbcontainer:db wetransform/geoserver-appschema
```

`mydbcontainer` in this case should be a PostGIS container with port 5432 exposed.

## Environment variables

`GS_ADMIN_PASSWORD`
`GS_MASTER_PASSWORD`

These variables can be used to conveniently set administrator and master passwords if you do not use a custom data directory but don't want to use the default passwords (e.g. in publicly accessible test environments). Passwords are expected to provided as

* GeoServer digest encrypted password (`digest1:hashedPasswordAndSalt`) **recommended**
* GeoServer plain text password (`plain:password`)
* or simply the plain password

If an admin password is provided but no master password, the admin password is used as the master password as well.

Example call:

```
docker run -it -p 8080:8080 -e GS_ADMIN_PASSWORD=mysecretpassword wetransform/geoserver-appschema
```

*Tip:* To create a GeoServer digest encrypted password use the provided script `gsdigest.groovy <password>` - it will print the prefix and the encrypted password to standard out.
