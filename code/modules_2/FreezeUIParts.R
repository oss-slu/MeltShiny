FreezeUIParts <- function(input, session, datasetsUploadedID, temperatureUpdatedID) {
  observeEvent(
    eventExpr = c(datasetsUploadedID(), temperatureUpdatedID),
    handlerExpr = {
      if (datasetsUploadedID() == TRUE) {
        disable("blankSampleID")
        disable("inputFileID")
        disable("datasetsUploadedID")
        disable("noBlanksID")
        disable("uploadData")
      }
    }
  )
  
  observe(
    if (input$noBlanksID == TRUE) {
      updateTextInput(session, "blankSampleID", value = "none")
      disable("blankSampleID")
    } else if (input$noBlanksID == FALSE) {
      updateTextInput(session, "blankSampleID", value = 1)
      enable("blankSampleID")
    }
  )
  
  observe(
    if (input$extinctConDecisionID == "Nucleic acid sequence(s)") {
      updateTextInput(session, "helixID", placeholder = "E.g: RNA", label = "Specify nucleic acid type")
      updateTextInput(session, "seqID", placeholder = "E.g: CGAAAGGU,ACCUUUCG", label = "Specify sequences")
      enable("helixID")
    } else if (input$extinctConDecisionID == "Custom molar extinction coefficients") {
      updateTextInput(session, "seqID", placeholder = "E.g: Custom, 10000, 20000", label = "Specify coefficients")
      updateTextInput(session, "helixID", placeholder = "Disabled")
      disable("helixID")
    }
  )
  
  observe(
    if (input$Tm_methodID == "nls" && ("Method 2" %in% input$methodsID) == TRUE) {
      enable("weightedTmID")
    } else {
      disable("weightedTmID")
    }
  )

  # Disable "Analysis" and "Results tabs until all files have successfully been uploaded
  observeEvent(
    eventExpr = c(datasetsUploadedID(), temperatureUpdatedID()),
    handlerExpr = {
      if (datasetsUploadedID() == FALSE) {
        disable(selector = '.navbar-nav a[data-value="Analysis"')
        disable(selector = '.navbar-nav a[data-value="Results"')
      } else {
        logInfo("PROCESSING COMPLETE")
        enable(selector = '.navbar-nav a[data-value="Analysis"')
        enable(selector = '.navbar-nav a[data-value="Results"')
      }
    }
  )
}
