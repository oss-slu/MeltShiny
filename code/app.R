#!/usr/bin/env Rscript --vanilla
# Load libraries and run application.
library(dplyr, warn.conflicts = FALSE)
library(DT)
library(ggplot2)
library(glue)
library(methods)
library(MeltR)
library(plotly)
library(openxlsx)
library(shiny)
library(shinyjs)
#shinyApp(ui = ui, server = server)
runApp(launch.browser = TRUE)
