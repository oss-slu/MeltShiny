# server.R handles input validation and analysis. 
# It initiates processing and dynamically creates information displayed on analysis graphs.

server <- function(input, output, session) {

  # Declare initial value for data upload button check
  is_valid_input <- FALSE

  # Prevent manual input to temperatureID button
  disable("temperatureID")
  disable("submit")

  # Declaring datasetsUploadedID as reactive for upload data button click
  datasetsUploadedID <- reactiveVal(FALSE)

  # Declaring temperatureUpdatedID as reactive for manual changes to the temperature
  temperatureUpdatedID <- reactiveVal(FALSE)

  observeEvent(input$uploadData, {
    datasetsUploadedID(TRUE)  # Set the reactive value to TRUE on upload data button click
    shinyjs::show("resetData")
  })

  observeEvent(input$resetData, {
    session$reload()
  })

  # If temperature is manually edited, update concTVal
  observeEvent(input$submit, {
    if (input$temperatureID != "") {
      concTVal <<- as.numeric(input$temperatureID)  # Set concTVal to new temperature
      
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
    all(!grepl("[^A, ^G, ^C, ^T]", x))
  }

  # Check the nucleotide sequence to check if it belongs to RNA
  rna_letters_only <- function(x) {
    all(!grepl("[^A, ^G, ^C, ^U]", x))
  }

  # Handle the inputs and uploaded datasets
  observeEvent(
    eventExpr = input$uploadData,
    handlerExpr = {
      logInfo("CHECKING PROGRAM INPUTS")
      # Error checking
      if (input$noBlanksID == FALSE) {
        if (can_convert_to_int(input$blankSampleID) == FALSE) {
          is_valid_input <<- FALSE
          showModal(modalDialog(
            title = "Not a number",
            "Please input an integer in the input box for blanks.",
            footer = modalButton("Understood"),
            easyClose = FALSE,
            fade = TRUE
          ))
        }
      }
      if ((input$helixID == ""&& input$seqID=="") || input$blankSampleID == "") {
        is_valid_input <<- FALSE
        showModal(modalDialog(
          title = "Missing Inputs",
          "Please ensure that all text inputs have been filled out.",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
      } else if (strsplit(input$helixID, ",")[[1]][1] == "DNA" && !input$wavelengthID == "260") {
        is_valid_input <<- FALSE
        showModal(modalDialog(
          title = "Nucleotide to Absorbance Mis-Pair",
          "Please use a wavelength value of 260 with DNA sequences.",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
      } else if (strsplit(input$helixID, ",")[[1]][1] == "RNA" && !(input$molecularStateID == "Monomolecular") &&
        ((rna_letters_only(gsub(" ", "", (strsplit(input$helixID, ",")[[1]][2]))) == FALSE) ||
          (rna_letters_only(gsub(" ", "", (strsplit(input$helixID, ",")[[1]][3]))) == FALSE))) {
        is_valid_input <<- FALSE
        showModal(modalDialog(
          title = "Not a RNA Nucleotide",
          "Please use nucleotide U with RNA inputs",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
      } else if (strsplit(input$helixID, ",")[[1]][1] == "DNA" && !(input$molecularStateID == "Monomolecular") &&
        ((dna_letters_only(gsub(" ", "", (strsplit(input$helixID, ",")[[1]][2]))) == FALSE) ||
          (dna_letters_only(gsub(" ", "", (strsplit(input$helixID, ",")[[1]][3]))) == FALSE))) {
        is_valid_input <<- FALSE
        showModal(modalDialog(
          title = "Not a DNA Nucleotide",
          "Please use the nucleotide T with DNA inputs.",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
      } else if (is.null(input$inputFileID)){
        showModal(modalDialog(
          title = "No File",
          "Please include a file upload",
          footer = modalButton("Understood"),
          easyClose = FALSE,
          fade = TRUE
        ))
      }

      # If there are no errors in the inputs, proceed with file upload and processing
      else {
        logInfo("VALID INPUT")

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
        helix <<- trimws(strsplit(gsub(" ", "", paste(input$helixID,',',input$seqID)), ",")[[1]], which = "both")

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
        vantData <<- myConnecter$gatherVantData()
        individualFitData <<- myConnecter$indFitTableData()

        # Variable that handles the points on the Van't Hoff plot for removal
        if (chosenMethods[2] == TRUE) {
          vals <<- reactiveValues(keeprows = rep(TRUE, nrow(vantData)))
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
      updateTextInput(session, "helixID", placeholder = "E.g: RNA",label = "Specify nucelic acid type")
      updateTextInput(session, "seqID", placeholder = "E.g: CGAAAGGU,ACCUUUCG",label="Specify sequences")
      enable("helixID")
    } else if (input$extinctConDecisionID == "Custom molar extinction coefficients") {
      updateTextInput(session, "seqID", placeholder = "E.g: Custom, 10000, 20000",label="Specify coefficients")
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
      logInfo("DISPLAYING UPLOADED DATASET")
      if(is_valid_input) {
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
    is_valid_input <<- FALSE
    }
  )

  # Disable "Van't Hoff" tab when method 2 is unselected
  observeEvent(
    eventExpr = c(datasetsUploadedID(), temperatureUpdatedID()),
    handlerExpr = {
      if (chosenMethods[2] == FALSE) {
        disable(selector = '.navbar-nav a[data-value="Vant Hoff Plot"')
      } else if (chosenMethods[2] == FALSE) {
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
        logInfo('PROCESSING COMPLETE')
        enable(selector = '.navbar-nav a[data-value="Analysis"')
        enable(selector = '.navbar-nav a[data-value="Results"')
      }
    }
  )

# Check if the datasetsUploadedID() returns TRUE correctly.
# Ensure that numSamples and start are correctly initialized and have valid values.
# debug: Print numSamples and can verify their values.
cat("Datasets uploaded. NumSamples:", numSamples, "Start:", start, "\n")

  # Dynamically create n tabs (n = number of samples in master data frame) for
  # the "Graphs" page under the "Analysis" navbarmenu.
  observeEvent(
    eventExpr = datasetsUploadedID(),
    handlerExpr = {
      start <<- 1
      if (datasetsUploadedID() == TRUE) {
        lapply(
          start:numSamples,
          function(i) {
            # debug: Print the current sample being processed
            cat("Processing tab for sample:", i, "\n")

            # Ensure the loop skips blankInt correctly
            if (i != blankInt) {
              # Verify derivativeXData and derivativeYData are initialized
              if (is.null(derivativeXData[[i]]) || is.null(derivativeYData[[i]])) {
                warning(paste0("Derivative data not initialized for sample ", i))
              }

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
                        conditionalPanel(
                          condition = paste0("input.firstDerivative", i, " === true"),
                          plotlyOutput(paste0("plotDerivative", i))
                        )
                      )
                    )
                  )
                )
              )
              # Add observer for rendering the derivative plot
              observeEvent(input[[paste0("firstDerivative", i)]], {
                req(input[[paste0("firstDerivative", i)]])  # Ensure the input exists

                output[[paste0("plotDerivative", i)]] <- renderPlotly({
                  # Ensure data exists before rendering
                  if (is.null(derivativeXData[[i]]) || is.null(derivativeYData[[i]])) {
                    stop(paste0("Derivative data not found for sample ", i))
                  }
                  
                  # Debug: Log derivative data for this sample
                  cat("Rendering derivative plot for sample:", i, "\n")
                  print(derivativeXData[[i]])
                  print(derivativeYData[[i]])

                  # Generate the derivative plot
                  plot_ly(
                    x = derivativeXData[[i]],
                    y = derivativeYData[[i]],
                    type = "scatter",
                    mode = "lines",
                    name = "Derivative"
                  )
                })
              }, ignoreNULL = FALSE)  # Ensure observer is triggered even if initially NULL
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
          "placeholder text for input sequences help",
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

      if(nrow(keep) == 0){
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
  
  # Initially render the Vant Hoff Plot
  renderVantHoffPlot()


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
      logInfo('RESULTS TABLE RENDERED')
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
      paste(input$saveNameVantID, ".", input$vantDownloadFormatID, sep = "")
    },
    content = function(file) {
      ggsave(filename = file, plot = vantGgPlot, width = 18, height = 10)
    }
  )

# Save the results table in the chosen file format
output$downloadTableID <- downloadHandler(
  filename = function() {
    paste(input$saveNameTableID, ".", input$tableFileFormatID, sep = "")
  },
  content = function(file2) {
    selectedParts <- list()
    
    if ("Individual Fits" %in% input$tableDownloadsPartsID) {
      individualFitData <- valuesT$individualFitData %>% select(-c(Delete, ID))
      selectedParts$IndividualFits <- individualFitData
    }
    if ("Method Summaries" %in% input$tableDownloadsPartsID) {
      selectedParts$MethodsSummaries <- summaryDataTable
    }
    if ("Percent Error" %in% input$tableDownloadsPartsID) {
      selectedParts$PercentError <- errorDataTable
    }
    if ("All of the Above" %in% input$tableDownloadsPartsID) {
      selectedParts$IndividualFits <- valuesT$individualFitData %>% select(-c(Delete, ID))
      selectedParts$MethodsSummaries <- summaryDataTable
      selectedParts$PercentError <- errorDataTable
    }
    
    # Choose the file format for saving
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