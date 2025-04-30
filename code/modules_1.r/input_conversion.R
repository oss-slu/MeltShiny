validate_sequences <- function(sequence_input, molecular_state) {
  sequence_input <- gsub(" ", "", sequence_input)  # remove any spaces
  allowed_chars <- "ACGUT"

  if (molecular_state == "Heteroduplex") {
    if (lengths(gregexpr(",", sequence_input))[[1]] != 1) {
      return(FALSE)  # must contain exactly one comma
    }
    sequences <- unlist(strsplit(sequence_input, ","))
    if (length(sequences) != 2) {
      return(FALSE)  # must split into exactly two sequences
    }
    if (any(!grepl(paste0("^[" , allowed_chars , "]+$"), sequences))) {
      return(FALSE)  # each sequence must contain only ACGUT
    }
  } else {
    # For Homoduplex and Monomolecular
    if (grepl(",", sequence_input)) {
      return(FALSE)  # comma not allowed
    }
    if (!grepl(paste0("^[" , allowed_chars , "]+$"), sequence_input)) {
      return(FALSE)  # only valid characters allowed
    }
  }
  return(TRUE)
}


process_valid_input <- function(input, session,datasetsUploadedID) {
  if (!validate_sequences(input$seqID, input$molecularStateID)) {
    shinyalert::shinyalert(
      title = "Invalid Sequence Input",
      text = if (input$molecularStateID == "Heteroduplex") {
        "Please input two valid sequences separated by exactly one comma (only A, C, G, U, T allowed)."
      } else {
        "Please input a valid single sequence with only A, C, G, U, T characters (no commas)."
      },
      type = "error"
    )
    return()  # stop processing if invalid
  }

  logInfo("VALID INPUT")
  
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
