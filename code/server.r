server <- function(input,output, session){
  
  # Create a reactive value which can hold the growing dataset.
  values <- reactiveValues(masterFrame = NULL,
                           numReadings = NULL
  )
  #input validation
  continue <- FALSE #used to stop the rest of the program from running if the inputs aren't valid
  #function to check if an input can be converted to an int
  can_convert_to_int <- function(x) {
    all(grepl('^(?=.)([+-]?([0-9]*)?)$', x, perl = TRUE))  
  }
  can_convert_to_numeric <- function(x) {
    all(grepl('^(?=.)([+-]?([0-9]*)(\\.([0-9]+))?)$', x, perl = TRUE))  
  }
  
  
  
  # Function that handles the dataset inputs, as wells as the dataset upload
  upload <- observeEvent(eventExpr = input$inputFileID,
                         handlerExpr = {
                           # Only proceed with the rest of function if a file has been uploaded
                           req(input$inputFileID)
                           if(input$pathlengthID == "" ||input$blankSampleID == "" || input$helixID == ""){
                             showModal(modalDialog(
                               title = "Missing Inputs",
                               "One or more of the input boxes are blank please fill them all in!"
                             ))
                           }
                           else if(can_convert_to_int(input$blankSampleID) == FALSE){
                             showModal(modalDialog(
                               title = "Not a number",
                               "Please input one integer in the blanks box"
                             ))
                             
                           }
                           
                           else if(strsplit(input$helixID,",")[[1]][1] == "DNA" && !input$wavelengthID == "260"){
                             showModal(modalDialog(
                               title = "Not a number",
                               "Please only use wavelength 260 with DNA inputs"
                             ))

                           }
                           else{
                             continue <- TRUE
                             # Store the dataset user inputs in global variables
                             pathlengthInputs <- c(unlist(strsplit(input$pathlengthID,",")))
                             pathlengthInputs <- gsub(" ","",pathlengthInputs) #removes any spaces
                             wavelengthVal <<- as.numeric(input$wavelength)
                             blank <<- as.numeric(input$blankSampleID)
                             helix <<- trimws(strsplit(input$helixID,",")[[1]],which="both")
                             helix <- gsub(" ","",helix)
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
                             
                             # Reactive variable that handles the points on the Van't Hoff plot.
                             # Necessary for removal of outliers from said plot.
                             vals <<- reactiveValues(
                               keeprows = rep(TRUE, nrow(calculations)))
                           }
                         }
  )

    # Output the post-processed data frame, which contains all the appended datasets.
    output$table <- renderTable({return(values$masterFrame)})
    
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
      req(values$numReadings) && continue == TRUE
      lapply(start:values$numReadings,
             function(i){
               if (i != blank) {
                 data = values$masterFrame[values$masterFrame$Sample == i,]
                 n = myConnecter$getFirstDerivativeMax(i)
                 bounds = myConnecter$getSliderBounds(i,n)
                 xmin = round(min(data$Temperature),4)
                 xmax = round(max(data$Temperature),4)
                 plotBoth = paste0("plotBoth",i)
                 plotBestFit = paste0("plotBestFit",i)
                 plotFit = paste0("plotFit",i)
                 plotName = paste0("plot",i)
                 plotSlider <- paste0("plotSlider",i)
                 plotDerivative = paste0("plotDerivative",i)
                 #Check box and tab Panel variables
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
                                                conditionalPanel(condition = glue("{xmin} == {bounds[[1]][1]}"),
                                                                 p("Warning: Lower bound exceeds minimum x-value of data. Positioning lower-end bar as the minimum value of the data")
                                                ),
                                                conditionalPanel(condition = glue("{xmax} == {bounds[[2]][1]}"),
                                                                 p("Warning: Upper bound exceeds maximum x-value of data. 
                                                                 Positioning uupper-end bar as the maximum value of the data",color="Red"))
                                              ),
                                              mainPanel(
                                                conditionalPanel(condition = glue("!input.{firstDerivative} && !input.{bestFit}"),
                                                                 plotOutput(plotName)
                                                ),
                                                conditionalPanel(condition = glue("input.{firstDerivative} && !input.{bestFit}"),
                                                                 plotOutput(plotDerivative)
                                                ),
                                                conditionalPanel(condition = glue("input.{bestFit} && !input.{firstDerivative}"),
                                                                 plotOutput(plotBestFit)
                                                ),
                                                conditionalPanel(condition = glue("input.{firstDerivative} && input.{bestFit}"),
                                                                 plotOutput(plotBoth)
                                                ),
                                                sliderInput(plotSlider,
                                                            glue("Plot{i}: Range of values"),
                                                            min = xmin,
                                                            max = xmax,
                                                            value = c(bounds[[1]][1],bounds[[2]][1]),
                                                            round = TRUE,
                                                            step = .10,
                                                            width = "85%")
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
    
    
    # Dynamically create a plot for of each of the n tabs.
    observe({
      req(values$numReadings)
      for (i in 1:values$numReadings) {
        if (i != blank) {
          local({
            myI <- i 
            plotDerivative = paste0("plotDerivative",myI)
            plotBestFit = paste0("plotBestFit",myI)
            plotBoth = paste0("plotBoth",myI)
            plotName = paste0("plot",myI)
            plotSlider = paste0("plotSlider",myI)
            # Plot containing raw data
            output[[plotName]] <- renderPlot({
              myConnecter$constructRawPlot(myI) +
                geom_vline(xintercept = input[[plotSlider]][1]) +
                geom_vline(xintercept = input[[plotSlider]][2])
            })
            # Plot containing first derivative with raw data
            output[[plotDerivative]] <- renderPlot({
              myConnecter$constructFirstDerivative(myI) +
                geom_vline(xintercept = input[[plotSlider]][1]) +
                geom_vline(xintercept = input[[plotSlider]][2])
            })
            # Plot containing best fit with raw data
            output[[plotBestFit]] <- renderPlot({
              myConnecter$constructBestFit(myI) + 
                geom_vline(xintercept = input[[plotSlider]][1]) +
                geom_vline(xintercept = input[[plotSlider]][2])
            })
            # Plot containing best, first derivative, and raw data
            output[[plotBoth]] <- renderPlot({
              myConnecter$constructBoth(myI) + 
                geom_vline(xintercept = input[[plotSlider]][1]) +
                geom_vline(xintercept = input[[plotSlider]][2])
            })
          })
        }
      }
    })

    # Automatically Fit Data
    observeEvent(input$automaticFit,
    handlerExpr = {
      req(input$inputFileID)
      object = myConnecter$object
      n = input$automaticIterations
      myConnecter$executeBLTrimmer(object,n)
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
    
    # Create the results table for the "Table" tab under the "Results" navbar menu.
    output$resulttable <- renderTable({
      data <-myConnecter$fitData()
      return(data)
    })
    output$summarytable <- renderTable({
      data <-myConnecter$summaryData1()
      return(data)
    })
    output$summarytable2 <- renderTable({
      data <-myConnecter$summaryData2()
      return(data)
    })
    output$error <- renderTable({
      data <-myConnecter$error()
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
        write.xlsx(myConnecter$error(), file2, sheetName = "error", append = TRUE)
      }
    )
}
