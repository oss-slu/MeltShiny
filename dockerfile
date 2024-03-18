# Use the Rocker Docker image with R 4.2.1 and Shiny Server pre-installed - this works best if you are not using an Apple Sillicon chip. 
FROM shiny:latest

ARG DEBIAN_FRONTEND=noninteractive

# Copy the application files into the Docker image
COPY code/app.R /code/app.R
COPY code/global.r /code/global.r
COPY code/install.R /code/install.R
COPY code/server.r /code/server.r
COPY code/ui.R /code/ui.R

# # Expose the port that Shiny Server listens on. This is the default port for Shiny applications.
EXPOSE 3838

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install libssl-dev

RUN Rscript /code/install.R


CMD R -e "shiny::runApp('/code/app.R',launch.browser=T)"

# Go to root directory and run `docker build -t meltshiny .` to build the Docker image
# Then do `docker run --network host meltshiny` to run the container
# It will show the IP address to go to in the terminal. Copy and paste in firefox or chrome browser.