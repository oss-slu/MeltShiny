# server.R handles input validation and analysis.
# It initiates processing and dynamically creates information displayed on analysis graphs.
source("modules_2/DisplayDataTable.R")
source("modules_2/DownloadHandler.R")
source("modules_2/DynamicTabs.R")
source("modules_2/FreezeUIParts.R")
source("modules_2/ResultsTable.R")
source("modules_2/UIcode.R")
source("modules_2/VantHoffPlot.R")


server <- function(input, output, session) {
  # Declare initial value for data upload button check
  is_valid_input <- reactiveVal(FALSE)

  # Prevent manual input to temperatureID button
  disable("temperatureID")
  disable("submit")

  # Declaring datasetsUploadedID as reactive for upload data button click
  datasetsUploadedID <- reactiveVal(FALSE)

  # Declaring temperatureUpdatedID as reactive for manual changes to the temperature
  temperatureUpdatedID <- reactiveVal(FALSE)

  # reusable error catching function
  handleError <- function(title, message) {
    # Display a modal with a custom title and message
    showModal(
      modalDialog(
        title = title,
        message,
        easyClose = TRUE,
        footer = modalButton("Close")
      )
    )
    
    
    # After the modal is closed, reset the session
    observeEvent(input$uploadData, {
      # Wait for the modal to be dismissed before resetting the session
      delay(5000, {
        session$reload()  # Reset the session
      })
    })
  }

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

  # Check if the value is an int
  can_convert_to_int <- function(x) {
    all(grepl("^(?=.)([+-]?([0-9]*)?)$", x, perl = TRUE))
  }

  # Check the nucleotide sequence to check if it belongs to DNA
  dna_letters_only <- function(x) {
    grepl("^[ATGC]+$", x, ignore.case = TRUE)
  }

  # Check the nucleotide sequence to check if it belongs to RNA
  rna_letters_only <- function(x) {
    grepl("^[AUGC]+$", x, ignore.case = TRUE)
  }
  

  # Handle the inputs and uploaded datasets
  observeEvent(
  eventExpr = input$uploadData,
  handlerExpr = {
    logInfo("CHECKING PROGRAM INPUTS")
    # Initially set is_valid_input to True
    is_valid_input <<- TRUE
    
    # Check if a file is uploaded
    if (is.null(input$inputFileID)) {
      is_valid_input <<- FALSE
      handleError("No File Uploaded", "Please upload a file before proceeding. The program will reset in 5 seconds.")
      return()  # Stop further execution
    }
    #Ensure file is a csv
    ext <- tools::file_ext(input$inputFileID$datapath)
    if (tolower(ext) != "csv") {
      is_valid_input <<- FALSE
      handleError("File Type Error", "The uploaded file is not a .csv file. The program will reset in 5 seconds")
      return()
    }
    #Try reading the CSV file
    df <- tryCatch({
      read.csv(input$inputFileID$datapath, stringsAsFactors = FALSE)
    }, error = function(e) {
      is_valid_input <<- FALSE
      handleError("File Read Error", "Error reading the CSV file. The program will reset in 5 seconds")
      return()
    })
    if (is.null(df)) return()  

    required_columns <- c("Sample", "Pathlength", "Temperature", "Absorbance")
    #Ensure the file has exactly 4 columns
    if (ncol(df) != 4) {
      is_valid_input <<- FALSE
      handleError("Column Error", "The CSV file must have exactly 4 columns. The program will reset in 5 seconds")
      return()
    }
    if (!identical(colnames(df), required_columns)) {
      is_valid_input <<- FALSE
      handleError("Column Name Error", "The columns must be named in this order: Sample, Pathlength, Temperature, Absorbance")
      return()
    }
    #Ensure the file has no missing values**
    if (anyNA(df)) {
      is_valid_input <<- FALSE
      handleError("Missing Data Error", "The file contains missing values. The program will reset in 5 seconds")
      return()
    }
    req(input$inputFileID)  # Ensure the file input is available
    # Read the dataset, treating empty strings as NA
    dataset <- read.csv(input$inputFileID$datapath, na.strings = c("NA", ""))

    # Check for blanks in the dataset
    has_blanks <- any(tolower(names(dataset)) == "blanks")



    if (input$noBlanksID) {  # 'No Blanks' checkbox is checked
      if (has_blanks) {
        is_valid_input <<- FALSE
        handleError("Blanks Found", "Remove blanks or uncheck the 'No Blanks' option. The program will reset in 5 seconds.")
        return()  # Stop further execution
      }
      
      if ((input$helixID == "" && input$seqID == "") || input$blankSampleID == "") {
        is_valid_input <<- FALSE
        showModal(modalDialog(
          title = "Missing Inputs",
          "Please ensure that all text inputs have been filled out.",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
        # Reset the input fields after error
        updateTextInput(session, "helixID", value = "RNA")
        updateTextInput(session, "seqID", value = "")
      }


      # Check if the helixID is RNA or DNA, and validate seqID accordingly
      if (input$helixID == "RNA") {
        if (!rna_letters_only(input$seqID)) {
          is_valid_input <<- FALSE
          showModal(modalDialog(
            title = "Invalid RNA Sequence",
            "Please ensure the sequence contains only valid RNA nucleotides (A, U, G, C).",
            footer = modalButton("Understood"),
            easyClose = FALSE,
            fade = TRUE
          ))
          # Reset the seqID input field after error
          updateTextInput(session, "helixID", value = "RNA")
          updateTextInput(session, "seqID", value = "")
        }
      }
      else if (input$helixID == "DNA") {
        if (!dna_letters_only(input$seqID)) {
          is_valid_input <<- FALSE
          showModal(modalDialog(
            title = "Invalid DNA Sequence",
            "Please ensure the sequence contains only valid DNA nucleotides (A, T, G, C).",
            footer = modalButton("Understood"),
            easyClose = FALSE,
            fade = TRUE
          ))
          # Reset the seqID input field after error
          updateTextInput(session, "helixID", value = "DNA")
          updateTextInput(session, "seqID", value = "")
        }
      }
      else {
        # In case helixID is neither RNA nor DNA, show an error
        is_valid_input <<- FALSE
        showModal(modalDialog(
          title = "Invalid helixID",
          "Please select either 'RNA' or 'DNA' for helixID.",
          title = "Invalid helixID",
          "Please select either 'RNA' or 'DNA' for helixID.",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
      }


      # Check for a mismatch between DNA and absorbance wavelength
      if (strsplit(input$helixID, ",")[[1]][1] == "DNA" && !input$wavelengthID == "260") {
        is_valid_input <<- FALSE
        showModal(modalDialog(
          title = "Nucleotide to Absorbance Mis-Pair",
          "Please use a wavelength value of 260 with DNA sequences.",
          title = "Nucleotide to Absorbance Mis-Pair",
          "Please use a wavelength value of 260 with DNA sequences.",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
        # Reset the input fields after error
        updateTextInput(session, "seqID", value = "")
      }

      # Check if a file has been uploaded
      if (is.null(input$inputFileID)) {
        # Reset the input fields after error
        updateTextInput(session, "seqID", value = "")
      }

      # Check if a file has been uploaded
      if (is.null(input$inputFileID)) {
        showModal(modalDialog(
          title = "No File",
          "Please include a file upload",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
      }
    }

    # Check specifically for an empty sequence
    if (input$seqID == "") {
      is_valid_input <<- FALSE
      handleError("Missing Sequence", "Enter a sequence before proceeding. The program will reset in 5 seconds.")
      return()  # Stop further execution
    }

    # Check for invalid input when 'No Blanks' is unchecked
    if (!input$noBlanksID) {  # User hasn't checked "No Blanks"
      if (!has_blanks) {  # But there are blanks in the dataset
        is_valid_input <<- FALSE
        handleError("Blanks Found", "Please check the 'No Blanks' option. The program will reset in 5 seconds.")
        return()  # Stop further execution
      }
    }

    # Ensure all required text inputs are filled
    if ((input$helixID == "" && input$seqID == "") || input$blankSampleID == "") {
      is_valid_input <<- FALSE
      handleError("Missing Inputs", "Fill out all text inputs. The program will reset in 5 seconds.")
      return()  # Stop further execution
    }

    # DNA-specific wavelength check
    if (strsplit(input$helixID, ",")[[1]][1] == "DNA" && input$wavelengthID != "260") {
      is_valid_input <<- FALSE
      handleError("Nucleotide to Absorbance Mis-Pair", "Use wavelength 260 for DNA sequences. The program will reset in 5 seconds.")
      return()  # Stop further execution
    }

    if (is.null(input$wavelengthID) || input$wavelengthID < 200 || input$wavelengthID > 280) {
      is_valid_input <<- FALSE
      handleError("Invalid Wavelength", "Wavelength must be between 200 and 280 nm. The program will reset in 5 seconds.")
      return()
    }

      # If there are no errors in the inputs, proceed with file upload and processing
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
