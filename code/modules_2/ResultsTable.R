### modules_2/ResultsTable.R
ResultsTable <- function(input, output, session, valuesT, datasetsUploadedID, individualFitData, summaryDataTable, errorDataTable, is_valid_input) {
  # Function for dynamically creating the delete button for each row on the individual fits table
  shinyInput <- function(FUN, len, id, ...) {
    inputs <- character(len)
    for (i in seq_len(len)) {
      inputs[i] <- as.character(FUN(paste0(id, i), ...))
    }
    inputs
  }
  
  getListUnder <- function() {
    req(datasetsUploadedID())
    if (datasetsUploadedID() == TRUE) {
      individualFitData$Delete <- shinyInput(actionButton, nrow(individualFitData), "delete_",
        label = "Remove",
        style = "color: red;background-color: white",
        onclick = paste0('Shiny.onInputChange( "delete_button" , this.id, {priority: "event"})')
      )
      individualFitData$ID <- seq.int(nrow(individualFitData))
      return(individualFitData)
    }
  }
  
  observeEvent(
    eventExpr = datasetsUploadedID(),
    handlerExpr = {
      req(is_valid_input)
      if (datasetsUploadedID() == TRUE) {
        valuesT <<- reactiveValues(individualFitData = NULL)
        valuesT$individualFitData <- isolate({
          getListUnder()
        })
      }
    }
  )
  
  # Remove row from individual fits table when its respective "Remove" button is pressed.
  observeEvent(eventExpr = input$delete_button, handlerExpr = {
    selectedRow <- as.numeric(strsplit(input$delete_button, "_")[[1]][2])
    valuesT$individualFitData <<- subset(valuesT$individualFitData, ID != selectedRow)
  })

  # Reset the individual fits table to original when "Reset" button is pressed.
  observeEvent(
    eventExpr = input$resetTable1ID == TRUE,
    handlerExpr = {
      valuesT$individualFitData <- isolate({
        getListUnder()
      })
    }
  )
  
  output$individualFitsTable <- DT::renderDataTable({
    DT::datatable(
      valuesT$individualFitData,
      filter = "none",
      rownames = F,
      extensions = "FixedColumns",
      class = "cell-border stripe",
      selection = "none",
      options = list(
        dom = "t",
        searching = FALSE,
        ordering = FALSE,
        fixedColumns = list(leftColumns = 2),
        pageLength = 100,
        columnDefs = list(list(targets = c(7), visible = FALSE))
      ),
      escape = F
    )
  })
  
  output$methodSummaryTable <- renderTable({
    summaryDataTable <<- rbind(summaryDataTable, myConnecter$summaryData1())
    summaryDataTable <<- rbind(summaryDataTable, myConnecter$summaryData2())
    summaryDataTable <<- rbind(summaryDataTable, myConnecter$summaryData3())
    return(summaryDataTable)
  })
  
  output$errorTable <- renderTable({
    errorDataTable <<- myConnecter$errorData()
    return(errorDataTable)
  })
}