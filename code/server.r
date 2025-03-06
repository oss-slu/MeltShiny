# server.R handles input validation and analysis.
# It initiates processing and dynamically creates information displayed on analysis graphs.
source("modules_1.r/error_handling.R")
source("modules_1.r/Input_conversion.R")
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

  observeEvent(input$toggleAdvanced, {
    shinyjs::toggle("advancedSettings")  # Toggles visibility on button click
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


  # Prevent Rplots.pdf from generating
  if (!interactive()) pdf(NULL)


  
  
  
  observeEvent(
    eventExpr = input$uploadData,
    handlerExpr = {
      validate_inputs(input,session)
      if (is_valid_input) {
        logInfo("VALID INPUT")

        # The datasets are now 'uploaded' and ready for analysis
        datasetsUploadedID(TRUE)
        shinyjs::show("resetData")

        masterFrame <- NULL
        dataList <- list()
        numUploads <- 0
        numSamples <- 0

        # Verify that inputs are valid to display graph
        is_valid_input <<- TRUE

        # Store the wavelength information
        wavelengthVal <<- input$wavelengthID

        # Store the blank information and reset blank related inputs after each file upload
        if (input$noBlanksID == TRUE) {
          blank <<- "none"
          blankInt <<- 0
        } else {
          blank <<- as.numeric(gsub(" ", "", input$blankSampleID))
          blankInt <<- blank
        }
        enable("blankSampleID")
        updateTextInput(session, "blankSampleID", value = 1)
        updateCheckboxInput(session, "noBlanksID", value = FALSE)

        # Store the extinction coefficient information
        helix <<- trimws(strsplit(gsub(" ", "", paste(input$helixID, ",", toupper(input$seqID))), ",")[[1]], which = "both")
        
        helix <<- trimws(strsplit(gsub(" ", "", paste(input$helixID, ",", toupper(input$seqID))), ",")[[1]], which = "both")
        
        # Store the tm method information
        tmMethodVal <<- toString(input$Tm_methodID)

        # Store the weighted tm information for method 2
        weightedTmVal <<- gsub(" ", "", input$weightedTmID)

        # Store the selected methods
        selectedMethods <- input$methodsID
        if (("Method 2" %in% selectedMethods) == FALSE) {
          chosenMethods[2] <<- FALSE
        } else {
          chosenMethods[2] <<- TRUE
        }
        if (("Method 3" %in% selectedMethods) == FALSE) {
          chosenMethods[3] <<- FALSE
        } else {
          chosenMethods[3] <<- TRUE
        }

        # Store and format molecular state information
        molStateVal <<- input$molecularStateID
        if (molStateVal == "Heteroduplex") {
          molStateVal <<- "Heteroduplex.2State"
        } else if (molStateVal == "Homoduplex") {
          molStateVal <<- "Homoduplex.2State"
        } else {
          molStateVal <<- "Monomolecular.2State"
        }


        # Disable widgets whose values apply to all datasets
        disable("helixID")
        disable("molecularStateID")
        disable("wavelengthID")
        disable("temperatureID")
        disable("methodsID")
        disable("Tm_methodID")
        disable("weightedTmID")
        disable("extinctConDecisionID")

        # Open the uploaded file
        fileName <- input$inputFileID$datapath
        raw_data <- read.csv(file = fileName)

        highest_temp <- max(raw_data$Temperature, na.rm = TRUE)
        updateTextInput(session, "temperatureID", value = highest_temp)

        # Store the temperature used to calculate the concentration with Beers law
        concTVal <<- as.numeric(gsub(" ", "", highest_temp))

        # Re-enable the temperature field for manual input
        enable("temperatureID")
        enable("submit")

        # Sort Sample column from lowest to highest
        data <- raw_data %>% arrange(Sample)

        dataList <<- append(dataList, list(data))
        numUploads <<- numUploads + 1
        numSamples <<- numSamples + length(unique(data$Sample))
        masterFrame <<- rbind(masterFrame, data)
      }
    }
  )



  # Once all datasets have been uploaded, create the MeltR object and derive necessary information
  observeEvent(
    eventExpr = c(datasetsUploadedID(), temperatureUpdatedID()),
    handlerExpr = {
      req(is_valid_input)
      if (datasetsUploadedID() == TRUE) {
        disable(selector = '.navbar-nav a[data-value="Help"')
        disable(selector = '.navbar-nav a[data-value="File"')
        disable("blankSampleID")
        disable("inputFileID")
        disable("datasetsUploadedID")
        disable("noBlanksID")
        disable("uploadData")
        Sys.sleep(5)
        enable(selector = '.navbar-nav a[data-value="Help"')
        enable(selector = '.navbar-nav a[data-value="File"')
      }

      if (datasetsUploadedID() == TRUE) {
        logInfo("CREATING MELTR OBJECT")
        # Send stored input values to the connecter class to create a MeltR object
        myConnecter <<- connecter(
          df = masterFrame,
          NucAcid = helix,
          wavelength = wavelengthVal,
          blank = blank,
          Tm_method = tmMethodVal,
          outliers = NA,
          Weight_Tm_M2 = weightedTmVal,
          Mmodel = molStateVal,
          methods = chosenMethods,
          concT = concTVal
        )
        myConnecter$constructObject() 
        # Store data necessary for generating the Vant Hoff plot and the results table
        # IMPORTANT NOTE there should be no vant hoff plot for molStateVal Monomolecular
        vantData <<- myConnecter$gatherVantData()
        individualFitData <<- myConnecter$indFitTableData()

        # Variable that handles the points on the Van't Hoff plot for removal
        if (chosenMethods[2] == TRUE && molStateVal != "Monomolecular.2State") {
          vals <<- reactiveValues(keeprows = rep(TRUE, nrow(vantData)))
          showTab("navbarPageID", "vantHoffPlotTab")
          # Initially render the Vant Hoff Plot
          VantHoffPlot(input, output, session, chosenMethods, vantData, vals, datasetsUploadedID, temperatureUpdatedID)
        } else if (molStateVal == "Monomolecular.2State"){
          hideTab("navbarPageID", "vantHoffPlotTab")
        }
      }
    }
  )

  # Freeze parts of the UI while the dataset is being uploaded
  FreezeUIParts(input, session, datasetsUploadedID, temperatureUpdatedID)

  # Show the uploaded datasets separately on the uploads page
  DisplayDataTable(input, output, session, dataList, numUploads, is_valid_input)

  # Dynamically create n tabs (n = number of samples in master data frame) for
  # the "Graphs" page under the "Analysis" navbarmenu.
  DynamicTabs(input, output, session, numSamples, blankInt, datasetsUploadedID, is_valid_input)

  # Create the Results Table
  ResultsTable(input, output, session, valuesT, datasetsUploadedID, individualFitData, summaryDataTable, errorDataTable, is_valid_input)

  # Download Hanlder to download parts (or all) of the Results Table or Van't Hoff Plot
  DownloadHandler(input, output, vantGgPlot, summaryDataTable, errorDataTable, valuesT)

  # observeEvents for the UI elements
  UIcode(input, session)  
}
