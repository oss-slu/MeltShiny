# server.R handles input validation and analysis.
# It initiates processing and dynamically creates information displayed on analysis graphs.
source("modules_1.r/error_handling.R")
source("modules_1.r/input_conversion.R")
source("modules_1.r/meltR_obj_creation.R")
source("modules_2/DisplayDataTable.R")
source("modules_2/DownloadHandler.R")
source("modules_2/DynamicTabs.R")
source("modules_2/FreezeUIParts.R")
source("modules_2/ResultsTable.R")
source("modules_2/UIcode.R")
source("modules_2/VantHoffPlot.R")

server <- function(input, output, session) {
  # Declare initial value for data upload button check
  is_valid_input <<- reactiveVal(FALSE)

  # Prevent manual input to temperatureID button
  disable("temperatureID")
  disable("submit")

  # Declaring datasetsUploadedID as reactive for upload data button click
  datasetsUploadedID <- reactiveVal(FALSE)

  # Declaring temperatureUpdatedID as reactive for manual changes to the temperature
  temperatureUpdatedID <- reactiveVal(FALSE)

  # Declaring fittingTriggered as a reactive for manual baseline trimming
  fittingTriggered <- reactiveVal(FALSE)
  plotRefreshTrigger <- reactiveVal(0)

  observeEvent(input$toggleAdvanced, {
    shinyjs::toggle("advancedSettings")  # Toggles visibility on button click
  })

  observeEvent(input$molecularStateID, {
    if (input$molecularStateID == "Monomolecular") {
      updateCheckboxGroupInput(session, "methodsID", selected = setdiff(input$methodsID, "Method 2"))

      shinyjs::disable(selector = "input[value = 'Method 2']")
    } else {
      shinyjs::enable(selector = "input[value='Method 2']")
    }
  })

  observeEvent(input$resetData, {
    session$reload()
  })

  # If temperature is manually edited, update concTVal
  observeEvent(input$submit, {
    if (input$temperatureID != "") {
      concTVal <<- as.numeric(input$temperatureID) # Set concTVal to new temperature

      # Call the MeltR analysis event with the newly updated temperature
      logInfo(paste("TEMPERATURE UPDATED TO", concTVal, "- REPROCESSING"))
      temperatureUpdatedID(TRUE)
      VantHoffPlot(input, output, session, chosenMethods, vantData, vals, datasetsUploadedID, temperatureUpdatedID)
      temperatureUpdatedID(FALSE)
    }
  })

  observeEvent(input$manualFitID, {
    fittingTriggered(TRUE)
    plotRefreshTrigger(plotRefreshTrigger() + 1)
  })


  # Prevent Rplots.pdf from generating
  if (!interactive()) pdf(NULL)


  
  observeEvent(input$uploadData, {
    shinyjs::show("loadingSpinner")  # Show spinner immediately

    validate_inputs(input, session)

    if (is_valid_input) {
      session$sendCustomMessage(type = 'scrollToTop', message = list())
      process_valid_input(input, session, datasetsUploadedID)
      process_meltR_object(datasetsUploadedID, temperatureUpdatedID, VantHoffPlot, input, output, session)
      ResultsTable(input, output, session, valuesT, datasetsUploadedID, individualFitData, summaryDataTable, errorDataTable, is_valid_input)
      DownloadHandler(input, output, vantGgPlot, summaryDataTable, errorDataTable, valuesT, individualFitData)
    }

    shinyjs::hide("loadingSpinner")  # Hide spinner after work is done
    # Hide just the sidebar contents, show the toggle button inside the panel
    shinyjs::hide("fileSidebarContents")
    shinyjs::show("sidebarToggleButton")
  })

  observeEvent(input$showSidebar, {
    shinyjs::show("fileSidebarContents")
    shinyjs::hide("sidebarToggleButton")
  })


  
  FreezeUIParts(input, session, datasetsUploadedID, temperatureUpdatedID)

  # Show the uploaded datasets separately on the uploads page
  DisplayDataTable(input, output, session, dataList, numUploads, is_valid_input)

  # Dynamically create n tabs (n = number of samples in master data frame) for
  # the "Graphs" page under the "Analysis" navbarmenu.
  DynamicTabs(input, output, session, numSamples, blankInt, datasetsUploadedID, is_valid_input, fittingTriggered, plotRefreshTrigger)

  # Create the Results Table
  

  # Download Hanlder to download parts (or all) of the Results Table or Van't Hoff Plot
  

  # observeEvents for the UI elements
  UIcode(input, session)  

}