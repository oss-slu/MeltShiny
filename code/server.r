server <- function(input,output, session){
  
  # Create a reactive value which can hold the growing dataset.
  values <- reactiveValues(masterFrame = NULL,
                           numReadings = NULL
                           )
  
  # Function that handles the dataset inputs, as wells as the dataset upload
  upload <- observeEvent(eventExpr = input$inputFileID,
                         handlerExpr = {
                           
                           # Only proceed with the rest of function if a file has been uploaded
                           req(input$inputFileID)
                        
                           # Store the dataset user inputs in global variables
                           pathlengthInputs <- c(unlist(strsplit(input$pathlengthID,",")))
                           wavelengthVal <<- as.numeric(input$wavelength)
                           blank <<- as.numeric(input$blankSampleID)
                           helix <<- trimws(strsplit(input$helixID,",")[[1]],which="both")
                           molStateVal <<- input$molecularStateID
                           
                           # Format stored molecular state choice
                           # and re-store it in the same global variable
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
                           values$numReadings <- counter - 1
                           values$masterFrame <- rbind(values$masterFrame, tempFrame)
                           
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
                             keeprows = rep(TRUE, nrow(calculations)))
                           }
                         )
  
  # Output the post-processed data frame, which contains all the appended datasets.
  output$inputTable = DT::renderDataTable({datatable(values$masterFrame, 
                                                class = 'cell-border stripe', 
                                                selection = 'none', 
                                                options = list(searching = FALSE, ordering = FALSE),
                                                caption = 'Table 1. Dataset 1.')})
  
  # Hide "Analysis" and "Results tabs until a file is successfully uploaded
  observeEvent(eventExpr = is.null(values$numReadings),
               handlerExpr = {
                 hideTab(inputId = "navbarPageID",target = "Analysis")
                 hideTab(inputId = "navbarPageID",target = "Results")
                 }
               )
  
  # Dynamically create n tabs (n = number of samples in master data frame) for 
  # the "Graphs" page under the "Analysis" navbarmenu.
  observe({
    req(values$numReadings)
    lapply(start:values$numReadings,
           function(i){
             if (i != blank) {
               data = values$masterFrame[values$masterFrame$Sample == i,]
               plotBoth = paste0("plotBoth",i)
               plotBestFit = paste0("plotBestFit",i)
               plotName = paste0("plot",i)
               plotSlider <- paste0("plotSlider",i)
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
               )}
             }
           )
    start <<- values$numReadings + 1
    showTab(inputId = "navbarPageID",target = "Analysis")
    showTab(inputId = "navbarPageID",target = "Results")
    })
  
  # Dynamically create a plot for each of the n tabs.
  observe({
    req(input$inputFileID)
    for (i in 1:values$numReadings) {
      if (i != blank) {
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
            myConnecter$constructBoth(myI)
            })
          })
        }
      }
    })
  
  # Create Van't Hoff plot for the "Van't Hoff Plot" Tab under the "Results" navbar menu.
  output$vantPlot <- renderPlot({
    keep <- calculations[vals$keeprows, , drop = FALSE]
    exclude <- calculations[!vals$keeprows, , drop = FALSE]
    ggplot(keep, aes(x = invT, y = lnCt )) + geom_point() +
      geom_smooth(method = lm, fullrange = TRUE, color = "black") +
      geom_point(data = exclude, shape = 21, fill = NA, color = "black", alpha = 0.25)
    }, res = 100)
  
  # Remove points from Van't Hoff that are clicked.
  observeEvent(eventExpr = input$vantClick, 
               handlerExpr = {
                 res <- nearPoints(calculations, input$vantClick, allRows = TRUE)
                 vals$keeprows <- xor(vals$keeprows, res$selected_)
                 })
  
  # Remove points that are brushed when the appropriate button is clicked.
  observeEvent(eventExpr = input$removeBrushedID, 
               handlerExpr = {
                 res <- brushedPoints(calculations, input$vantBrush, allRows = TRUE)
                 vals$keeprows <- xor(vals$keeprows, res$selected_)
                 })
  
  # Reset all the Van't Hoff plot when the reset button is clicked.
  observeEvent(eventExpr = input$resetVantID, 
               handlerExpr = {
                 vals$keeprows <- rep(TRUE, nrow(calculations))
                 })
  
  # Function for dynamically creating the delete button on results table 1
  shinyInput <- function(FUN, len, id, ...) {
    inputs <- character(len)
    for (i in seq_len(len)) {
      inputs[i] <- as.character(FUN(paste0(id, i), ...))
    }
    inputs
  }
  
  # Calls function above to create delete buttons and add IDs for each row in data table 1
  getListUnder <- reactive({
    req(input$inputFileID)
    df3 <<- df2
    df3$Delete <- shinyInput(actionButton, nrow(df3),'delete_',label = "Remove",
                            style = "color: red;background-color: white",
                            onclick = paste0('Shiny.onInputChange( \"delete_button\" , this.id, {priority: \"event\"})'))
    
    df3$ID <- seq.int(nrow(df3))
    return(df3)
  })
  
  # Assign the reactive data.frame for data table 1 to a reactive value
  observe({
    req(input$inputFileID)
    valuesT <<- reactiveValues(df3 = NULL)
    valuesT$df3 <- isolate({getListUnder()})
  })
  
  # When delete button is pressed, remove row from data table 1
  observeEvent( input$delete_button, {
    selectedRow <- as.numeric(strsplit(input$delete_button, "_")[[1]][2])
    valuesT$df3 <<- subset(valuesT$df3, ID!=selectedRow)
  })
  
  # When reset button is pressed, reset table 1 to original
  observeEvent(eventExpr = input$resetTable1ID, 
               handlerExpr = {
                 valuesT$df3 <- isolate({getListUnder()})
               })
  
  # Render results table
  output$resulttable = DT::renderDataTable({
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
  output$summarytable <- renderTable({
    data <- myConnecter$summaryData1()
    return(data)
  })
  output$summarytable2 <- renderTable({
    data <- myConnecter$summaryData2()
    return(data)
  })
  output$summarytable3 <- renderTable({
    data <- myConnecter$summaryData3()
    return(data)
  })
  output$error <- renderTable({
    data <- myConnecter$error()
    return(data)
  })
  
  # Save the Van't Hoff Plot as a pdf.
  output$downloadVantID <- downloadHandler(
    filename = function(){
      paste(input$saveVantID, '.pdf', sep = '')
    },
    content = function(file1){
      cairo_pdf(filename = file1, onefile = T,width = 18, 
                height = 10, pointsize = 12, family = "sans", bg = "transparent",
                antialias = "subpixel",fallback_resolution = 300
                )
      caluclations <- myConnecter$gatherVantData()
      InverseTemp <- caluclations$invT
      LnConcentraion <- caluclations$lnCt
      plot(LnConcentraion,InverseTemp)
      dev.off()
    },
    contentType = "application/pdf"
  )
  
  # Save the results table as an excel file, with each component on a seperate sheet.
  output$downloadTableID <- downloadHandler(
    filename = function() {
      paste(input$saveTableID, '.xlsx', sep='')
      },
    content = function(file2) {
      write.xlsx(myConnecter$summaryData1(), file2, sheetName = "table1", append = FALSE)
      write.xlsx(myConnecter$summaryData2(), file2, sheetName = "table2", append = TRUE)
      write.xlsx(myConnecter$summaryData3(), file2, sheetName = "table3", append = TRUE)
      write.xlsx(myConnecter$error(), file2, sheetName = "error", append = TRUE)
      }
    )
  }
