# How to build and run the docker container

1. **Go to root directory and run `docker build -t meltshiny . ` in the terminal**
    This will build and update the docker image. You can replace "meltshiny with whatever you want the container to be called. Keep in mind that building a new container name will result in a longer installation process.\

    If it is just an update of an already existing container, it will already have the dependencies preinstalled. 
2. **In terminal, run the following command, `docker run --network host meltshiny` to run the container**
    This will show the IP address to put in your browser. Copy and paste in Firefox or Google Chrome


# WARNING #
**Docker containerization DOES NOT WORK WITH APPLE SILLICON CHIPS!** 
Shiny Docker Image is not compatible with any variation of M1,M2, and M3 chip. There may be a way to work around this working with a repository created by andrewbaxter439

https://github.com/andrewbaxter439/docker-shiny-arm

However, this version was made in August 2023. It is out of date. 
