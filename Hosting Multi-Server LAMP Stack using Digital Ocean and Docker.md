Installing Digital Ocean:
```
- sudo apt update && sudo apt install apt-transport-https ca-certificates curl software-properties-common

- Then add the GPG key for the official Docker repository to your system:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

Add Docker to APT Sources:
- echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

- sudo apt update

- apt-cache policy docker-ce

- sudo systemctl status docker

- docker images

- docker run -it ubuntu (Boom. Container)

- docker ps -a

- docker exec -it <container_id> /bin/bash

- docker pull apache2 

- docker run -d --name apache2-container -e TZ=UTC -p 8080:80 ubuntu/apache2:2.4-22.04_beta

- docker pull mysql

- docker run --name NAME_OF_CONTAINER -e MYSQL_ROOT_PASSWORD=test -d mysql:latest

- 

```
