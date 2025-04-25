DynamicTabs <- function(input, output, session, numSamples, blankInt, datasetsUploadedID, is_valid_input, fittingTriggered, plotRefreshTrigger) {
  observeEvent(
    eventExpr = datasetsUploadedID(),
    handlerExpr = {
      req(is_valid_input)
      start <<- 1
      if (datasetsUploadedID() == TRUE) {
        lapply(
          start:numSamples,
          function(i) {
            if (i != blankInt) {
              tabName <- paste("Sample", i, sep = " ")
              appendTab(
                inputId = "tabs",
                tab = tabPanel(
                  tabName,
                  fluidPage(
                    sidebarLayout(
                      sidebarPanel(
                        h4("Options:"),
                        checkboxInput(inputId = paste0("bestFit", i), label = "Show best fit line"),
                        checkboxInput(inputId = paste0("firstDerivative", i), label = "Show derivative")
                      ),
                      mainPanel(
                        plotlyOutput(paste0("plotBoth", i))
                      )
                    )
                  )
                )
              )
            }
          }
        )
        start <<- numSamples + 1
      }
    }
  )

  # Dynamically create the analysis plot for each of the n sample tabs
  observeEvent(
    eventExpr = datasetsUploadedID(),
    handlerExpr = {
      req(is_valid_input)
      if (datasetsUploadedID() == TRUE) {
        # Initialize variables for accessing best fit and derivative information
        bestFitXData <<- vector("list", numSamples)
        bestFitYData <<- vector("list", numSamples)
        derivativeXData <<- vector("list", numSamples)
        derivativeYData <<- vector("list", numSamples)
        xRange <<- vector("list", numSamples)

        # Create plots
        for (i in 1:numSamples) {
          if (i != blankInt) {
            local({
              myI <- i

              output[[paste0("plotBoth", myI)]] <- renderPlotly({
                plotRefreshTrigger()
                analysisPlot <- myConnecter$constructAllPlots(myI, fittingTriggered)
                if (input[[paste0("bestFit", myI)]] == TRUE) {
                  analysisPlot <- analysisPlot %>% add_lines(x = bestFitXData[[myI]], y = bestFitYData[[myI]], color = "red")
                }
                if (input[[paste0("firstDerivative", myI)]] == TRUE) {
                  analysisPlot <- analysisPlot %>% add_trace(x = derivativeXData[[myI]], y = derivativeYData[[myI]], marker = list(color = "green"))
                }
                analysisPlot
              })
              observeEvent(event_data(source = paste0("plotBoth", myI), event = "plotly_relayout", priority = c("event")), {
                xRange[[myI]] <<- event_data(source = paste0("plotBoth", myI), event = "plotly_relayout", priority = c("event"))$xaxis.range[1:2]
                output[[paste0("xrange", myI)]] <- renderText({
                  paste0(" x-range: [", round(xRange[[myI]][1], 2), ", ", round(xRange[[myI]][2], 2), "]")
                })
              })
            })
          }
        }
        logInfo("ANALYSIS PLOTS RENDERED ")
      }
    }
  )
}
