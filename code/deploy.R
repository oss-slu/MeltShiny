# deploy.R handles automated deployment for MeltShiny to shinyapps (hosting).

library(rsconnect)

# A function to stop the script when one of the variables cannot be found and to strip quotation marks from the secrets when you supplied them
error_on_missing_name <- function(name) {
  var <- Sys.getenv(name, unset = NA)
  if(is.na(var)) {
    stop(paste0("cannot find ", name, " !"), call. = FALSE)
  }
  gsub("\"", "", var)
}

# Get the Shiny account name, token, and secret from the environment variables
 shiny_acc_name <- error_on_missing_name("SHINY_ACC_NAME")
 token <- error_on_missing_name("TOKEN")
 secret <- error_on_missing_name("SECRET")


# Authenticate
setAccountInfo(name = error_on_missing_name("SHINY_ACC_NAME"),
               token = error_on_missing_name("TOKEN"),
               secret = error_on_missing_name("SECRET"))

# Deploy the application.
deployApp(
    appName = "MeltShiny",
    appFiles = c("ui.R", "server.r", "global.r", "app.R", "install.R", "deploy.R", "www", "uiParts", "rsconnect", "modules_2", "modules_1.r" ), 
    forceUpdate = TRUE )