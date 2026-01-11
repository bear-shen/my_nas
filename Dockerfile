# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/engine/reference/builder/

#ffmpeg 6.0才有av1_nvenc的编码
#因此至少需要ubuntu(nobel/24.04LTS)
FROM 0xee/my_docker_aio:latest
#FROM node:22-bookworm

#only for onlyoffice
#这些东西AI的建议是写在env文件或者参数里面。。。反正先这样
ENV onlyoffice_enabled=false
ENV onlyoffice_jwt_secret='YOUR_JWT_SECRET'
ENV onlyoffice_origin='http://172.16.1.240:8001'
ENV pg_host='127.0.0.1'
ENV pg_port='5432'
ENV pg_account='postgres'
ENV pg_password='postgres'
ENV pg_database='toshokan'

# Use production node environment by default.
ENV NODE_ENV=production
ENV SRC=/myNas
#https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR ${SRC}

# Copy the rest of the source files into the image.
COPY . .

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into
# into this layer.
RUN chmod -R 0777 ${SRC}/docker/server_init.sh &&\
    chmod -R 0777 ${SRC}/docker/server_start.sh &&\
    ${SRC}/docker/server_init.sh

# Expose the port that the application listens on.
EXPOSE 80

# Run the application as a non-root user.
USER root

ENTRYPOINT ["${SRC}/docker/server_start.sh"]
