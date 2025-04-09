### modules_2/ResultsTable.R
ResultsTable <- function(input, output, session, valuesT, datasetsUploadedID, individualFitData, summaryDataTable, errorDataTable, is_valid_input) {
  # Create reactive values to track when analysis should be updated
  analysisUpdate <- reactiveVal(0)
  
  
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

        #Initialize analysis counter
        analysisUpdate(1)
      }
    }
  )
  

  # Keep track of removed samples
  removedSamples <- reactiveVal(c())


  # Remove row from individual fits table when its respective "Remove" button is pressed.
  observeEvent(eventExpr = input$delete_button, handlerExpr = {
    selectedRow <- as.numeric(strsplit(input$delete_button, "_")[[1]][2])
    
    #Get the sample ID to be removed
    sampleToRemove <- valuesT$individualFitData[valuesT$individualFitData$ID == selectedRow, "Sample"]

    #remove from table display
    valuesT$individualFitData <<- subset(valuesT$individualFitData, ID != selectedRow)

    # Update the MeltR object by setting the sample as an outlier
    if(!is.null(myConnecter) && !is.null(sampleToRemove)) {
      logInfo(paste("Removing sample", sampleToRemove, "from analysis"))
      
      # Add to  list of removed samples
      current <- removedSamples()
      removedSamples(c(current, sampleToRemove))
      
      # Update outliers in myConnecter and reconstruct
      myConnecter$outliers <- removedSamples()
      myConnecter$constructObject()
      
      # Increment the analysis update counter to trigger reactivity
      analysisUpdate(analysisUpdate() + 1)
    }
  })

  # Reset the individual fits table to original when "Reset" button is pressed.
  observeEvent(
    eventExpr = input$resetTable1ID == TRUE,
    handlerExpr = {
      # Reset outliers in the MeltR object
      if(!is.null(myConnecter)) {
        logInfo("Resetting analysis to include all samples")
        
        # Clear our list of removed samples
        removedSamples(c())
        
        # Reset outliers and reconstruct
        myConnecter$outliers <- NA
        myConnecter$constructObject()
        
        # Increment the analysis update counter to trigger reactivity
        analysisUpdate(analysisUpdate() + 1)
      }

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

    analysisUpdate()

    sumData1 <- myConnecter$summaryData1()
    sumData2 <- myConnecter$summaryData2()
    sumData3 <- myConnecter$summaryData3()
    
    # Combine them within the function scope
    updatedTable <- rbind(sumData1, sumData2, sumData3)
    
    # Update the global variable
    summaryDataTable <<- updatedTable
    
    return(updatedTable)
  })
  
  output$errorTable <- renderTable({

    analysisUpdate()
    
    updatedErrorTable <- myConnecter$errorData()
    
    errorDataTable <<- myConnecter$errorData()
    return(errorDataTable)
  })
}