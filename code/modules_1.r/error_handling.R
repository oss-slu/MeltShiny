validate_inputs <- function(input, session) {
  logInfo("CHECKING PROGRAM INPUTS")
  is_valid_input <<- TRUE

  showErrorModal <- function(title, message) {
    showModal(modalDialog(
      title = title,
      message,
      footer = modalButton("OK"),
      easyClose = TRUE
    ))
    
    # Delay session reset until after modal closes
    observeEvent(input$modal_closed, {
      session$reload()
    })
  }

  # Check if a file is uploaded
  if (is.null(input$inputFileID)) {
    is_valid_input <<- FALSE
    showErrorModal("No File Uploaded", "Please upload a file before proceeding.")
    return()
  }

  # Ensure file is a CSV
  ext <- tools::file_ext(input$inputFileID$datapath)
  if (tolower(ext) != "csv") {
    is_valid_input <<- FALSE
    showErrorModal("File Type Error", "The uploaded file is not a .csv file.")
    return()
  }

  # Try reading the CSV file
  df <- tryCatch({
    read.csv(input$inputFileID$datapath, stringsAsFactors = FALSE)
  }, error = function(e) {
    is_valid_input <<- FALSE
    showErrorModal("File Read Error", "Error reading the CSV file.")
    return()
  })

  if (is.null(df)) return()

  required_columns <- c("Sample", "Pathlength", "Temperature", "Absorbance")

  # Ensure the file has exactly 4 columns
  if (ncol(df) != 4) {
    is_valid_input <<- FALSE
    showErrorModal("Column Error", "The CSV file must have exactly 4 columns.")
    return()
  }

  if (!identical(colnames(df), required_columns)) {
    is_valid_input <<- FALSE
    showErrorModal("Column Name Error", "The columns must be named in this order: Sample, Pathlength, Temperature, Absorbance")
    return()
  }

  # Ensure the file has no missing values
  if (anyNA(df)) {
    is_valid_input <<- FALSE
    showErrorModal("Missing Data Error", "The file contains missing values.")
    return()
  }

  # Check for blanks in the dataset
  dataset <- read.csv(input$inputFileID$datapath, na.strings = c("NA", ""))
  has_blanks <- any(tolower(names(dataset)) == "blanks")

  if (input$noBlanksID && has_blanks) {
    is_valid_input <<- FALSE
    showErrorModal("Blanks Found", "Remove blanks or uncheck the 'No Blanks' option.")
    return()
  }

  if ((input$helixID == "" && input$seqID == "") || input$blankSampleID == "") {
    is_valid_input <<- FALSE
    showErrorModal("Missing Inputs", "Please ensure that all text inputs have been filled out.")
    updateTextInput(session, "helixID", value = "RNA")
    updateTextInput(session, "seqID", value = "")
    return()
  }
    
  # Check the nucleotide sequence to check if it belongs to DNA
  dna_letters_only <- function(x) {
    grepl("^[ATGC]+$", x, ignore.case = TRUE)
  }

  # Check the nucleotide sequence to check if it belongs to RNA
  rna_letters_only <- function(x) {
    grepl("^[AUGC]+$", x, ignore.case = TRUE)
  }

  # Sequence validation depending on molecular state
  molecular_state <- input$molecularStateID
  seq_input <- gsub(" ", "", input$seqID)  # Remove spaces
  sequences <- unlist(strsplit(seq_input, ","))

  if (molecular_state == "Heteroduplex") {
    if (length(sequences) != 2) {
      is_valid_input <<- FALSE
      showErrorModal("Sequence Input Error", "Please provide exactly two sequences separated by a comma for Heteroduplex.")
      updateTextInput(session, "seqID", value = "")
      return()
    }
    for (seq in sequences) {
      if (input$helixID == "RNA" && !rna_letters_only(seq)) {
        is_valid_input <<- FALSE
        showErrorModal("Invalid RNA Sequence", "Each sequence must contain only valid RNA nucleotides (A, U, G, C).")
        updateTextInput(session, "seqID", value = "")
        return()
      }
      if (input$helixID == "DNA" && !dna_letters_only(seq)) {
        is_valid_input <<- FALSE
        showErrorModal("Invalid DNA Sequence", "Each sequence must contain only valid DNA nucleotides (A, T, G, C).")
        updateTextInput(session, "seqID", value = "")
        return()
      }
    }
  } else {
    if (length(sequences) != 1) {
      is_valid_input <<- FALSE
      showErrorModal("Sequence Input Error", "Only a single sequence should be provided for Homoduplex or Monomolecular.")
      updateTextInput(session, "seqID", value = "")
      return()
    }
    if (input$helixID == "RNA" && !rna_letters_only(sequences[1])) {
      is_valid_input <<- FALSE
      showErrorModal("Invalid RNA Sequence", "Ensure the sequence contains only valid RNA nucleotides (A, U, G, C).")
      updateTextInput(session, "seqID", value = "")
      return()
    }
    if (input$helixID == "DNA" && !dna_letters_only(sequences[1])) {
      is_valid_input <<- FALSE
      showErrorModal("Invalid DNA Sequence", "Ensure the sequence contains only valid DNA nucleotides (A, T, G, C).")
      updateTextInput(session, "seqID", value = "")
      return()
    }
  }

  # DNA-specific wavelength check
  if (strsplit(input$helixID, ",")[[1]][1] == "DNA" && input$wavelengthID != "260") {
    is_valid_input <<- FALSE
    showErrorModal("Nucleotide to Absorbance Mis-Pair", "Use wavelength 260 for DNA sequences.")
    return()
  }

  # Ensure wavelength is within a valid range
  if (is.null(input$wavelengthID) || input$wavelengthID < 200 || input$wavelengthID > 280) {
    is_valid_input <<- FALSE
    showErrorModal("Invalid Wavelength", "Wavelength must be between 200 and 280 nm.")
    return()
  }
}
