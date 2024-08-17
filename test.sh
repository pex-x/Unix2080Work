#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script."
  exit 1
elif [[ $EUID == 0 ]]; then
    echo "Welcome to the LAMP Stack Unified Control Script, or LAMPSUCS. Please choose solution from menu below."
    #Add menu to destroy, and re-run script.
    echo "1:) Create New Containers"
    echo "2:) Destroy Containers"
    echo "3:) Harden Digital Ocean Machine"
    read -p "Please choose an option. (1/2/3/N)? "
        if [[ $REPLY =~ 1 ]]; then
        echo "==== Installing Docker ===="
        if [ -x "$(command -v docker)" ]; then
         echo "Docker is installed, updating system & docker to prevent errors."
         sudo apt update
         sudo apt update && sudo apt install apt-transport-https ca-certificates curl software-properties-common
         sudo snap install docker
         curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
         echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
         sudo apt update
         apt-cache policy docker-ce
         echo
        fi
        read -p "Install Apache? (y/n)? "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "==== Installing Apache Container ===="
            read -p "Please name your container: " NAME_DOCKER
            docker run -d --name $NAME_DOCKER -e TZ=UTC -p 8080:80 ubuntu/apache2:2.4-22.04_beta
            
            :'
            echo "Apache Security is reccomended..."
            read -p "Do you need Apache Securtiy? (y/n)?" 
            if [[ $REPLY =~ ^[Yy]$ ]]; then
             docker exec -it $NAME_DOCKER /bin/bash
             DOCKER_APACHECONF = /etc/apache2/apache2.conf
             DOCKER_APACHECONF_BK = /etc/apache2/apache2.conf.backup
            
             echo "Backing up $DOCKER_APACHECONF to $DOCKER_APACHECONF_BK"
             if ! [[ -f "$DOCKER_APACHECONF_BK" ]]; then
		      echo "Backing up $DOCKER_APACHECONF to $DOCKER_APACHECONF_BK"
		      cp $DOCKER_APACHECONF $DOCKER_APACHECONF_BK
		     fi

	         echo "To restore: cp $DOCKER_APACHECONF_BK $DOCKER_APACHECONF"
        	 echo "Hiding Apache Version and OS Information"
             sed -i -e '$a\ServerTokens Prods$a\ServerSignature Off/g' $DOCKER_APACHECONF
             sed -i "KeepAliveTimeout/i 200"

             echo "Disabling Directory Listing"
             a2dismod --force autoindex
             echo "Updating Packages/Checking for out of date version"
             apt update && apt upgrade

             echo "Enabling HTTP Strict Transport Security (HSTS) & restarting server"
             a2enmod headers
             service apache2 restart
             docker start $NAME_DOCKER
             docker exec -it $NAME_DOCKER /bin/bash
             config_files=("/etc/apache2/sites-available/default-ssl.conf")
             insert_string='Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"\n'
             sed -i "/<\/VirtualHost>/i  $insert_string" $config_files

             echo "Doing last restart to make sure everything initilized"
             service apache2 restart
             docker start $NAME_DOCKER

             echo "Security Complete. To disable unnessecary modules please check apache2ctl -M"
            elif [[ $REPLY =~ ^[Nn]$ ]]; then
             echo
            else
             echo "Invalid input, please try again"
             exit 1
            fi
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            echo
        else
            echo "Invalid input, please try again"
            exit 1
        fi
        '
        read -p "Install MySQL? (y/n)? "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "==== Installing MySQL Container ===="
            docker pull mysql
            read -p "Please name your container: " CONTAINER_NAME
            read -p "Please add a root password: " PASSWORD
            echo
            docker run --name $CONTAINER_NAME -e MYSQL_ROOT_PASSWORD=$PASSWORD -d mysql:latest
            echo
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            echo
        else
            echo "Invalid input, please try again"
            exit 1
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
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    read -p "Please enter the full path to your repo: " PATH_TO_SCRIPT 
                    read -p "Please put the full name of your Perl Script: " NAME_OF_SCRIPT
                    read -p "Please Name Your Container: " NAME_OF_CONTAINER

                    DOCKERFILE_PERL_CONTENT="FROM perl:5.34 
                    COPY . /usr/src/myapp 
                    WORKDIR /usr/src/myapp 
                    CMD [ \"perl\", \"./$NAME_OF_SCRIPT\" ]"

                    echo "$DOCKERFILE_PERL_CONTENT" > "$PATH_TO_SCRIPT/Dockerfile"
                    echo "Attempting to run container..."
                    docker build -t my-perl-app .
                    docker run -it --rm --name $NAME_OF_CONTAINER my-perl-app

                elif [[ $REPLY =~ ^[Nn]$ ]]; then
                    read -p "Please Name Your Container: " NAME_OF_CONTAINER
                    docker build -t my-perl-app .
                    docker run -it --rm --name $NAME_OF_CONTAINER my-perl-app
                else
                    echo "An error occurred, please try again."
                    exit 1
                fi
            else
                echo "Invalid Option, please try again."
                exit 1
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
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    read -p "Please enter the full path to your repo: " PATH_TO_SCRIPT 
                    read -p "Please put the full name of your PHP Script: " NAME_OF_SCRIPT
                    read -p "Please Name Your Container: " NAME_OF_CONTAINER

                    DOCKERFILE_PHP_CONTENT="FROM php:8.2-cli 
                    COPY . /usr/src/myapp 
                    WORKDIR /usr/src/myapp  
                    CMD [ \"php\", \"./$NAME_OF_SCRIPT\" ]"

                    echo "$DOCKERFILE_PHP_CONTENT" > "$PATH_TO_SCRIPT/Dockerfile"
                    echo "Attempting to run container..."
                    docker build -t my-php-app .
                    docker run -it --rm --name $NAME_OF_CONTAINER my-php-app

                elif [[ $REPLY =~ ^[Nn]$ ]]; then
                    read -p "Please Name Your Container: " NAME_OF_CONTAINER
                    docker build -t my-php-app .
                    docker run -it --rm --name $NAME_OF_CONTAINER my-php-app
                else
                    echo "An error occurred, please try again."
                    exit 1
                fi
            else
                echo "Invalid Option, please try again."
                exit 1
            fi
        elif [[ $REPLY =~ 3 ]]; then
            docker pull python
            read -p "Python 2 or Python 3? (2/3) " PY_VERSION 
            if [[ $PY_VERSION =~ 2 ]]; then
                read -p "Single script or full application? (1/2)" APP_TYPE
                if [[ $APP_TYPE =~ 1 ]]; then
                    read -p "Please enter the full path to your single script: " PATH_TO_SCRIPT
                    read -p "Please put the full name of your Python Script: " NAME_OF_SCRIPT 
                    docker run -it --rm --name my-running-script -v "$PWD":$PATH_TO_SCRIPT -w $PATH_TO_SCRIPT python:2 python $NAME_OF_SCRIPT
                elif [[ $APP_TYPE =~ 2 ]]; then
                    read -p "Do you need a Dockerfile? (Y/N) " 
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        read -p "Please enter the full path to your repo: " PATH_TO_SCRIPT 
                        read -p "Please put the full name of your Python Script: " NAME_OF_SCRIPT 

                        DOCKERFILE_PY2_CONTENT="FROM python:2
                        WORKDIR /usr/src/app
                        COPY requirements.txt ./
                        RUN pip install --no-cache-dir -r requirements.txt
                        COPY . .
                        CMD [\"python\", \"./$NAME_OF_SCRIPT\"]"

                        echo "$DOCKERFILE_PY2_CONTENT" > "$PATH_TO_SCRIPT/Dockerfile"
                        echo "Attempting to run container..."
                        docker build -t my-python-app .
                        docker run -it --rm --name my-running-app my-python-app

                    elif [[ $REPLY =~ ^[Nn]$ ]]; then
                        docker build -t my-python-app .
                        docker run -it --rm --name my-running-app my-python-app
                    else
                        echo "An error occurred, please try again."
                        exit 1
                    fi
                else
                    echo "Invalid Option, please try again."
                    exit 1
                fi
            elif [[ $PY_VERSION =~ 3 ]]; then
                read -p "Single script or full application? (1/2)" APP_TYPE
                if [[ $APP_TYPE =~ 1 ]]; then
                read -p "Please put the full name of your Python Script: " NAME_OF_SCRIPT 
                    docker run -it --rm --name my-running-script -v "$PWD":$PATH_TO_SCRIPT -w $PATH_TO_SCRIPT python:3 python $NAME_OF_SCRIPT
                elif [[ $APP_TYPE =~ 2 ]]; then
                    read -p "Do you need a Dockerfile? (Y/N) " 
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        read -p "Please enter the full path to your repo: " PATH_TO_SCRIPT 
                        read -p "Please put the full name of your Python Script: " NAME_OF_SCRIPT 

                        DOCKERFILE_PY3_CONTENT="FROM python:3
                        WORKDIR /usr/src/app
                        COPY requirements.txt ./
                        RUN pip install --no-cache-dir -r requirements.txt
                        COPY . .
                        CMD [\"python\", \"./$NAME_OF_SCRIPT\"]"

                        echo "$DOCKERFILE_PY3_CONTENT" > "$PATH_TO_SCRIPT/Dockerfile"
                        echo "Attempting to run container..."
                        docker build -t my-python-app .
                        docker run -it --rm --name my-running-app my-python-app

                    elif [[ $REPLY =~ ^[Nn]$ ]]; then
                        docker build -t my-python-app .
                        docker run -it --rm --name my-running-app my-python-app
                    else
                        echo "An error occurred, please try again."
                        exit 1
                    fi
                else
                    echo "Invalid Option, please try again."
                    exit 1
                fi
            else
                echo "Invalid Option, please try again."
                exit 1
            fi
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            echo 
        else
            echo "Error. Try again."
            exit 1
        fi
        elif [[ $REPLY =~ 2 ]]; then
         read -p "Please name your container that you would like to remove: " NAME_REMOVAL
         docker stop $NAME_REMOVAL
         docker rm $NAME_REMOVAL
        elif [[ $REPLY =~ 3 ]]; then
         echo "Password Requirements"	
         LOGIN_CONFIG="/etc/login.defs"
         LOGIN_CONFIG_BACKUP="$LOGIN_CONFIG.backup"

         if ! [[ -f "$LOGIN_CONFIG_BACKUP" ]]; then
		  echo "backing up $LOGIN_CONFIG to $LOGIN_CONFIG_BACKUP"
		  cp $LOGIN_CONFIG $LOGIN_CONFIG_BACKUP
	     fi

    	 echo "To Restore: cp $LOGIN_CONFIG_BACKUP"
	
    	 sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/g' $LOGIN_CONFIG
	     sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 10/g' $LOGIN_CONFIG
	     sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE  7/g' $LOGIN_CONFIG

	     echo "Edited $LOGIN_CONFIG"
	     echo "----Diff----"
	     git diff --unified=0 --no-index $LOGIN_CONFIG_BACKUP $LOGIN_CONFIG
         #-----END------#

         #----LIBPAM REQUIREMENTS----#
         echo "LIBPAM "
	     sudo apt-get -y install libpam-cracklib

         PW_CONFIG="/etc/pam.d/common-password"
         PW_CONFIG_BACKUP="$PW_CONFIG.backup"

	     if ! [[ -f "$PW_CONFIG_BACKUP" ]]; then
		  echo "backing up $PW_CONFIG to $PW_CONFIG_BACKUP"
		  cp $PW_CONFIG $PW_CONFIG_BACKUP
	     fi
         sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' $PW_CONFIG

         echo "Edited $PW_CONFIG"
	     echo "----Diff----"
	     git diff --unified=0 --no-index $PW_CONFIG_BACKUP $PW_CONFIG
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
         exit
        else
            echo "An Error has occurred."
        fi        
else
    echo "An Error has occurred."
    exit 1
fi
#---------------------END OF BASICS------------------------#
