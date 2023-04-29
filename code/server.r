server <- function(input,output, session){
  # Prevent Rplots.pdf from generating
  if(!interactive()) pdf(NULL)
  
  # Create a reactive value which can hold the growing dataset.
  values <<- reactiveValues(masterFrame = NULL,
                           numReadings = NULL
                           )
  
  # Check if the value is an int.
  can_convert_to_int <- function(x) {
    all(grepl('^(?=.)([+-]?([0-9]*)?)$', x, perl = TRUE))  
  }
  
  # Check the nucleotide sequence to check if it belongs to DNA.
  dna_letters_only <- function(x){
    all(!grepl("[^A,^G,^C,^T]",x))
  }
  
  # Check the nucleotide sequence to check if it belongs to RNA.
  rna_letters_only <- function(x){
    all(!grepl("[^A,^G,^C,^U]",x))
  }
  
  # Handle the situation in which the user clicks the "No Blanks" checkbox.
  observeEvent(eventExpr = input$noBlanksID,
               handlerExpr = {
                 if (input$noBlanksID == TRUE){
                   updateTextInput(session,"blankSampleID", value = "none")
                   disable('blankSampleID')
                 }
               })
  
  # Handle the dataset inputs and append additional datasets.
  upload <- observeEvent(eventExpr = input$inputFileID,
                         handlerExpr = {
                           if(input$noBlanksID == FALSE){
                             if(can_convert_to_int(input$blankSampleID) == FALSE){
                               showModal(modalDialog(
                                 title = "Not a number",
                                 "Please input an integer in the blanks box.",
                                 footer = modalButton("Understood"),
                                 easyClose = FALSE,
                                 fade = TRUE
                               ))
                             }
                           }
                           if(input$pathlengthID == "" || input$helixID == "" || input$blankSampleID == ""){
                             showModal(modalDialog(
                               title = "Missing Inputs",
                               "Please ensure that all inputs have been filled out.",
                               footer = modalButton("Understood"),
                               easyClose = FALSE,
                               fade = TRUE
                             ))
                           }
                           else if(strsplit(input$helixID,",")[[1]][1] == "DNA" && !input$wavelengthID == "260"){
                             showModal(modalDialog(
                               title = "Nucleotide to Absorbance Mis-Pair",
                               "Please use a wavelength value of 260 with DNA sequences.",
                               footer = modalButton("Understood"),
                               easyClose = FALSE,
                               fade = TRUE
                               ))
                           }
                           else if(strsplit(input$helixID,",")[[1]][1] == "RNA" && !(input$molecularStateID == "Monomolecular")&& 
                                   ((rna_letters_only(gsub(" ", "",(strsplit(input$helixID,",")[[1]][2]))) == FALSE) || 
                                    (rna_letters_only(gsub(" ", "",(strsplit(input$helixID,",")[[1]][3]))) == FALSE))){
                             showModal(modalDialog(
                               title = "Not a RNA Nucleotide",
                               "Please use nucleotide U with RNA inputs",
                               footer = modalButton("Understood"),
                               easyClose = FALSE,
                               fade = TRUE
                             ))
                           }
                           else if(strsplit(input$helixID,",")[[1]][1] == "DNA" && !(input$molecularStateID == "Monomolecular")&& 
                                   ((dna_letters_only(gsub(" ", "",(strsplit(input$helixID,",")[[1]][2]))) == FALSE) || 
                                    (dna_letters_only(gsub(" ", "",(strsplit(input$helixID,",")[[1]][3]))) == FALSE))){
                             showModal(modalDialog(
                               title = "Not a DNA Nucleotide",
                               "Please use the nucleotide T with DNA inputs.",
                               footer = modalButton("Understood"),
                               easyClose = FALSE,
                               fade = TRUE
                             ))
                           }
                           else{
                             # Store the dataset user inputs in global variables
                             pathlengthInputs <- c(unlist(strsplit(input$pathlengthID,",")))
                             wavelengthVal <<- as.numeric(input$wavelength)
                             if(input$noBlanksID == TRUE){
                               blank <<- "none"
                               blankInt <<- 0
                               }
                             else{
                               blank <<- as.numeric(input$blankSampleID)
                               blankInt <<- blank
                               }
                             helix <<- trimws(strsplit(input$helixID,",")[[1]],which="both")
                             molStateVal <<- input$molecularStateID
                           
                             # Format stored molecular state choice and re-store it in the same global variable.
                             if (molStateVal == "Heteroduplex") {
                               molStateVal <<- "Heteroduplex.2State"
                             } else if (molStateVal == "Homoduplex") {
                               molStateVal <<- "Homoduplex.2State"
                             }else{
                               molStateVal <<- "Monomolecular.2State"
                             }
                           
                             # Disable widgets from inputs page whose values apply to all datasets.
                             disable('helixID')
                             disable('molecularStateID')
                             disable('wavelengthID')
                           
                             # Extract the file and remove any columns/rows with NA's.
                             fileName <- input$inputFileID$datapath
                             cd <- read.csv(file = fileName,header = FALSE)
                             df <- cd %>% select_if(~ !any(is.na(.)))
                           
                             # Create temporary data frame to store data from each uploaded file.
                             # Also process data to fit MeltR's format. 
                             columns <- c("Sample", "Pathlength", "Temperature", "Absorbance")
                             tempFrame <- data.frame(matrix(nrow = 0, ncol = 4))
                             colnames(tempFrame) <- columns
                             readings <- ncol(df)
                           
                             # Append each individual temporary data frame into a larger dataframe
                             p <- 1
                             for (x in 2:readings) {
                               col <- df[x]
                               sample <- rep(c(counter),times = nrow(df[x]))
                               pathlength <- rep(c(as.numeric(pathlengthInputs[p])),times = nrow(df[x]))
                               col <- df[x]
                               t <- data.frame(sample,pathlength,df[1],df[x])
                               names(t) <- names(tempFrame)
                               tempFrame <- rbind(tempFrame, t)
                               p <- p + 1
                               counter <<- counter + 1
                             }
                             dataList <<- append(dataList, list(tempFrame))
                             numFiles <<- numFiles + 1
                             values$numReadings <- counter - 1
                             values$masterFrame <- rbind(values$masterFrame, tempFrame)
                             enable('blankSampleID')
                             updateTextInput(session,"blankSampleID", value = 1)
                             updateCheckboxInput(session,"noBlanksID", value = FALSE)
                             }
                           })
  
  # Once all datasets have been uploaded, the MeltR object can be created
  observeEvent(eventExpr = input$datasetsUploadedID, 
               handlerExpr = {
                 if(input$datasetsUploadedID == TRUE){
                   # Send stored input values to the connecter abstraction class, create 
                   # a connecter object, and store the result of calling one of it's functions.
                   myConnecter <<- connecter(df = values$masterFrame,
                                             NucAcid = helix,
                                             Mmodel = molStateVal,
                                             blank = blank
                                             )
                   myConnecter$constructObject()
                   calculations <<- myConnecter$gatherVantData()
                   df2 <<- myConnecter$fitData()
                   
                   # Reactive variable that handles the points on the Van't Hoff plot.
                   # Necessary for removal of outliers from said plot.
                   vals <<- reactiveValues(
                     keeprows = rep(TRUE, nrow(calculations))
                     )
                   }
                 }
               )
  
  # Disable remaining widgets on "Upload" page when all datasets have been uploaded.
  observeEvent(eventExpr = input$datasetsUploadedID, 
               handlerExpr = {
                 if(input$datasetsUploadedID == TRUE){
                   disable('temperatureID')
                   disable('methodsID')
                   disable('blankSampleID')
                   disable('pathlengthID')
                   disable('inputFileID')
                   disable('datasetsUploadedID')
                   disable('includeBlanksID')
                   disable('blankPairsID')
                   disable('noBlanksID')
                   }
                 })
  
  observeEvent(eventExpr = input$inputFileID,
               handlerExpr = {
                 divID <- toString(numFiles)
                 dtID <- paste0(divID,"DT")
                 insertUI(
                   selector = "#placeholder",
                   ui = tags$div(id = divID,
                                 DT::dataTableOutput(dtID),
                                 hr(style = "border-top: 1px solid #000000;")
                                 )
                   )
                 output[[dtID]] <- DT::renderDataTable({datatable(dataList[[numFiles]], 
                                                                  class = 'cell-border stripe', 
                                                                  selection = 'none', 
                                                                  options = list(searching = FALSE, ordering = FALSE),
                                                                  caption = paste0('Table',toString(numFiles),'.','Dataset',toString(numFiles),'.'))})
               }
  )
  
  # Disable "Analysis" and "Results tabs until all files have successfully been uploaded
  observeEvent(eventExpr = input$datasetsUploadedID,
               handlerExpr = {
                 if(input$datasetsUploadedID == FALSE){
                   disable(selector = '.navbar-nav a[data-value="Analysis"')
                   disable(selector = '.navbar-nav a[data-value="Results"')
                   }
                 }
               )
  
  # Dynamically create n tabs (n = number of samples in master data frame) for 
  # the "Graphs" page under the "Analysis" navbarmenu.
  observeEvent(eventExpr = input$datasetsUploadedID, 
               handlerExpr = {
                 if(input$datasetsUploadedID == TRUE){
                   lapply(start:values$numReadings,
                          function(i){
                            if (i != blankInt) {
                              data = values$masterFrame[values$masterFrame$Sample == i,]
                              plotBoth = paste0("plotBoth",i)
                              plotBestFit = paste0("plotBestFit",i)
                              plotName = paste0("plot",i)
                              plotDerivative = paste0("plotDerivative",i)
                              firstDerivative = paste0("firstDerivative",i)
                              bestFit = paste0("bestFit",i)
                              tabName = paste("Sample",i,sep = " ")
                              appendTab(inputId = "tabs",
                                        tab = tabPanel(tabName,
                                                       fluidPage(
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             h4("Options:"),
                                                             checkboxInput(inputId = bestFit,label = "Best Fit"),
                                                             checkboxInput(inputId = firstDerivative,label = "First Derivative"),
                                                             ),
                                                           mainPanel(
                                                             conditionalPanel(condition = glue("!input.{firstDerivative} && !input.{bestFit}"),
                                                                              plotlyOutput(plotName)
                                                                              ),
                                                             conditionalPanel(condition = glue("input.{firstDerivative} && !input.{bestFit}"),
                                                                              plotlyOutput(plotDerivative)
                                                                              ),
                                                             conditionalPanel(condition = glue("input.{bestFit} && !input.{firstDerivative}"),
                                                                              plotlyOutput(plotBestFit)
                                                                              ),
                                                             conditionalPanel(condition = glue("input.{firstDerivative} && input.{bestFit}"),
                                                                              plotlyOutput(plotBoth)
                                                                              ),
                                                             )
                                                           )
                                                         )
                                                       )
                                        )
                              }
                            }
                         )
                   start <<- values$numReadings + 1
                   enable(selector = '.navbar-nav a[data-value="Analysis"')
                   enable(selector = '.navbar-nav a[data-value="Results"')
                   }
                 }
               )
  
  # Dynamically create the three plots for each of the n sample tabs.
  observeEvent(eventExpr = input$datasetsUploadedID, 
               handlerExpr = {
                 if(input$datasetsUploadedID == TRUE){
                   for (i in 1:values$numReadings) {
                     if (i != blankInt) {
                       local({
                         myI <- i 
                         plotDerivative = paste0("plotDerivative",myI)
                         plotBestFit = paste0("plotBestFit",myI)
                         plotBoth = paste0("plotBoth",myI)
                         plotName = paste0("plot",myI)
                        
                         # Plot containing raw data
                         output[[plotName]] <- renderPlotly({
                           myConnecter$constructRawPlot(myI)
                           })
                        
                         # Plot containing first derivative with raw data
                         output[[plotDerivative]] <- renderPlotly({
                           myConnecter$constructFirstDerivative(myI)
                           })
                        
                         # Plot containing best fit with raw data
                         output[[plotBestFit]] <- renderPlotly({
                           myConnecter$constructBestFit(myI)
                         })
                        
                         # Plot containing best, first derivative, and raw data
                         output[[plotBoth]] <- renderPlotly({
                           myConnecter$constructAllPlots(myI)
                           })
                         })
                       }
                     }
                   }
                 })
  
  # Create Van't Hoff plot for the "Van't Hoff Plot" tab under the "Results" navbar menu.
  output$vantPlot <- renderPlot({
    keep <- calculations[vals$keeprows, , drop = FALSE]
    exclude <- calculations[!vals$keeprows, , drop = FALSE]
    vantGgPlot <<- ggplot(keep, aes(x = invT, y = lnCt )) + geom_point() +
      geom_smooth(formula = y ~ x,method = lm, fullrange = TRUE, color = "black", se=F, linewidth = .5, linetype = "dashed") +
      geom_point(data = exclude, shape = 21, fill = NA, color = "black", alpha = 0.25) +
      labs(y = "ln(Concentration)", x = "Inverse Temperature (°C)", title = "Van't Hoff") +
      theme(plot.title = element_text(hjust = 0.5))
    vantGgPlot
    })
  
  # Remove points from Van't Hoff that are clicked.
  observeEvent(eventExpr = input$vantClick, 
               handlerExpr = {
                 res <- nearPoints(calculations, input$vantClick, allRows = TRUE)
                 vals$keeprows <- xor(vals$keeprows, res$selected_)
                 })
  
  # Remove brushed points from Van't Hoff when the "Brushed" button is clicked.
  observeEvent(eventExpr = input$removeBrushedID, 
               handlerExpr = {
                 res <- brushedPoints(calculations, input$vantBrush, allRows = TRUE)
                 vals$keeprows <- xor(vals$keeprows, res$selected_)
                 })
  
  # Reset the Van't Hoff plot when the "Reset" button is clicked.
  observeEvent(eventExpr = input$resetVantID, 
               handlerExpr = {
                 vals$keeprows <- rep(TRUE, nrow(calculations))
                 })
  
  # Function for dynamically creating the delete button on the individual fits table
  shinyInput <- function(FUN, len, id, ...) {
    inputs <- character(len)
    for (i in seq_len(len)) {
      inputs[i] <- as.character(FUN(paste0(id, i), ...))
    }
    inputs
  }
  
  # Calls function above to create delete buttons and add IDs for each row in the individual fits table
  getListUnder <- reactive({
    if(input$datasetsUploadedID == TRUE){
    
      df3 <<- df2
      df3$Delete <- shinyInput(actionButton, nrow(df3),'delete_',label = "Remove",
                               style = "color: red;background-color: white",
                               onclick = paste0('Shiny.onInputChange( \"delete_button\" , this.id, {priority: \"event\"})'))
    
      df3$ID <- seq.int(nrow(df3))
      return(df3)
      }
  })
  
  # Assign the reactive data frame for the individual fits table to a reactive value
  observeEvent(eventExpr = input$datasetsUploadedID, 
               handlerExpr = {
                 if(input$datasetsUploadedID == TRUE){
                   valuesT <<- reactiveValues(df3 = NULL)
                   valuesT$df3 <- isolate({getListUnder()})
                   }
                 })
  
  # Remove row from individual fits table when its respective "Remove" button is pressed.
  observeEvent( eventExpr = input$delete_button, handlerExpr = {
    selectedRow <- as.numeric(strsplit(input$delete_button, "_")[[1]][2])
    valuesT$df3 <<- subset(valuesT$df3, ID!=selectedRow)
  })
  
  # Reset the individual fits table to original when "Reset" button is pressed.
  observeEvent(eventExpr = input$resetTable1ID == TRUE, 
               handlerExpr = {
                 valuesT$df3 <- isolate({getListUnder()})
               })
  
  # Render all parts of the results table.
  output$individualFitsTable = DT::renderDataTable({
    table <- valuesT$df3 %>%
      DT::datatable(filter = "none", 
                    rownames = F,
                    extensions = 'FixedColumns',
                    class = 'cell-border stripe', 
                    selection = 'none', 
                    options = list(dom = 't',
                                   searching = FALSE, 
                                   ordering = FALSE,
                                   fixedColumns = list(leftColumns = 2),
                                   pageLength = 100,
                                   columnDefs = list(list(targets = c(7), visible = FALSE))),
                    escape = F)
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
  
  # Save the Van't Hoff Plot as a pdf.
  output$downloadVantID <- downloadHandler(
    filename = function(){
      paste(input$saveNameVantID, input$vantDownloadFormatID, sep = '')
    },
    content = function(file){
      ggsave(filename = file, plot = vantGgPlot, width = 18, height = 10)
    }
  )
  
  # Save the results table as an excel file, with each component on a separate sheet.
  output$downloadTableID <- downloadHandler(
    filename = function() {
      paste(input$saveTableID, '.xlsx', sep='')
      },
    content = function(file2) {
      write.xlsx(list(IndividualFits = valuesT$df3 %>% select(-c(Delete, ID)), MethodsSummaries = summaryDataTable, PercentError = errorDataTable),
                 file = file2, append = FALSE)
      }
    )
  }
