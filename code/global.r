# List of global variables
blank <- NULL 
counter <- 1 
helix <- c() 
molStateVal <- "" 
wavelengthVal <- ""
myConnector = NULL 
start <- 1 
df2 <- NULL
valuesT <- NULL
df3 <- NULL

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
                             capture.output(.self$object <- meltR.A(data_frame = df,
                                                                    blank = blank,
                                                                    NucAcid = NucAcid,
                                                                    Mmodel = Mmodel,
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
                             },
                           
                          #Construct a plot containing the raw data
                           constructRawPlot = function(sampleNum){
                             data = df[df$Sample == sampleNum,]
                             xmin = round(min(data$Temperature),digits = 4)
                             xmax = round(max(data$Temperature),digits = 4)
                             plot_ly(data, x = data$Temperature, y = data$Absorbance, type = "scatter", mode = "markers") %>%
                               layout(showlegend = FALSE) %>%
                               layout(
                                 shapes = list(
                                   list(type = "line", width = 4,line = list(color = "black"),x0 = xmin,x1 = xmin,y0 = 0,y1 = 1, yref = "paper"),
                                   list(type = "line", width = 4,line = list(color = "black"),x0 = xmax,x1 = xmax,y0 = 0,y1 = 1, yref = "paper")
                                   )
                                 ) %>% 
                               layout(xaxis=list(fixedrange=TRUE, title = "Temperature")) %>% 
                               layout(yaxis=list(fixedrange=TRUE, title = "Absorbance")) %>%
                               config(displayModeBar = FALSE)
                             },
                           
                           # Construct a plot of the first derivative and the raw data
                           constructFirstDerivative = function(sampleNum){
                             data = .self$fdData[.self$fdData == sampleNum,]
                             xmin = round(min(data$Temperature), digits = 4)
                             xmax = round(max(data$Temperature), digits = 4)
                             plot_ly(data, x = data$Temperature, y = data$Absorbance, type = "scatter", mode = "markers") %>%
                               add_markers(x = data$Temperature, y = data$yPlot+min(data$Absorbance), color = "blue") %>%
                               layout(
                                 shapes = list(
                                   list(type = "line", y0 = 0, y1 = 1, yref = "paper", x0 = data$Temperature[which.max(data$yPlot)], 
                                        x1 = data$Temperature[which.max(data$yPlot)], line = list(width = 1, dash = "dot"), editable = FALSE),
                                   list(type = "line", width = 4,line = list(color = "black"),x0 = xmin,x1 = xmin,y0 = 0,y1 = 1,yref = "paper", editable = TRUE),
                                   list(type = "line", width = 4,line = list(color = "black"),x0 = xmax,x1 = xmax,y0 = 0,y1 = 1,yref = "paper", editable = TRUE)
                                 )
                               ) %>%
                               layout(showlegend = FALSE) %>%
                               layout(xaxis=list(fixedrange=TRUE, title = "Temperature")) %>% 
                               layout(yaxis=list(fixedrange=TRUE, title = "Absorbance")) %>%
                               config(displayModeBar = FALSE)
                             },
                           
                           # Construct a plot of the best fit and the raw data
                           constructBestFit = function(sampleNum){
                             data = .self$object$Method.1.data
                             data = data[data$Sample == sampleNum,]
                             xmin = round(min(data$Temperature), digits = 4)
                             xmax = round(max(data$Temperature), digits = 4)
                             plot_ly(data, x = data$Temperature, y = data$Absorbance, type = "scatter", mode = "markers") %>%
                               add_lines(x = data$Temperature,y = data$Model, color = "red") %>%
                               layout(
                                 shapes = list(
                                   list(type = "line", width = 4,line = list(color = "black"),x0 = xmin,x1 = xmin,y0 = 0,y1 = 1,yref = "paper"),
                                   list(type = "line", width = 4,line = list(color = "black"),x0 = xmax,x1 = xmax,y0 = 0,y1 = 1,yref = "paper")
                                 )
                               ) %>%
                               layout(showlegend = FALSE) %>%
                               layout(xaxis=list(fixedrange=TRUE, title = "Temperature")) %>% 
                               layout(yaxis=list(fixedrange=TRUE, title = "Absorbance"))%>%
                               config(displayModeBar = FALSE)
                             },
                           
                           # Construct a plot of the best fit, first derivative, and the raw data
                           constructBoth = function(sampleNum){
                             data1 = .self$object$Derivatives.data[.self$object$Derivatives.data == sampleNum,]
                             data2 = .self$object$Method.1.data[.self$object$Method.1.data$Sample == sampleNum,]
                             xmin = round(min(data1$Temperature), digits = 4)
                             xmax = round(max(data1$Temperature), digits = 4)
                             coeff = 4000 #Static number to shrink data to scale
                             upper = max(data1$dA.dT)/max(data1$Ct) + coeff
                             plot_ly(data2, x = data2$Temperature, y = data2$Absorbance, type = "scatter", mode = "markers") %>%
                               add_lines(x = data2$Temperature, y = data2$Model, color = "red") %>%
                               add_markers(x = data1$Temperature, y = (data1$dA.dT/(data1$Pathlength*data1$Ct))/upper+min(data1$Absorbance), color = "blue") %>%
                               layout(
                                 shapes = list(
                                   list(type = "line", y0 = 0, y1 = 1, yref = "paper", x0 = data1$Temperature[which.max(data1$dA.dT)], 
                                        x1 = data1$Temperature[which.max(data1$dA.dT)], line = list(width = 1, dash = "dot"), editable = FALSE),
                                   list(type = "line", width = 4,line = list(color = "black"),x0 = xmin,x1 = xmin,y0 = 0,y1 = 1,yref = "paper", editable = TRUE),
                                   list(type = "line", width = 4,line = list(color = "black"),x0 = xmax,x1 = xmax,y0 = 0,y1 = 1,yref = "paper", editable = TRUE)
                                 )
                               ) %>%
                               layout(showlegend = FALSE) %>%
                               layout(xaxis=list(fixedrange=TRUE, title = "Temperature")) %>% 
                               layout(yaxis=list(fixedrange=TRUE, title = "Absorbance"))%>%
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
