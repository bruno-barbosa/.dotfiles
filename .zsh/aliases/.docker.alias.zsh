# DOCKER ALIASES

# general docker aliases
alias drmc='docker rm $(docker ps -a -q)'
alias drmi='docker image rm $(docker images -a -q)'

alias portainer.run='docker run -d --expose 9000 --name portainer --restart always -e VIRTUAL_HOST=portainer.local -e VIRTUAL_PORT=9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer:/data portainer/portainer'
alias rancher.run='docker run -d --restart=unless-stopped --name rancher-server -e VIRTUAL_HOST=rancher.aion -e VIRTUAL_PORT=8080 rancher/server:stable'
alias nginx.run='docker run -d -p 80:80 --restart=unless-stopped --name nginx-proxy -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy'