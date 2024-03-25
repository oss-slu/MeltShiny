library(rsconnect,warn.conflicts=FALSE)
# Authenticate
rsconnect::setAccountInfo(name = "oss-slu",
            token = "2B40F62A2447585C65D43938644ADD20",
            secret = "t9XoI8TK8AQTw3v4iJWN2c1edRtLbt3YpQiCB0mG")
# Deploy
rsconnect::deployApp(appFiles ="app.R",appTitle="MeltShiny",appName = "MeltShiny")
