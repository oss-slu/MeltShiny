# modules/dynamic_tabs.R

observeDynamicTabs <- function(input, output, session) {
  observeEvent(input$uploadData, {
    req(masterFrame)
    # Create dynamic tabs for each sample
    for (i in 1:numSamples) {
      if (i != blankInt) {
        tabName <- paste("Sample", i)
        dtID <- paste0(i, "DT")
        insertUI(
          selector = "#placeholder",
          ui = tags$div(
            id = as.character(i),
            DT::dataTableOutput(dtID),
            hr(style = "border-top: 1px solid #000000;")
          )
        )
        output[[dtID]] <- DT::renderDataTable({
          datatable(  # Assuming each dataset is stored in a list if multiple uploads
            masterFrame,
            class = "cell-border stripe",
            selection = "none",
            options = list(searching = FALSE, ordering = FALSE),
            caption = paste("Table", i, "Dataset", i)
          )
        })
      }
    }
    
    # Render Plotly plots for each sample
    for (i in 1:numSamples) {
      if (i != blankInt) {
        local({
          myI <- i
          output[[paste0("plotBoth", myI)]] <- renderPlotly({
            analysisPlot <- myConnecter$constructAllPlots(myI)
            if (isTRUE(input[[paste0("bestFit", myI)]]))
              analysisPlot <- analysisPlot %>% add_lines(x = bestFitXData[[myI]], y = bestFitYData[[myI]], color = "red")
            if (isTRUE(input[[paste0("firstDerivative", myI)]]))
              analysisPlot <- analysisPlot %>% add_trace(x = derivativeXData[[myI]], y = derivativeYData[[myI]], marker = list(color = "green"))
            analysisPlot
          })
        })
      }
    }
  })
}

# Van't Hoff plot renderer (can be triggered when temperature or dataset updates)
renderVantHoffPlotModule <- function(input, output, session) {
  output$vantPlot <- renderPlot({
    if (chosenMethods[2] && molStateVal != "Monomolecular.2State") {
      keep <- vantData[vals$keeprows, , drop = FALSE]
      exclude <- vantData[!vals$keeprows, , drop = FALSE]
      if (nrow(keep) == 0)
        vals$keeprows <- rep(TRUE, nrow(vantData))
      rValue <- format(sqrt(summary(lm(invT ~ lnCt, keep))$r.squared), digits = 3)
      vantGgPlot <<- ggplot(keep, aes(x = lnCt, y = invT)) +
        geom_point() +
        geom_smooth(formula = y ~ x, method = lm, fullrange = TRUE,
                    color = "black", se = FALSE, linewidth = 0.5, linetype = "dashed") +
        geom_point(data = exclude, shape = 21, fill = NA, color = "black", alpha = 0.25) +
        labs(y = "Inverse Temperature(K)", x = "ln(Concentration(M))", title = "van't Hoff") +
        annotate("text", x = Inf, y = Inf, color = "#333333",
                 label = paste("r = ", toString(rValue)), size = 7, vjust = 1, hjust = 1) +
        theme(plot.title = element_text(hjust = 0.5))
      vantGgPlot
    }
  })
}
