#!/usr/bin/env bash

#fetch directory of script
SCRIPT_DIR=$(echo ${BASH_SOURCE[0]} | sed -e "s|/[^/]*$||")
SCRIPT_DIR=$SCRIPT_DIR/"code/"

#run app in local browser
R -e "shiny::runApp('$SCRIPT_DIR',launch.browser=T)"


