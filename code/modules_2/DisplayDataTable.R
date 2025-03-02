DisplayDataTable <- function(input, output, session, dataList, numUploads, is_valid_input) {
  observeEvent(
    eventExpr = input$uploadData,
    handlerExpr = {
      req(is_valid_input)
      logInfo("DISPLAYING UPLOADED DATASET")
      if (is_valid_input) {
        divID <- toString(numUploads)
        dtID <- paste0(divID, "DT")
        insertUI(
          selector = "#placeholder",
          ui = tags$div(
            id = divID,
            DT::dataTableOutput(dtID),
            hr(style = "border-top: 1px solid #000000;")
          )
        )
      
        output[[dtID]] <- DT::renderDataTable({
          datatable(dataList[[numUploads]],
            class = "cell-border stripe",
            selection = "none",
            options = list(searching = FALSE, ordering = FALSE),
            caption = paste0("Table ", toString(numUploads), " Dataset ", toString(numUploads))
          )
        })
      }
    }
  )
}
