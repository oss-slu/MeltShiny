# Use the Rocker Docker image with R 4.2.1 and Shiny Server pre-installed
FROM rocker/shiny:4.2.1

# Copy the application files into the Docker image
COPY code/app.R /app.R
COPY code/global.r /global.r
COPY code/install.R /install.R
COPY code/server.r /server.r
COPY code/ui.R /ui.R

# Install additional R packages (if needed, example below)
# RUN R -e "install.packages(c('package1', 'package2'), repos='https://cloud.r-project.org/')"

# Expose the port that Shiny Server listens on. This is the default port for Shiny applications.
EXPOSE 3838

# Go to root directory and run `docker build -t MeltShiny .` to build the Docker image

# To run the container do: `docker run -p 3838:3838 meltwin2.0` in terminal