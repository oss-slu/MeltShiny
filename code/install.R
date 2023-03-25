#!/usr/bin/env Rscript --vanilla
requiredPackages <- c("dplyr",
                      "DT",
                      "ggplot2",
                      "glue",
                      "devtools",
                      "openxlsx",
                      "plotly",
                      "tidyverse",
                      "remotes",
                      "methods",
                      "ggrepel",
                      "MeltR",
                      "shiny",
                      "shinyjs")

# Install packages if not found on the system.
installPackages <- function(packages) {
  for (p in packages) {
    if (!(p %in% rownames(installed.packages()))) {
      if (p == "MeltR") {
        remotes::install_github("JPSieg/MeltR")
      } else {
        install.packages(p,repos = "http://cran.us.r-project.org")
      }
    }
  }
}

# Check the installation state of each required package.
checkPackages <- function(packages) {
  for (p in packages) {
    if (p %in% rownames(installed.packages())) {
      print(paste0("[\u2713] ",p))
    }else{
      cat(paste0("[X]",p,"\n",
                   p,' was not successfully installed.
        Try entering the following command into the RStudio console:
        install.packages("',p,'")'))
    }
  }
}

installPackages(requiredPackages)
checkPackages(requiredPackages)
print("You can safely close this window.")
