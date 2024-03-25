
# Authenticate
setAccountInfo(name = Sys.getenv("SHINY_ACC_NAME"),
            token = Sys.getenv("TOKEN"),
            secret = Sys.getenv("SECRET"))
# Deploy
deployApp(appFiles = "app.R",appTitle=Sys.getenv("APP_TITLE"),appName = Sys.getenv("APP_NAME"))