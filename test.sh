#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script."
  exit 1
fi
if [[ $EUID == 0 ]]; then
     echo "Run Mega Script"

    read -p "Execute Script (y/n)? "
    echo 
    if [[ $REPLY =~ y ]]; then
        echo "==== Installing Docker ===="
        sudo apt update && sudo apt install apt-transport-https ca-certificates curl software-properties-common
        echo
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        echo 
        sudo apt update
        echo
        apt-cache policy docker-ce
        echo
        read -p "Install Apache? (y/n)? "
        if [[ $REPLY =~ y ]]; then
            echo "==== Installing Apache Container ===="
            docker pull apache2 
            read -p "Please name your container: "
            echo
            docker run -d --name $REPLY -e TZ=UTC -p 8080:80 ubuntu/apache2:2.4-22.04_beta
            echo
        if [[ $REPLY =~ n ]]; then
            exit
        fi
        read -p "Install MySQL? (y/n)? "
        if [[ $REPLY =~ y ]]; then
            echo "==== Installing MySQL Container ===="
            docker pull mysql
            read -p "Please name your container, followed by your root password: "
            echo
            docker run --name $var1 -e MYSQL_ROOT_PASSWORD=$var2 -d mysql:latest
            echo
        if [[ $REPLY =~ n ]]; then
            exit
        fi
    fi
fi
if [[ $REPLY =~ n ]]; then
    exit 
fi
#---------------------END OF BASICS------------------------#