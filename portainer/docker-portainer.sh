docker run -d -p 9000:9000 -p 9443:9443 \
--name portainer \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v ${pwd}/data-portainer:/data \
portainer/portainer:latest
