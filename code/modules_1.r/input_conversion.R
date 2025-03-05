process_valid_input <- function(input, session,datasetsUploadedID) {
  if (is_valid_input) {
    logInfo("VALID INPUT")

    # The datasets are now 'uploaded' and ready for analysis
    datasetsUploadedID(TRUE)
    shinyjs::show("resetData")

    masterFrame <<- NULL
    dataList <<- list()
    numUploads <<- 0
    numSamples <<- 0

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

    # Store the tm method information
    tmMethodVal <<- toString(input$Tm_methodID)

    # Store the weighted tm information for method 2
    weightedTmVal <<- gsub(" ", "", input$weightedTmID)

    # Store the selected methods
    selectedMethods <- input$methodsID
    chosenMethods[2] <<- "Method 2" %in% selectedMethods
    chosenMethods[3] <<- "Method 3" %in% selectedMethods

    # Store and format molecular state information
    molStateVal <<- input$molecularStateID
    molStateVal <<- switch(molStateVal,
      "Heteroduplex" = "Heteroduplex.2State",
      "Homoduplex" = "Homoduplex.2State",
      "Monomolecular.2State"
    )

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
