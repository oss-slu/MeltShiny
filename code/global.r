# List of global variables
blank <- NULL 
counter <- 1 
helix <- c() 
molStateVal <- "" 
wavelengthVal <- ""
myConnector = NULL 
start <- 1 

# Connector class that interacts with MeltR.
# constructObject() has to be called for each new method implemented. 
connecter <- setRefClass(Class = "connecter",
                         fields = c("df",
                                    "NucAcid",
                                    "blank",
                                    "Mmodel",
                                    "object",
                                    "fdData"
                                    ),
                         methods = list(
                           
                           # Create MeltR object & first derivative data
                           constructObject = function(){
                             .self$object <- meltR.A(data_frame = df,
                                                     blank = blank,
                                                     NucAcid = NucAcid,
                                                     Mmodel = Mmodel
                                                     )
                             upper = 4000 #Static number to shrink data to scale
                             .self$fdData <- .self$object$Derivatives.data
                             .self$fdData <- cbind(.self$fdData,
                                                   as.data.frame(
                                                     .self$fdData$dA.dT/(.self$fdData$Pathlength*.self$fdData$Ct)/upper
                                                     )
                                                   )
                             names(.self$fdData)[ncol(.self$fdData)] <- "yPlot"
                             },
                           
                          #Construct a plot containing the raw data
                           constructRawPlot = function(sampleNum){
                             data = df[df$Sample == sampleNum,]
                             plot_ly(data, x = data$Temperature, y = data$Absorbance, type = "scatter", mode = "markers") %>%
                               layout(showlegend = FALSE)
                             },
                           
                           # Construct a plot of the first derivative and the raw data
                           constructFirstDerivative = function(sampleNum){
                             data = .self$fdData[.self$fdData == sampleNum,]
                             plot_ly(data, x = data$Temperature, y = data$Absorbance, type = "scatter", mode = "markers") %>%
                               add_markers(x = data$Temperature, y = data$yPlot+min(data$Absorbance), color = "blue") %>%
                               add_markers(x = data$Temperature[which.max(data$yPlot)],y = max(data$yPlot)+min(data$Absorbance), color = "red") %>%
                               layout(showlegend = FALSE)
                             },
                           
                           # Construct a plot of the best fit and the raw data
                           constructBestFit = function(sampleNum){
                             data = .self$object$Method.1.data
                             data = data[data$Sample == sampleNum,]
                             plot_ly(data, x = data$Temperature, y = data$Absorbance, type = "scatter", mode = "markers") %>%
                               add_lines(x = data$Temperature,y = data$Model, color = "red") %>%
                               layout(showlegend = FALSE)
                             },
                           
                           # Construct a plot of the best fit, first derivative, and the raw data
                           constructBoth = function(sampleNum){
                             data1 = .self$object$Derivatives.data[.self$object$Derivatives.data == sampleNum,]
                             data2 = .self$object$Method.1.data[.self$object$Method.1.data$Sample == sampleNum,]
                             coeff = 4000 #Static number to shrink data to scale
                             upper = max(data1$dA.dT)/max(data1$Ct) + coeff
                             plot_ly(data2, x = data2$Temperature, y = data2$Absorbance, type = "scatter", mode = "markers") %>%
                               add_lines(x = data2$Temperature, y = data2$Model, color = "red") %>%
                               add_markers(x = data1$Temperature, y = (data1$dA.dT/(data1$Pathlength*data1$Ct))/upper+min(data1$Absorbance), color = "blue") %>%
                               layout(showlegend = FALSE)
                             },
                           
                           # Return the data needed to create the Van't Hoff plot
                           gatherVantData = function(){
                             data = .self$object$Method.2.data
                             return(data)
                             },
                           
                           # Return the individual fit table data
                           fitData = function(){
                             indvCurves = .self$object$Method.1.indvfits 
                             return(indvCurves)
                             },
                           
                           # Return the results for the three methods
                           summaryData1 = function(){
                             summaryData=.self$object$Summary
                             return(summaryData[1,])
                             },
                           summaryData2 = function(){
                             summaryData=.self$object$Summary
                             return(summaryData[2,])
                             },
                           
                           # Return the percent error for the methods
                           error = function(){
                             error = .self$object[3]
                             return(error)
                             }
                           )
                         )
