ui <- navbarPage(title = "MeltShiny",
                 id = "navbarPageID",
                 navbarMenu(title = "File",
                            tabPanel(title = "Add Data", 
                                     fluidPage(
                                       sidebarLayout(
                                         sidebarPanel(
                                           useShinyjs(),
                                           textInput(label = "Enter the blank sample.",
                                                     placeholder = "E.g: 1",
                                                     value = 1,
                                                     inputId = "blankSampleID"
                                                     ),
                                           checkboxInput(label = "Show blank during analysis step",
                                                         value = FALSE,
                                                         inputId = "includeBlanksID"
                                                         ),
                                           textInput(label = "Enter the pathlength for each sample. (Note, these values should be separated by commas
                                                     and have no spaces in between them.) If there are no blanks, enter the word none.",
                                                     placeholder = "E.g: 2,5,3,2",
                                                     inputId = "pathlengthID"
                                                     ),
                                           textInput(label = "Enter the sequence information in the following order: a nucleic acid, a sequence, and, if applicable, its complement).
                                                              (Note, these values should be seperated by commas and have no spaces in between them.)",
                                                     placeholder = "E.g: RNA,CGAAAGGU,ACCUUUCG",
                                                     inputId = "helixID"
                                                     ),
                                           selectInput(label = "Select the molecular state.", 
                                                       choices = c("Heteroduplex","Homoduplex","Monomolecular"), 
                                                       selected = "Heteroduplex",
                                                       inputId = "molecularStateID"
                                                       ),
                                           selectInput(label = "Select the wavelengthID. (Note, thermodynamic parameters can only be collected for DNA at 260 nm.)", 
                                                       choices = c("300","295","290","285","280","275","270","265","260","255","250","245","240","235","230"), 
                                                       selected = "260",
                                                       inputId = "wavelengthID", 
                                                       ),
                                           fileInput(label = "Select the file containing the dataset.",
                                                     multiple = FALSE,
                                                     accept = ".csv",
                                                     inputId = "inputFileID",
                                                     )
                                           ),
                                         mainPanel(tableOutput(outputId = "table"))
                                         )
                                       )
                                     )
                            ),
                 navbarMenu(title = "Analysis",
                            tabPanel(title = "Graphs",
                                     tabsetPanel(id = "tabs")
                                     ),
                            tabPanel(title = "Fit",
                                     tabsetPanel(type = "tabs",
                                                 tabPanel("Manual"),
                                                 tabPanel("Automatic")
                                                 )
                                     )
                            ),
                 navbarMenu(title = "Results",
                            tabPanel(title = "Van't Hoff Plot", 
                                     fluidPage(
                                       sidebarLayout(
                                         sidebarPanel(h4("Options:"),
                                                      h5("To remove more than one point at once, 
                                                         click and drag a selection box over the region
                                                         and press the button below."),
                                                      actionButton(inputId = "removeBrushedID", 
                                                                   label = "Remove brushed"
                                                                   ),
                                                      h5("To reset the plot, press the button below."),
                                                      actionButton(inputId = "resetVantID",
                                                                   label = "Reset plot"
                                                                   ),
                                                      h5("To download a pdf version of the Van't Hoff plot, use the widget below."),
                                                      textInput(label = "Enter the file name.",
                                                                inputId = "saveVantID"
                                                                ),
                                                      downloadButton(outputId = 'downloadVantID')
                                         ),
                                         mainPanel(
                                           plotOutput(outputId = "vantPlot",
                                                      click = "vantClick",
                                                      brush = brushOpts(id = "vantBrush")
                                                      )
                                           )
                                         )
                                       )
                                     ),
                            tabPanel(title = "Table", 
                                     fluidPage(
                                       sidebarLayout(
                                         sidebarPanel(h5("Download the table as an Excel file, with each of the three components on seperate sheets."),
                                                      textInput(label = "Enter the file name.",
                                                                inputId = "saveTableID"
                                                                ),
                                                      downloadButton(outputId = "downloadTableID")
                                         ),
                                         mainPanel(
                                           h5("Results for Individual Fits:"),
                                           tableOutput(outputId = "resulttable"),
                                           h5("Summary of the Three Methods:"),
                                           tableOutput(outputId = "summarytable"),
                                           tableOutput(outputId = "summarytable2"),
                                           h5("Percent Error Between Methods:"),
                                           tableOutput(outputId = "error")
                                           )
                                         )
                                       )
                                     )
                            ),
                 tabPanel(title = "Help")
                 )
