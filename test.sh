#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script."
  exit 1
else [[ $EUID == 0 ]]; then
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
        elif [[ $REPLY =~ n ]]; then
            exit
        else
            echo "Invaild, please try again"
        fi

        read -p "Install MySQL? (y/n)? "
        if [[ $REPLY =~ y ]]; then
            echo "==== Installing MySQL Container ===="
            docker pull mysql
            read -p "Please name your container: " CONTAINER_NAME
            read -p "Please add a root password: " PASSWORD
            echo
            docker run --name $CONTAINER_NAME -e MYSQL_ROOT_PASSWORD=$PASSWORD-d mysql:latest
            echo
        elif [[ $REPLY =~ n ]]; then
            exit
        else
            echo "Invaild, please try again"
        fi

        echo "1:) Perl"
        echo "2:) PHP"
        echo "3:) Python"
        read -p "What type of scripting engine would you like to install? (1/2/3/N)"
        if [[ $REPLY =~ 1 ]]; then
            docker pull perl
            read -p "Single script or full application? (1/2)" APP_TYPE
                if [[ $APP_TYPE =~ 1 ]]; then
                    read -p "Please enter the full path to your single script: " PATH_TO_SCRIPT
                    read -p "Please Name Your Container: " NAME_OF_CONTAINER
                    docker run -it --rm --name $NAME_OF_CONTAINER -v "$PWD":/usr/src/myapp -w /usr/src/myapp perl:5.34 perl $PATH_TO_SCRIPT
                elif [[ $APP_TYPE =~ 2 ]]; then
                    read -p "Do you need a Dockerfile? (Y/N) " 
                    if [[ $REPLY =~ y ]]; then
                     read -p "Please enter the full path to your repo: " PATH_TO_SCRIPT 
                     read -p "Please put the full name of your PHP Script: " NAME_OF_SCRIPT
                     read -p "Please Name Your Container: " NAME_OF_CONTAINER
 
                        DOCKERFILE_PERL_CONTENT="FROM perl:5.34 
                        COPY . /usr/src/myapp 
                        WORKDIR /usr/src/myapp 
                        CMD [ "perl", "./your-daemon-or-script.pl" ]"

                     echo "$DOCKERFILE_PERL_CONTENT" > "$PATH_TO_SCRIPT/Dockerfile"
                     echo "Attempting to run container..."
                     docker build -t my-perl-app .
                     docker run -it --rm --name $NAME_OF_CONTAINER my-perl-app

                    elif [[ $REPLY =~ n ]]; then
                     read -p "Please Name Your Container: " NAME_OF_CONTAINER
                     docker build -t my-perl-app .
                     docker run -it --rm --name $NAME_OF_CONTAINER my-perl-app
                    else
                     echo "An error occured, please try again."
                    fi
        elif [[ $REPLY =~ 2 ]]; then
            docker pull php
            read -p "Single script or full application? (1/2)" APP_TYPE
                if [[ $APP_TYPE =~ 1 ]]; then
                    read -p "Please enter the full path to your single script: " PATH_TO_SCRIPT
                    read -p "Please Name Your Container: " NAME_OF_CONTAINER
                    docker run -it --rm --name $NAME_OF_CONTAINER -v "$PWD":/usr/src/myapp -w /usr/src/myapp php:8.2-cli php $PATH_TO_SCRIPT
                elif [[ $APP_TYPE =~ 2 ]]; then
                    read -p "Do you need a Dockerfile? (Y/N) " 
                    if [[ $REPLY =~ y ]]; then
                     read -p "Please enter the full path to your repo: " PATH_TO_SCRIPT 
                     read -p "Please put the full name of your PHP Script: " NAME_OF_SCRIPT
                     read -p "Please Name Your Container: " NAME_OF_CONTAINER
 
                        DOCKERFILE_PHP_CONTENT="FROM php:8.2-cli 
                        COPY . /usr/src/myapp 
                        WORKDIR /usr/src/myapp  
                        CMD [ "php", "./$NAME_OF_SCRIPT" ]"

                     echo "$DOCKERFILE_PHP_CONTENT" > "$PATH_TO_SCRIPT/Dockerfile"
                     echo "Attempting to run container..."
                     docker build -t my-php-app .
                     docker run -it --rm --name $NAME_OF_CONTAINER my-php-app


                    elif [[ $REPLY =~ n ]]; then
                     read -p "Please Name Your Container: " NAME_OF_CONTAINER
                     docker build -t my-php-app .
                     docker run -it --rm --name $NAME_OF_CONTAINER my-php-app
                    else
                     echo "An error occured, please try again."
                    fi
        elif [[ $REPLY =~ 3 ]]; then
            docker pull python
            read -p "Python 2 or Python 3? (2/3) " PY_VERSION 
            if [[ $PY_VERSION =~ 2 ]]; then
                read -p "Single script or full application? (1/2)" APP_TYPE2
                if [[ $APP_TYPE2 =~ 1 ]]; then
                    read -p "Please enter the full path to your single script: " PATH_TO_SCRIPT
                    docker run -it --rm --name my-running-script -v "$PWD":/usr/src/myapp -w /usr/src/myapp python:2 python $PATH_TO_SCRIPT
                elif [[ $APP_TYPE2 =~ 2 ]]; then
                    read -p "Do you need a Dockerfile? (Y/N) " 
                    if [[ $REPLY =~ y ]]; then
                     read -p "Please enter the full path to your repo: " PATH_TO_SCRIPT 
                     read -p "Please put the full name of your Python Script: " NAME_OF_SCRIPT 

                        DOCKERFILE_PY2_CONTENT="FROM python:2
                        WORKDIR /usr/src/app
                        COPY requirements.txt ./
                        RUN pip install --no-cache-dir -r requirements.txt
                        COPY . .
                        CMD ["python", "./NAME_OF_SCRIPT "]"

                     echo "$DOCKERFILE_PY2_CONTENT" > "$PATH_TO_SCRIPT/Dockerfile"
                     echo "Attempting to run container..."
                     docker build -t my-python-app .
                     docker run -it --rm --name my-running-app my-python-app

                    elif [[ $REPLY =~ n ]]; then
                     docker build -t my-python-app .
                     docker run -it --rm --name my-running-app my-python-app
                    else
                     echo "An error occured, please try again."
                    fi
                else
                    echo "Invalid Option, please try again."
                fi
            elif [[ $PY_VERSION =~ 3 ]]; then
                read -p "Single script or full application? (1/2)" APP_TYPE3
              read -p "Single script or full application? (1/2)" APP_TYPE2
                if [[ $APP_TYPE3 =~ 1 ]]; then
                    read -p "Please enter the full path to your single script: " PATH_TO_SCRIPT
                    docker run -it --rm --name my-running-script -v "$PWD":/usr/src/myapp -w /usr/src/myapp python:3 python $PATH_TO_SCRIPT
                elif [[ $APP_TYPE3 =~ 2 ]]; then
                    read -p "Do you need a Dockerfile? (Y/N) " 
                    if [[ $REPLY =~ y ]]; then
                     read -p "Please enter the full path to your repo: " PATH_TO_SCRIPT 
                     read -p "Please put the full name of your Python Script: " NAME_OF_SCRIPT 

                        DOCKERFILE_PY3_CONTENT="FROM python:3
                        WORKDIR /usr/src/app
                        COPY requirements.txt ./
                        RUN pip install --no-cache-dir -r requirements.txt
                        COPY . .
                        CMD ["python", "./NAME_OF_SCRIPT "]"

                     echo "$DOCKERFILE_PY3_CONTENT" > "$PATH_TO_SCRIPT/Dockerfile"
                     echo "Attempting to run container..."
                     docker build -t my-python-app .
                     docker run -it --rm --name my-running-app my-python-app

                    elif [[ $REPLY =~ n ]]; then
                     docker build -t my-python-app .
                     docker run -it --rm --name my-running-app my-python-app
                    else
                     echo "An error occured, please try again."
                    fi
                else
                    echo "Invalid Option, please try again."
                fi
            elif [[ $REPLY =~ n ]]; then
                exit
            else
                echo "Invaild, please try again"    
            fi
    elif [[ $REPLY =~ n ]]; then
        exit 
    else
        echo "Error. Try again." 
    fi
fi
#---------------------END OF BASICS------------------------#