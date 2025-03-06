DownloadHandler <- function(input, output, vantGgPlot, summaryDataTable, errorDataTable, valuesT) {
  
  # Save the Van't Hoff Plot in the chosen format
  output$downloadVantID <- downloadHandler(
    filename = function() {
      if (input$saveNameVantID == "") {
        return(paste("VantHoffPlot", ".", input$vantDownloadFormatID, sep = ""))
      } else {
        return(paste(input$saveNameVantID, ".", input$vantDownloadFormatID, sep = ""))
      }
    },
    content = function(file) {
      ggsave(filename = file, plot = vantGgPlot, width = 18, height = 10)
    }
  )

  # Save the Results Table in the chosen format
  output$downloadTableID <- downloadHandler(
    filename = function() {
      if (input$saveNameTableID == "") {
        return(paste("ResultsTable", ".", input$tableFileFormatID, sep = ""))
      } else {
        return(paste(input$saveNameTableID, ".", input$tableFileFormatID, sep = ""))
      }
    },
    content = function(file2) {
      # Default to "All of the Above" if no checkboxes are selected
      tableParts <- if (is.null(input$tableDownloadsPartsID) || length(input$tableDownloadsPartsID) == 0) {
        c("All of the Above")
      } else {
        input$tableDownloadsPartsID
      }

      selectedParts <- list()
      if ("Individual Fits" %in% tableParts || "All of the Above" %in% tableParts) {
        selectedParts$IndividualFits <- valuesT$individualFitData %>% select(-c(Delete, ID))
      }
      if ("Method Summaries" %in% tableParts || "All of the Above" %in% tableParts) {
        selectedParts$MethodsSummaries <- summaryDataTable
      }
      if ("Percent Error" %in% tableParts || "All of the Above" %in% tableParts) {
        selectedParts$PercentError <- errorDataTable
      }

      # Write the selected parts to the file
      if (input$tableFileFormatID == "csv") {
        write.csv(selectedParts, file = file2)
      } else {
        write.xlsx(selectedParts, file = file2)
      }
    }
  )
}
