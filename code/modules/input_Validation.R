# modules/input_validation.R

# Helper functions for input checks
can_convert_to_int <- function(x) {
  all(grepl("^(?=.)([+-]?([0-9]*)?)$", x, perl = TRUE))
}

dna_letters_only <- function(x) {
  grepl("^[ATGC]+$", x, ignore.case = TRUE)
}

rna_letters_only <- function(x) {
  grepl("^[AUGC]+$", x, ignore.case = TRUE)
}

# Observer for file upload and input validation
observeFileUpload <- function(input, output, session) {
  observeEvent(input$uploadData, {
    logInfo("CHECKING PROGRAM INPUTS")
    is_valid_input <- TRUE
    
    # Check if a file is uploaded
    if (is.null(input$inputFileID)) {
      is_valid_input <- FALSE
      handleError(session, "No File Uploaded", 
                  "Please upload a file before proceeding. The program will reset in 5 seconds.")
      return()
    }
    
    # Ensure file is a CSV
    ext <- tools::file_ext(input$inputFileID$datapath)
    if (tolower(ext) != "csv") {
      is_valid_input <- FALSE
      handleError(session, "File Type Error", 
                  "The uploaded file is not a .csv file. The program will reset in 5 seconds.")
      return()
    }
    
    # Try reading the CSV file
    df <- tryCatch({
      read.csv(input$inputFileID$datapath, stringsAsFactors = FALSE)
    }, error = function(e) {
      is_valid_input <- FALSE
      handleError(session, "File Read Error", 
                  "Error reading the CSV file. The program will reset in 5 seconds.")
      return(NULL)
    })
    if (is.null(df)) return()
    
    # Validate the CSV structure
    required_columns <- c("Sample", "Pathlength", "Temperature", "Absorbance")
    if (ncol(df) != 4) {
      is_valid_input <- FALSE
      handleError(session, "Column Error", 
                  "The CSV file must have exactly 4 columns. The program will reset in 5 seconds.")
      return()
    }
    if (!identical(colnames(df), required_columns)) {
      is_valid_input <- FALSE
      handleError(session, "Column Name Error", 
                  "The columns must be named in this order: Sample, Pathlength, Temperature, Absorbance.")
      return()
    }
    if (anyNA(df)) {
      is_valid_input <- FALSE
      handleError(session, "Missing Data Error", 
                  "The file contains missing values. The program will reset in 5 seconds.")
      return()
    }
    
    # (Additional validations for blanks, sequence inputs, and wavelength checks would go here.)
    # For instance, check if the helix and seq inputs match expected formats.
    
    # Process file if validations pass
    if (is_valid_input) {
      logInfo("VALID INPUT")
      # Update UI element (e.g., show Reset button)
      shinyjs::show("resetData")
      
      # Read and sort the data
      raw_data <- read.csv(input$inputFileID$datapath)
      highest_temp <- max(raw_data$Temperature, na.rm = TRUE)
      updateTextInput(session, "temperatureID", value = highest_temp)
      concTVal <<- as.numeric(highest_temp)
      
      # Disable file inputs that are now “locked in”
      disable("inputFileID")
      disable("noBlanksID")
      disable("uploadData")
      
      # Sort and store the data
      data <- raw_data %>% arrange(Sample)
      masterFrame <<- if (is.null(masterFrame)) data else rbind(masterFrame, data)
      numUploads <<- numUploads + 1
      numSamples <<- numSamples + length(unique(data$Sample))
      
      # (Store additional user inputs as needed, e.g. helix, blank, tmMethod, etc.)
    }
  })
}
