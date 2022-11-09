# Back end
server <- function(input,output, session){
  #Reactive list variable 
  values <- reactiveValues(masterFrame = NULL,numReadings = NULL)
  #Upload Project File
  
  upload <- observeEvent(eventExpr = input$inputFile,
                         handlerExpr = {
                           # Declaring variables
                           pathlengths <- c(unlist(strsplit(input$pathlengths,",")))
                           req(input$inputFile)
                           fileName <- input$inputFile$datapath
                           cd <- read.csv(file = fileName,header = FALSE)
                           df <- cd %>% select_if(~ !any(is.na(.)))
                           # Creating temporary frame to store sample data
                           columns <- c("Sample", "Pathlength", "Temperature", "Absorbance")
                           tempFrame <- data.frame(matrix(nrow = 0, ncol = 4))
                           colnames(tempFrame) <-columns
                           readings <- ncol(df)
                           # Loop that appends sample data 
                           p <- 1
                           for (x in 2:readings) {
                             col <- df[x]
                             sample <- rep(c(counter),times = nrow(df[x]))
                             pathlength <- rep(c(pathlengths[p]),times = nrow(df[x]))
                             col <- df[x]
                             t <- data.frame(sample,pathlength,df[1],df[x])
                             names(t) <- names(tempFrame)
                             tempFrame <- rbind(tempFrame, t)
                             p <- p + 1
                             counter <<- counter + 1
                           }
                           values$numReadings <- counter - 1
                           values$masterFrame <- rbind(values$masterFrame, tempFrame)
                           values$uploaded <- 1
                         }
                         
  )
  output$Table <- renderTable({
    return(values$masterFrame)})
  
  #code that hides "Plots" drop-down hidden until file successfully uploads
  observeEvent(
    eventExpr = is.null(values$numReadings),
    handlerExpr = {
      hideTab(inputId = "navbar",target = "Analysis")
    }
  )
  
  
  #code that creates n tabPanels for the "Analysis" tabPanel
  observe({
    req(values$numReadings)
    lapply(start:values$numReadings,function(i){
      tabName = paste("Sample",i,sep=" ")
      plotName = paste0("plot",i)
      plotSlider <- paste0("plotSlider",i)
      data = values$masterFrame[values$masterFrame$Sample == i,]
      xmin = min(data$Temperature)
      xmax = max(data$Temperature)
      plotDerivative = paste0("plotDerivative",i)
      fitData = paste0("fit",i)
      firstDerivative = paste0("firstDerivative",i)
      fitIterations = paste0("fitIteration",i)
      checkbox = paste0("checkbox",i)
      appendTab(inputId = "tabs",
                tab = tabPanel(
                  tabName,
                  fluidPage(
                    sidebarLayout(
                      sidebarPanel(
                        #side-panel code
                        h2("Features"),
                        checkboxInput(inputId=firstDerivative,label="First Derivative"),
                        hr(),
                        textInput(fitIterations,"Enter the number of combitions to test for fitting.",value=100),
                        actionButton(fitData,"Fit Data")
                      ),mainPanel(
                        #main-panel code
                        plotOutput(plotName),
                        column(6,sliderInput(plotSlider,glue("Plot{i}: Range of values"),min=xmin,max=xmax,value=c(xmin,xmax)))
                      )
                    )
                  )
                ))
    })
    start <<- values$numReadings + 1
    showTab(inputId = "navbar",target = "Analysis")
  })
  
  
  #Dynamically creates a renderPlot object of each absorbance readings
  observe({
    req(input$inputFile)
    for (i in 1:values$numReadings) {
      local({
        myI <- i 
        plotName = paste0("plot",myI)
        plotSlider = paste0("plotSlider",myI)
        output[[plotName]] <- renderPlot({
          data = values$masterFrame[values$masterFrame$Sample == myI,]
          ggplot(data, aes(x = Temperature, 
                           y = Absorbance, 
                           color = factor(Sample))) +
            geom_point() + theme_classic() +
            geom_vline(xintercept = input[[plotSlider]][1]) +
            geom_vline(xintercept = input[[plotSlider]][2])
        })
      })
    }
  })
  
  #Dynamically renders & outputs the created plots
  #Dynamically renders & outputs inputSliders for each plot
  #Output Structure: two plots & sliders per column
  output$dataVisualContents <- renderUI({
    req(input$inputFile)
    lapply(1:values$numReadings, function(i){
      plotSlider <- paste0("plotSlider",i)
      plotName <- paste0("plot",i)
      nextPlot <- paste0("plot",i + 1)
      nextSlider = paste0("plotSlider",i + 1)
      data <- values$masterFrame[values$masterFrame$Sample == i,]
      xmin <- min(data$Temperature)
      xmax <- max(data$Temperature)
      #even # of plots
      if (values$numReadings %% 2 == 0) {
        if (i %% 2 != 0) {
          div(
            fluidRow(
              column(6,plotOutput(plotName)),
              column(6,plotOutput(nextPlot))
            ),
            fluidRow(
              column(6,sliderInput(plotSlider,glue("Plot{i}: Range of values"),min = xmin,max = xmax,value = c(xmin,xmax))),
              column(6,sliderInput(nextSlider,glue("Plot{i + 1}: Range of values"),min = xmin,max = xmax,value = c(xmin,xmax))),
            ),
            hr()
          )
        }
        #odd # of plots
      }else{
        if (i == values$numReadings) {
          tagList(
            plotOutput(plotName),
            sliderInput(plotSlider,glue("Plot{i}: Range of values"),min = xmin,max = xmax,value = c(xmin,xmax))
          )
        }else {
          if (i %% 2 != 0) {
            div(
              fluidRow(
                column(6,plotOutput(plotName)),
                column(6,plotOutput(nextPlot))
              ),
              fluidRow(
                column(6,sliderInput(plotSlider,glue("Plot{i}: Range of values"),min = xmin,max = xmax,value = c(xmin,xmax))),
                column(6,sliderInput(nextSlider,glue("Plot{i+1}: Range of values"),min = xmin,max = xmax,value = c(xmin,xmax)))
              ),
              hr()
            )
          }
        }
      }
    })
  })
  
  #Dynamically output # of check boxes
  output$checkboxes <- renderUI({
    req(input$inputFile)
    boxOutput <- lapply(1:values$numReadings, function(i){
      plotName <- paste0("plot",i)
      plotBox <- paste0("plotBox",i)
      checkboxInput(plotBox,plotName,value = TRUE)
    })
    do.call(tagList,boxOutput)
  })
}



# Run the app
#shinyApp(ui = ui, server = server)