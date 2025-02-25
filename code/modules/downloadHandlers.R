# modules/download_handlers.R

setupDownloadHandlers <- function(input, output, session) {
  output$downloadVantID <- downloadHandler(
    filename = function() {
      if (input$saveNameVantID == "")
        paste("VantHoffPlot", ".", input$vantDownloadFormatID, sep = "")
      else
        paste(input$saveNameVantID, ".", input$vantDownloadFormatID, sep = "")
    },
    content = function(file) {
      ggsave(filename = file, plot = vantGgPlot, width = 18, height = 10)
    }
  )
  
  output$downloadTableID <- downloadHandler(
    filename = function() {
      if (input$saveNameTableID == "")
        paste("ResultsTable", ".", input$tableFileFormatID, sep = "")
      else
        paste(input$saveNameTableID, ".", input$tableFileFormatID, sep = "")
    },
    content = function(file2) {
      tableParts <- if (is.null(input$tableDownloadsPartsID) || length(input$tableDownloadsPartsID) == 0)
        c("All of the Above")
      else
        input$tableDownloadsPartsID
      
      selectedParts <- list()
      if ("Individual Fits" %in% tableParts || "All of the Above" %in% tableParts)
        selectedParts$IndividualFits <- valuesT$individualFitData %>% select(-c(Delete, ID))
      if ("Method Summaries" %in% tableParts || "All of the Above" %in% tableParts)
        selectedParts$MethodsSummaries <- summaryDataTable
      if ("Percent Error" %in% tableParts || "All of the Above" %in% tableParts)
        selectedParts$PercentError <- errorDataTable
      
      if (input$tableFileFormatID == "csv")
        write.csv(selectedParts, file = file2)
      else
        write.xlsx(selectedParts, file = file2)
    }
  )
}
