# Use the Rocker Docker image with R 4.2.1 and Shiny Server pre-installed - this works best if you are not using an Apple Sillicon chip. 
FROM rocker/shiny:latest
# WORKDIR /code
RUN install2.r rsconnect dplyr DT ggplot2 glue openxlsx plotly remotes methods ggrepel MeltR shiny shinyjs shinythemes 
RUN Rscript -e "remotes::install_github('JPSieg/MeltR')"
# Copy the application files into the Docker image
COPY code/app.R /app.R
COPY code/install.R /install.R
COPY code/global.r /global.r
COPY code/server.r /server.r
COPY code/ui.R /ui.R
COPY code/deploy.R /deploy.R

CMD Rscript deploy.R


# To test the Docker image, you can run the following commands:
# Go to root directory and run `docker build -t meltshiny .` to build the Docker image
# Then do `docker run --network host meltshiny` to run the container
# It will show the IP address to go to in the terminal. Copy and paste in firefox or chrome browser.