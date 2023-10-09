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
myConnector <- NULL

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

    # Construct the analysis plot
    constructAllPlots = function(sampleNum) {
      data <- .self$object$Derivatives.data[.self$object$Derivatives.data == sampleNum, ]
      data2 <- .self$object$Method.1.data[.self$object$Method.1.data$Sample == sampleNum, ]
      coeff <- 4000 # Static number to shrink data to scale
      upper <- max(data$dA.dT) / max(data$Ct) + coeff

      # Store the necessary information for use in the server for adding the best fit and first derivative
      bestFitXData[[sampleNum]] <<- data2$Temperature
      bestFitYData[[sampleNum]] <<- data2$Model
      derivativeXData[[sampleNum]] <<- data$Temperature
      derivativeYData[[sampleNum]] <<- data$dA.dT / (data$Pathlength * data$Ct) / upper + min(data$Absorbance)

      # Generate the base plot with just the absorbance data and a maximum derivative indicator line
      plot_ly(type = "scatter", mode = "markers", source = paste0("plotBoth", sampleNum)) %>%
        add_trace(data = data2, x = data2$Temperature, y = data2$Absorbance, marker = list(color = "blue")) %>%
        layout(
          shapes = list(
            list(
              type = "line", y0 = 0, y1 = 1, yref = "paper", x0 = data$Temperature[which.max(data$dA.dT)],
              x1 = data$Temperature[which.max(data$dA.dT)], line = list(width = 1, dash = "dot"), editable = FALSE
            )
          ),
          xaxis = list(dtick = 5)
        ) %>%
        rangeslider(xRange[[sampleNum]][1], xRange[[sampleNum]][2], thickness = .1) %>%
        layout(showlegend = FALSE) %>%
        layout(xaxis = list(fixedrange = TRUE, title = "Temperature (\u00B0C)")) %>%
        layout(yaxis = list(fixedrange = TRUE, title = "Absorbance(nm)")) %>%
        config(displayModeBar = FALSE)
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
