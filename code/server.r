# server.R handles input validation and analysis.
# It initiates processing and dynamically creates information displayed on analysis graphs.

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
      renderVantHoffPlot()
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
          renderVantHoffPlot()
        } else if (molStateVal == "Monomolecular.2State"){
          hideTab("navbarPageID", "vantHoffPlotTab")
        }
      }
    }
  )

  # Disable remaining widgets on "Upload" page when all datasets have been uploaded
  observeEvent(
    eventExpr = c(datasetsUploadedID(), temperatureUpdatedID),
    handlerExpr = {
      if (datasetsUploadedID() == TRUE) {
        disable("blankSampleID")
        disable("inputFileID")
        disable("datasetsUploadedID")
        disable("noBlanksID")
        disable("uploadData")
      }
    }
  )


  # Handle the situation in which the user toggles the "No Blanks" checkbox
  observe(
    if (input$noBlanksID == TRUE) {
      updateTextInput(session, "blankSampleID", value = "none")
      disable("blankSampleID")
    } else if (input$noBlanksID == FALSE) {
      updateTextInput(session, "blankSampleID", value = 1)
      enable("blankSampleID")
    }
  )

  # Update the example information in the nucleic acid/ extinction coefficient text box depending on user choice
  observe(
    if (input$extinctConDecisionID == "Nucleic acid sequence(s)") {
      updateTextInput(session, "helixID", placeholder = "E.g: RNA", label = "Specify nucelic acid type")
      updateTextInput(session, "seqID", placeholder = "E.g: CGAAAGGU,ACCUUUCG", label = "Specify sequences")
      enable("helixID")
    } else if (input$extinctConDecisionID == "Custom molar extinction coefficients") {
      updateTextInput(session, "seqID", placeholder = "E.g: Custom, 10000, 20000", label = "Specify coefficients")
      updateTextInput(session, "helixID", placeholder = "Disabled")
      disable("helixID")
    }
  )

  # Only activate the checkbox for weighted tm if method 2 and nls are selected
  observe(
    if (input$Tm_methodID == "nls" && ("Method 2" %in% input$methodsID) == TRUE) {
      enable("weightedTmID")
    } else {
      disable("weightedTmID")
    }
  )

  # Show the uploaded datasets separately on the uploads page
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
          caption = paste0("Table", " ", toString(numUploads), ".", " ", "Dataset", " ", toString(numUploads), ".")
        )
      })
    }
    }
  )

  # Disable "Van't Hoff" tab when method 2 is unselected
  observeEvent(
    eventExpr = c(datasetsUploadedID(), temperatureUpdatedID()),
    handlerExpr = {
      if (chosenMethods[2] == FALSE) {
        disable(selector = '.navbar-nav a[data-value="Vant Hoff Plot"')
      } else if (chosenMethods[2] == TRUE) {
        enable(selector = '.navbar-nav a[data-value="Vant Hoff Plot"')
      }
    }
  )

  # Disable "Analysis" and "Results tabs until all files have successfully been uploaded
  observeEvent(
    eventExpr = c(datasetsUploadedID(), temperatureUpdatedID()),
    handlerExpr = {
      if (datasetsUploadedID() == FALSE) {
        disable(selector = '.navbar-nav a[data-value="Analysis"')
        disable(selector = '.navbar-nav a[data-value="Results"')
      } else {
        logInfo("PROCESSING COMPLETE")
        enable(selector = '.navbar-nav a[data-value="Analysis"')
        enable(selector = '.navbar-nav a[data-value="Results"')
      }
    }
  )

  # Dynamically create n tabs (n = number of samples in master data frame) for
  # the "Graphs" page under the "Analysis" navbarmenu.
  observeEvent(
    eventExpr = datasetsUploadedID(),
    handlerExpr = {
      req(is_valid_input)
      start <<- 1
      if (datasetsUploadedID() == TRUE) {
        lapply(
          start:numSamples,
          function(i) {
            if (i != blankInt) {
              tabName <- paste("Sample", i, sep = " ")
              appendTab(
                inputId = "tabs",
                tab = tabPanel(
                  tabName,
                  fluidPage(
                    sidebarLayout(
                      sidebarPanel(
                        h4("Options:"),
                        checkboxInput(inputId = paste0("bestFit", i), label = "Show best fit line"),
                        checkboxInput(inputId = paste0("firstDerivative", i), label = "Show derivative"),
                      ),
                      mainPanel(
                        conditionalPanel(
                          condition = "output.plotBoth1 == null",
                          h3("Loading..."),
                          tags$script(
                            "$(document).ready(function() {
                              setTimeout(function() {
                                $('h3:contains(\"Loading...\")').remove();
                              }, 1500);
                            });"
                          )
                        ),
                        plotlyOutput(paste0("plotBoth", i)),
                        # plotlyOutput(paste0("plotBoth", i)),
                      )
                    )
                  )
                )
              )
            }
          }
        )
        start <<- numSamples + 1
      }
    }
  )

  observeEvent(
    eventExpr = input$seqHelp,
    handlerExpr = {
      showModal(modalDialog(
        title = "Help for Specify Sequences",
        "Please enter the nucleotide sequence in the correct format. For DNA sequences, 
         use only A, T, C, and G. For RNA sequences, use only A, U, C, and G. Ensure the 
         sequence is free from spaces, special characters, or numbers.",
        footer = modalButton("Understood"),
        easyClose = FALSE,
        fade = TRUE
      ))
    }
  )

  observeEvent(
    eventExpr = input$tmHelp,
    handlerExpr = {
      showModal(modalDialog(
        title = "Help for TM Methods",
        "placeholder text for tm methods help",
        footer = modalButton("Understood"),
        easyClose = FALSE,
        fade = TRUE
      ))
    }
  )
  # Dynamically create the analysis plot for each of the n sample tabs
  observeEvent(
    eventExpr = datasetsUploadedID(),
    handlerExpr = {
      req(is_valid_input)
      if (datasetsUploadedID() == TRUE) {
        # Initialize variables for accessing best fit and derivative information
        bestFitXData <<- vector("list", numSamples)
        bestFitYData <<- vector("list", numSamples)
        derivativeXData <<- vector("list", numSamples)
        derivativeYData <<- vector("list", numSamples)
        xRange <<- vector("list", numSamples)

        # Create plots
        for (i in 1:numSamples) {
          if (i != blankInt) {
            xRange[[i]][1] <<- suppressWarnings(round(min(bestFitXData[[i]])))
            xRange[[i]][2] <<- suppressWarnings(round(max(bestFitXData[[i]])))
            local({
              myI <- i

              output[[paste0("plotBoth", myI)]] <- renderPlotly({
                analysisPlot <- myConnecter$constructAllPlots(myI)
                if (input[[paste0("bestFit", myI)]] == TRUE) {
                  analysisPlot <- analysisPlot %>% add_lines(x = bestFitXData[[myI]], y = bestFitYData[[myI]], color = "red")
                }
                if (input[[paste0("firstDerivative", myI)]] == TRUE) {
                  analysisPlot <- analysisPlot %>% add_trace(x = derivativeXData[[myI]], y = derivativeYData[[myI]], marker = list(color = "green"))
                }

                analysisPlot
              })
              observeEvent(event_data(source = paste0("plotBoth", myI), event = "plotly_relayout", priority = c("event")), {
                xRange[[myI]] <<- event_data(source = paste0("plotBoth", myI), event = "plotly_relayout", priority = c("event"))$xaxis.range[1:2]
                output[[paste0("xrange", myI)]] <- renderText({
                  paste0(" x-range: [", round(xRange[[myI]][1], 2), ", ", round(xRange[[myI]][2], 2), "]")
                })
              })
            })
          }
        }
        logInfo("ANALYSIS PLOTS RENDERED ")
      }
    }
  )


  # Create Van't Hoff plot for the "Van't Hoff Plot" tab under the "Results" navbar menu.
  renderVantHoffPlot <- function() {
    output$vantPlot <- renderPlot({
      if (chosenMethods[2] == TRUE) {
        logInfo("VAN'T HOFF RENDERED")
        # Store the points that are kept vs excluded
        keep <- vantData[vals$keeprows, , drop = FALSE]
        exclude <- vantData[!vals$keeprows, , drop = FALSE]
        # Check to see if all brush points are removed

        if (nrow(keep) == 0) {
          vals$keeprows <- rep(TRUE, nrow(vantData))
        }
        # Calculate the R value
        rValue <- format(sqrt(summary(lm(invT ~ lnCt, keep))$r.squared), digits = 3)

        # Create vant plot, including R value
        vantGgPlot <<- ggplot(keep, aes(x = lnCt, y = invT)) +
          geom_point() +
          geom_smooth(formula = y ~ x, method = lm, fullrange = TRUE, color = "black", se = F, linewidth = .5, linetype = "dashed") +
          geom_point(data = exclude, shape = 21, fill = NA, color = "black", alpha = 0.25) +
          labs(y = "Inverse Temperature(K)", x = "ln(Concentration(M))", title = "van't Hoff") +
          annotate("text", x = Inf, y = Inf, color = "#333333", label = paste("r = ", toString(rValue)), size = 7, vjust = 1, hjust = 1) +
          theme(plot.title = element_text(hjust = 0.5))

        # removeUI(selector = "#vantLoading")
        vantGgPlot
      }
    })
  }

  


  # Remove points from Van't Hoff plot that are clicked
  observeEvent(
    eventExpr = input$vantClick,
    handlerExpr = {
      if (chosenMethods[2] == TRUE) {
        res <- nearPoints(vantData, input$vantClick, allRows = TRUE)
        vals$keeprows <- xor(vals$keeprows, res$selected_)
      }
    }
  )

  # Remove brushed points from Van't Hoff when the "Brushed" button is clicked.
  observeEvent(
    eventExpr = input$removeBrushedID,
    handlerExpr = {
      if (chosenMethods[2] == TRUE) {
        res <- brushedPoints(vantData, input$vantBrush, allRows = TRUE)
        vals$keeprows <- xor(vals$keeprows, res$selected_)
      }
    }
  )

  # Reset the Van't Hoff plot when the "Reset" button is clicked.
  observeEvent(
    eventExpr = input$resetVantID,
    handlerExpr = {
      if (chosenMethods[2] == TRUE) {
        vals$keeprows <- rep(TRUE, nrow(vantData))
      }
    }
  )

  # Function for dynamically creating the delete button for each row on the individual fits table
  shinyInput <- function(FUN, len, id, ...) {
    inputs <- character(len)
    for (i in seq_len(len)) {
      inputs[i] <- as.character(FUN(paste0(id, i), ...))
    }
    inputs
  }

  # Calls function to create delete buttons and add IDs for each row in the individual fits table
  getListUnder <- reactive({
    req(is_valid_input)
    if (datasetsUploadedID() == TRUE) {
      individualFitData$Delete <- shinyInput(actionButton, nrow(individualFitData), "delete_",
        label = "Remove",
        style = "color: red;background-color: white",
        onclick = paste0('Shiny.onInputChange( \"delete_button\" , this.id, {priority: \"event\"})')
      )

      individualFitData$ID <- seq.int(nrow(individualFitData))
      return(individualFitData)
    }
  })

  # Assign the reactive data frame for the individual fits table to a reactive value
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

  # Navigate back to the "File" tab when "Back to Home" button is pressed.
  observeEvent(input$backToHome, {
    updateNavbarPage(session, "navbarPageID", selected = "File")
  })

  # Render all parts of the results table.
  output$individualFitsTable <- DT::renderDataTable({
    table <- valuesT$individualFitData %>%
      DT::datatable(
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

  # Save the Van't Hoff Plot in the chosen format
  output$downloadVantID <- downloadHandler(
    filename = function() {
      # Check if the user has provided a filename; if not, use a default
      if (input$saveNameVantID == "") {
        return(paste("VantHoffPlot", ".", input$vantDownloadFormatID, sep = ""))
      } else {
        return(paste(input$saveNameVantID, ".", input$vantDownloadFormatID, sep = ""))
      }
    },
    content = function(file) {
      ggsave(filename = file, plot = vantGgPlot, width = 18, height = 10)
    }
  )

  output$downloadTableID <- downloadHandler(
    filename = function() {
      # Check if the user has provided a filename; if not, use a default
      if (input$saveNameTableID == "") {
        return(paste("ResultsTable", ".", input$tableFileFormatID, sep = ""))
      } else {
        return(paste(input$saveNameTableID, ".", input$tableFileFormatID, sep = ""))
      }
    },
    content = function(file2) {
      # Default to "All of the Above" if no checkboxes are selected
      tableParts <- if (is.null(input$tableDownloadsPartsID) || length(input$tableDownloadsPartsID) == 0) {
        c("All of the Above")
      } else {
        input$tableDownloadsPartsID
      }

      selectedParts <- list()
      if ("Individual Fits" %in% tableParts || "All of the Above" %in% tableParts) {
        selectedParts$IndividualFits <- valuesT$individualFitData %>% select(-c(Delete, ID))
      }
      if ("Method Summaries" %in% tableParts || "All of the Above" %in% tableParts) {
        selectedParts$MethodsSummaries <- summaryDataTable
      }
      if ("Percent Error" %in% tableParts || "All of the Above" %in% tableParts) {
        selectedParts$PercentError <- errorDataTable
      }

      # Write the selected parts to the file
      if (input$tableFileFormatID == "csv") {
        write.csv(selectedParts, file = file2)
      } else {
        write.xlsx(selectedParts, file = file2)
      }
    }
  )

  # General Information Button
  observeEvent(input$btn_general_info, {
    shinyjs::hide("upload_data_content")
    shinyjs::hide("analysis_graphs_content")
    shinyjs::hide("results_table_content")
    shinyjs::hide("exit_content")
    shinyjs::toggle("general_info_content")
  })

  # How to Upload Data Button
  observeEvent(input$btn_upload_data, {
    shinyjs::hide("general_info_content")
    shinyjs::hide("analysis_graphs_content")
    shinyjs::hide("results_table_content")
    shinyjs::hide("exit_content")
    shinyjs::toggle("upload_data_content")
  })

  # Analysis Graphs Button
  observeEvent(input$btn_analysis_graphs, {
    shinyjs::hide("general_info_content")
    shinyjs::hide("upload_data_content")
    shinyjs::hide("results_table_content")
    shinyjs::hide("exit_content")
    shinyjs::toggle("analysis_graphs_content")
  })

  # Results Table Button
  observeEvent(input$btn_results_table, {
    shinyjs::hide("general_info_content")
    shinyjs::hide("upload_data_content")
    shinyjs::hide("analysis_graphs_content")
    shinyjs::hide("exit_content")
    shinyjs::toggle("results_table_content")
  })

  # Exit Instructions Button
  observeEvent(input$btn_exit, {
    shinyjs::hide("general_info_content")
    shinyjs::hide("upload_data_content")
    shinyjs::hide("analysis_graphs_content")
    shinyjs::hide("results_table_content")
    shinyjs::toggle("exit_content")
  })
}
