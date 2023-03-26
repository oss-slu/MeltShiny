@echo off
Rscript -e "shiny::runApp('../code/app.R',launch.browser=T)"
pause
