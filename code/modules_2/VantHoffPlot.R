
VantHoffPlot <- function(input, output, session, chosenMethods, vantData, vals, datasetsUploadedID, temperatureUpdatedID) {
  output$vantPlot <- renderPlot({
    if (chosenMethods[2] == TRUE) {
      logInfo("VAN'T HOFF RENDERED")
      keep <- vantData[vals$keeprows, , drop = FALSE]
      exclude <- vantData[!vals$keeprows, , drop = FALSE]
      if (nrow(keep) == 0) {
        vals$keeprows <- rep(TRUE, nrow(vantData))
      }
      rValue <- format(sqrt(summary(lm(invT ~ lnCt, keep))$r.squared), digits = 3)
      vantGgPlot <<- ggplot(keep, aes(x = lnCt, y = invT)) +
        geom_point() +
        geom_smooth(formula = y ~ x, method = lm, fullrange = TRUE, color = "black", se = F, linewidth = .5, linetype = "dashed") +
        geom_point(data = exclude, shape = 21, fill = NA, color = "black", alpha = 0.25) +
        labs(y = "Inverse Temperature(K)", x = "ln(Concentration(M))", title = "van't Hoff") +
        annotate("text", x = Inf, y = Inf, color = "#333333", label = paste("r = ", toString(rValue)), size = 7, vjust = 1, hjust = 1) +
        theme(plot.title = element_text(hjust = 0.5))
      vantGgPlot
    }
  })
  
  # Remove points from Van't Hoff plot that are clicked
  observeEvent(
    eventExpr = input$vantClick,
    handlerExpr = {
      if (chosenMethods[2] == TRUE) {
        res <- nearPoints(vantData, input$vantClick, allRows = TRUE)
        vals$keeprows <- xor(vals$keeprows, res$selected_)
      }
    }
  )

  # Remove brushed points from Van't Hoff when the "Brushed" button is clicked.
  observeEvent(
    eventExpr = input$removeBrushedID,
    handlerExpr = {
      if (chosenMethods[2] == TRUE) {
        res <- brushedPoints(vantData, input$vantBrush, allRows = TRUE)
        vals$keeprows <- xor(vals$keeprows, res$selected_)
      }
    }
  )

  # Reset the Van't Hoff plot when the "Reset" button is clicked.
  observeEvent(
    eventExpr = input$resetVantID,
    handlerExpr = {
      if (chosenMethods[2] == TRUE) {
        vals$keeprows <- rep(TRUE, nrow(vantData))
      }
    }
  )

  # Disable "Van't Hoff" tab when method 2 is unselected
  observeEvent(
    eventExpr = c(datasetsUploadedID(), temperatureUpdatedID()),
    handlerExpr = {
      if (chosenMethods[2] == FALSE) {
        disable(selector = '.navbar-nav a[data-value="Vant Hoff Plot"')
      } else if (chosenMethods[2] == TRUE) {
        enable(selector = '.navbar-nav a[data-value="Vant Hoff Plot"')
      }
    }
  )
}