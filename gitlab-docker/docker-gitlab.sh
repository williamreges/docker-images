mkdir ${PWD}/gitlab

mkdir ${PWD}/gitlab/config

mkdir ${PWD}/gitlab/logs

mkdir ${PWD}/gitlab/data

chmod 777 ${PWD}/gitlab

sudo docker run --detach \
  --hostname gitlab.example.com \
  --publish 8929:80 --publish 2289:22 \
  --name gitlab \
  --restart always \
  --volume ${PWD}/gitlab/config:/etc/gitlab \
  --volume ${PWD}/gitlab/logs:/var/log/gitlab \
  --volume ${PWD}/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
