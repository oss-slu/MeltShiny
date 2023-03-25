set SCRIPT_DIR="%CD%\code\app.R"
set "SCRIPT_DIR=%SCRIPT_DIR:\=/%"

R -e "shiny::runApp('%SCRIPT_DIR%',launch.browser=T)"
