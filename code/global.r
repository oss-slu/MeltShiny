# List of global variables
blank <- NULL
blankInt <- NULL
counter <- 1 
helix <- c() 
molStateVal <- "" 
wavelengthVal <- ""
myConnector = NULL 
start <- 1 
df2 <- NULL
valuesT <- NULL
df3 <- NULL
leftBarVal <- 0
rightBarVal <- 0
min <- 0
max <- 0
dataList = list()
numFiles <- 0
vantGgPlot <- NULL
summaryDataTable <- NULL
errorDataTable <- NULL
chosenMethods <- c(TRUE, TRUE, TRUE)
concTVal <- 0
tmMethodVal <- ""
weightedTmVal <- FALSE
numReadings = NULL
masterFrame = NULL

# Global variables for analysis plots
bestFitXData = NULL
bestFitYData = NULL
derivativeXData = NULL
derivativeYData = NULL


# Connector class that interacts with MeltR.
# constructObject() has to be called for each new method implemented. 
connecter <- setRefClass(Class = "connecter",
                         fields = c("df",
                                    "NucAcid",
                                    "wavelength",
                                    "blank",
                                    "Tm_method",
                                    "Weight_Tm_M2",
                                    "Mmodel",
                                    "methods",
                                    "concT",
                                    "object",
                                    "fdData"
                                    ),
                         methods = list(
                           # Create MeltR object & first derivative data
                           constructObject = function(){
                             capture.output(.self$object <- meltR.A(data_frame = df,
                                                                    blank = blank,
                                                                    NucAcid = NucAcid,
                                                                    wavelength = wavelength,
                                                                    Tm_method = Tm_method,
                                                                    Weight_Tm_M2 = Weight_Tm_M2,
                                                                    Mmodel = Mmodel,
                                                                    concT = concT,
                                                                    #methods = methods,
                                                                    Save_results = "none",
                                                                    Silent = FALSE
                                                                    ), 
                                            file = nullfile()
                                            )
                             upper = 4000 #Static number to shrink data to scale
                             .self$fdData <- .self$object$Derivatives.data
                             .self$fdData <- cbind(.self$fdData,
                                                   as.data.frame(
                                                     .self$fdData$dA.dT/(.self$fdData$Pathlength*.self$fdData$Ct)/upper
                                                     )
                                                   )
                             names(.self$fdData)[ncol(.self$fdData)] <- "yPlot"
                             
                             # Need to position the starting baseline bars at the min and max of temperature
                             data = df[df$Sample == 1,]
                             leftBarVal <<- round(min(data$Temperature),digits = 4)
                             min <<- round(min(data$temperature))
                             max <<- round(max(data$temperature))
                             rightBarVal <<- round(max(data$Temperature),digits = 4)
                             },
                           
                           # Construct the analysis plot
                           constructAllPlots = function(sampleNum){
                             data = .self$object$Derivatives.data[.self$object$Derivatives.data == sampleNum,]
                             data2 = .self$object$Method.1.data[.self$object$Method.1.data$Sample == sampleNum,]
                             coeff = 4000 #Static number to shrink data to scale
                             upper = max(data$dA.dT)/max(data$Ct) + coeff

                             # Store the necessary information for use in the server for adding the best fit and first derivative
                             bestFitXData[[sampleNum]] <<- data2$Temperature
                             bestFitYData[[sampleNum]] <<- data2$Model
                             derivativeXData[[sampleNum]] <<- data$Temperature
                             derivativeYData[[sampleNum]] <<- data$dA.dT/(data$Pathlength*data$Ct)/upper+min(data$Absorbance)
                             
                             # Generate the base plot with just the absorbance data
                             plot_ly(type = "scatter", mode = "markers") %>%
                               add_trace(data = data2, x = data2$Temperature, y = data2$Absorbance, marker = list(color = "blue")) %>%
                               layout(
                                 shapes = list(
                                   list(type = "line", y0 = 0, y1 = 1, yref = "paper", x0 = data$Temperature[which.max(data$dA.dT)], 
                                        x1 = data$Temperature[which.max(data$dA.dT)], line = list(width = 1, dash = "dot"), editable = FALSE)
                                   )
                                 ) %>%
                               rangeslider(data$Temperature[min], data$Temperature[max]) %>%
                               layout(showlegend = FALSE) %>%
                               layout(xaxis=list(fixedrange=TRUE, title = "Temperature")) %>% 
                               layout(yaxis=list(fixedrange=TRUE, title = "Absorbance(nm)"))%>%
                               config(displayModeBar = FALSE)
                             },
                        
                           # Return the x value associated with the maximum y-value for the first derivative
                           getFirstDerivativeMax = function(sampleNum) {
                             data = .self$fdData[.self$fdData == sampleNum,]
                             maxRowIndex = which.max(data[["yPlot"]])
                             xVal = data[maxRowIndex,3]
                             return(xVal)
                             },
                           
                           # Return the data needed to create the Van't Hoff plot
                           gatherVantData = function(){
                             vantData = .self$object$Method.2.data
                             return(vantData)
                             },
                           
                           # Return the individual fit data
                           fitData = function(){
                             indvCurves = .self$object$Method.1.indvfits 
                             return(indvCurves)
                             },
                           
                           # Return the results for the three methods
                           summaryData1 = function(){
                             summaryData = .self$object$Summary
                             return(summaryData[1,])
                             },
                           summaryData2 = function(){
                             summaryData = .self$object$Summary
                             return(summaryData[2,])
                             },
                           summaryData3 = function(){
                             summaryData = .self$object$Summary
                             return(summaryData[3,])
                             },
                           
                           # Return the percent error for the methods
                           errorData = function(){
                             errorData = .self$object$Range
                             #print()
                             return(errorData)
                             }
                           )
                         )
