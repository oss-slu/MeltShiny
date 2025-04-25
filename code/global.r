# Global.r defines global variables/packages/methods that are used throughout the MeltShiny application.


# Declare packages
library(dplyr)
library(DT)
library(ggplot2)
library(glue)
library(openxlsx)
library(plotly)
library(remotes)
library(methods) 
library(ggrepel)
library(MeltR) 
library(shiny)
library(shinyjs)
library(shinythemes)

options(warn = -1)

# Global variables for file inputs
blank <- NULL
blankInt <- NULL
helix <- c()
molStateVal <- ""
wavelengthVal <- ""
chosenMethods <- c(TRUE, TRUE, TRUE)
concTVal <- 0
tmMethodVal <- ""
weightedTmVal <- FALSE

# Global variables for uploaded datasets
dataList <- list()
numUploads <- 0
masterFrame <- NULL
counter <- 1
numSamples <- NULL

# Global variables for the MeltR object
myConnecter <- NULL

# Global variables for the Van't Hoff plot
vantData <- NULL

# Global variables for the results table
individualFitData <- NULL
summaryDataTable <- NULL
errorDataTable <- NULL
vantGgPlot <- NULL
valuesT <- NULL

# Global variables for analysis plots
start <- 1
bestFitXData <- NULL
bestFitYData <- NULL
derivativeXData <- NULL
derivativeYData <- NULL
xRange <- NULL

# Connector class that interacts with MeltR.
# constructObject() has to be called for each new method implemented.
connecter <- setRefClass(
  Class = "connecter",
  fields = c(
    "df",
    "NucAcid",
    "wavelength",
    "blank",
    "Tm_method",
    "Weight_Tm_M2",
    "Mmodel",
    "outliers",
    "methods",
    "concT",
    "object",
    "fdData"
  ),
  methods = list(
    # Create MeltR object & first derivative data
    constructObject = function() {
      # For outliers, MeltR.A seems to expect either NA or a single value
      outliers_to_use <- NA
      if (!is.null(outliers) && length(outliers) > 0) {
        if (length(outliers) == 1) {
          outliers_to_use <- outliers
        } else {
          # If we have multiple outliers, we need to handle them differently
          outliers_to_use <- outliers[1]
        }
      }
      capture.output(
        .self$object <- meltR.A(
          data_frame = df,
          blank = blank,
          NucAcid = NucAcid,
          wavelength = wavelength,
          Tm_method = Tm_method,
          Weight_Tm_M2 = Weight_Tm_M2,
          Mmodel = Mmodel,
          concT = concT,
          outliers = outliers,
          # fitTs = xRanges
          methods = methods,
          Save_results = "none",
          Silent = FALSE
        ),
        file = nullfile()
      )
      upper <- 4000 # Static number to shrink data to scale
      .self$fdData <- .self$object$Derivatives.data
      .self$fdData <- cbind(
        .self$fdData,
        as.data.frame(
          .self$fdData$dA.dT / (.self$fdData$Pathlength * .self$fdData$Ct) / upper
        )
      )
    },

    # Automatically fit MeltR.A object through BLTrimmer
    # executeBLTrimmer = function(object, iterations) {
    #   .self$fittedObject <- BLTrimmer(object,
    #                                  n.combinations = iterations)
    # },

    # Modified constructAllPlots with baseline trimming logic
    constructAllPlots = function(sampleNum, fittingTriggered = NULL) {
      logInfo(sprintf("RENDERING ANALYSIS PLOT #%s", sampleNum))

      # Grab the original full data
      data <- .self$object$Derivatives.data[.self$object$Derivatives.data$Sample == sampleNum, ]
      data2 <- .self$object$Method.1.data[.self$object$Method.1.data$Sample == sampleNum, ]
      coeff <- 4000
      upper <- max(data$dA.dT) / max(data$Ct) + coeff

      # Filter for max derivative temperature
      filteredData <- data[data$Temperature >= 20 & data$Temperature <= 70, ]
      maxDerivativeTemp <- filteredData$Temperature[which.max(filteredData$dA.dT)]
            
      # Apply baseline trim if triggered and xRange is valid
      if (!is.null(fittingTriggered) &&
          is.function(fittingTriggered) && 
          isTRUE(fittingTriggered()) &&
          !is.null(xRange[[sampleNum]]) &&
          length(xRange[[sampleNum]]) == 2 &&
          !any(is.na(xRange[[sampleNum]]))) {

        # Filter the data
        data <- data[data$Temperature >= xRange[[sampleNum]][1] & data$Temperature <= xRange[[sampleNum]][2], ]
        data2 <- data2[data2$Temperature >= xRange[[sampleNum]][1] & data2$Temperature <= xRange[[sampleNum]][2], ]

        logInfo(sprintf("BASELINE TRIM FILTERED Sample %s to range [%.2f, %.2f]",
                        sampleNum,
                        xRange[[sampleNum]][1],
                        xRange[[sampleNum]][2]))
      }

      # Store line/derivative data
      bestFitXData[[sampleNum]] <<- data2$Temperature
      bestFitYData[[sampleNum]] <<- data2$Model
      derivativeXData[[sampleNum]] <<- data$Temperature
      derivativeYData[[sampleNum]] <<- data$dA.dT / (data$Pathlength * data$Ct) / upper + min(data$Absorbance)

      # Start building the plot
      p <- plot_ly(type = "scatter", mode = "markers", source = paste0("plotBoth", sampleNum)) %>%
        add_trace(data = data2, x = ~Temperature, y = ~Absorbance, marker = list(color = "blue")) %>%
        layout(
          shapes = list(
            list(
              type = "line", y0 = 0, y1 = 1, yref = "paper", x0 = maxDerivativeTemp,
              x1 = maxDerivativeTemp, line = list(width = 1, dash = "dot"), editable = FALSE
            )
          ),
          annotations = list(
            list(
              x = maxDerivativeTemp,
              y = 1.02,
              yref = "paper",
              text = sprintf("Transition @ %.2f°C", maxDerivativeTemp),
              showarrow = FALSE,
              xanchor = "left"
            )
          )
        ) %>%
        layout(
          xaxis = list(dtick = 5, fixedrange = TRUE, title = "Temperature (°C)"),
          yaxis = list(fixedrange = TRUE, title = "Absorbance(nm)"),
          showlegend = FALSE
        ) %>%
        rangeslider(xRange[[sampleNum]][1], xRange[[sampleNum]][2], thickness = .1) %>%
        config(displayModeBar = FALSE)

      logInfo(sprintf("RENDERED ANALYSIS PLOT #%s", sampleNum))
      return(p)
    },


    # Return the data needed to create the Van't Hoff plot
    gatherVantData = function() {
      vantData <- .self$object$Method.2.data
      return(vantData)
    },

    # Return the individual fit data
    indFitTableData = function() {
      indvCurves <- .self$object$Method.1.indvfits
      return(indvCurves)
    },

    # Return the results for the three methods
    summaryData1 = function() {
      summaryData <- .self$object$Summary
      return(summaryData[1, ])
    },
    summaryData2 = function() {
      summaryData <- .self$object$Summary
      return(summaryData[2, ])
    },
    summaryData3 = function() {
      summaryData <- .self$object$Summary
      return(summaryData[3, ])
    },

    # Return the percent error for the three methods
    errorData = function() {
      errorData <- .self$object$Range
      return(errorData)
    }
  )
)

logInfo <- function(message) {
  timestamp <- format(Sys.time(), "[%Y-%m-%d %H:%M:%S]")
  level <- "INFO"
  log <- paste(timestamp, level, message, sep=" | ")
  cat(log, "\n") # Print the log message with a newline at the end
}
