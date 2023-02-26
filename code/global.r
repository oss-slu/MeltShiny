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
                           
                           # Construct a plot containing the raw data
                           constructRawPlot = function(sampleNum){
                             data = df[df$Sample == sampleNum,]
                             ggplot(data, aes(x = Temperature, y = Absorbance)) +
                               geom_point() +
                               theme_classic()
                             },
                           
                           # Construct a plot of the first derivative and the raw data
                           constructFirstDerivative = function(sampleNum){
                             data = .self$fdData[.self$fdData == sampleNum,]
                             ggplot(data,aes(x = Temperature)) +
                               geom_point(aes(y = Absorbance)) +
                               geom_point(aes(y = yPlot+min(Absorbance)),color="blue") +
                               geom_point(aes(x = Temperature[which.max(yPlot)],y = max(yPlot)+min(Absorbance)),color="red") +
                               theme_classic()
                             },
                           
                           # Construct a plot of the best fit and the raw data
                           constructBestFit = function(sampleNum){
                             data = .self$object$Method.1.data
                             data = data[data$Sample == sampleNum,]
                             ggplot(data,aes(x = Temperature)) +
                               geom_point(aes(y = Absorbance), color = "black") +
                               geom_line(aes(y = Model), color = "red") +
                               theme_classic()
                             },
                           
                           # Construct a plot of the best fit, first derivative, and the raw data
                           constructBoth = function(sampleNum){
                             data1 = .self$object$Derivatives.data[.self$object$Derivatives.data == 4,]
                             data2 = .self$object$Method.1.data[.self$object$Method.1.data$Sample == 4,]
                             coeff = 4000 #Static number to shrink data to scale
                             upper = max(data1$dA.dT)/max(data1$Ct) + coeff
                             ggplot() + 
                               geom_point(data2,mapping = aes(x = Temperature, y = Absorbance), color = "black") + #raw
                               geom_line(data2,mapping = aes(x = Temperature, y = Model), color = "red") + #best fit 
                               geom_point(data1, mapping = aes(x = Temperature, y = (dA.dT/(Pathlength*Ct))/upper+min(Absorbance)), color = "blue") + #first derivative
                               theme_classic()
                             },
                           
                           # Return the x value associated with the maximum y-value for the first derivative
                           getFirstDerivativeMax = function(sampleNum) {
                             data = .self$fdData[.self$fdData == sampleNum,]
                             maxRowIndex = which.max(data[["yPlot"]])
                             xVal = data[maxRowIndex,3]
                             return(xVal)
                             },
                           
                           # Return the start & end ranges for each respective slider
                           getSliderBounds = function(sampleNum,maximum) {
                             data = .self$fdData[.self$fdData == sampleNum,]
                             minTemp = round(min(data$Temperature),4)
                             maxTemp = round(max(data$Temperature),4)
                             if (minTemp < maximum-20){
                               minTemp = maximum - 20
                               }
                             if (maxTemp > maximum+20){
                               maxTemp = maximum + 20
                               }
                             return(list(minTemp,maxTemp))
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
