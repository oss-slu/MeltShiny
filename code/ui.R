ui <- navbarPage(title = "MeltShiny",
                 id = "navbarPageID",
                 navbarMenu(title = "File",
                            tabPanel(title = "Add Dataset", 
                                     fluidPage(
                                       sidebarLayout(
                                         sidebarPanel(
                                           useShinyjs(),
                                           textInput(label = "Enter the blank sample",
                                                     placeholder = "E.g: 1",
                                                     value = 1,
                                                     inputId = "blankSampleID"
                                                     ),
                                           checkboxInput(label = "Show blank(s)",
                                                         value = FALSE,
                                                         inputId = "includeBlanksID"
                                                         ),
                                           textInput(label = "Enter the pathlength for each sample.",
                                                     placeholder = "E.g: 2,5,3,2",
                                                     inputId = "pathlengthID"
                                                     ),
                                           textInput(label = "Specify the extinction coefficients",
                                                     placeholder = "E.g: RNA,CGAAAGGU,ACCUUUCG",
                                                     inputId = "helixID"
                                                     ),
                                           selectInput(label = "Select the wavelengthID", 
                                                       choices = c("300","295","290","285","280","275","270","265","260","255","250","245","240","235","230"), 
                                                       selected = "260",
                                                       inputId = "wavelengthID"
                                                       ),
                                           textInput(label = "Enter the temperature",
                                                     placeholder = "E.g: 75",
                                                     value = 90,
                                                     inputId = "temperatureID"
                                                     ),
                                           checkboxGroupInput(label = "Choose methods",
                                                              inputId = "methodsID", 
                                                              choices = list("Method 1" = 1, 
                                                                             "Method 2" = 2, 
                                                                             "Method 3" = 3),
                                                              selected = c(1,2,3)),
                                           selectInput(label = "Select the molecular state", 
                                                       choices = c("Heteroduplex","Homoduplex","Monomolecular"), 
                                                       selected = "Heteroduplex",
                                                       inputId = "molecularStateID"
                                                       ),
                                           fileInput(label = "Select the dataset file",
                                                     multiple = FALSE,
                                                     accept = ".csv",
                                                     inputId = "inputFileID"
                                                     )
                                           ),
                                         mainPanel(DT::dataTableOutput(outputId = "inputTable"))
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
                                                 tabPanel(title = "Manual"),
                                                 tabPanel(title = "Automatic")
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
                                                      downloadButton(outputId = 'downloadVantID', "Download")
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
                                         sidebarPanel(h5("To reset table 1, press the button below."),
                                                      actionButton(inputId = "resetTable1ID",
                                                                   label = "Reset"
                                                      ),
                                                      h5("Download the table as an Excel file, with each of the three components on seperate sheets."),
                                                      textInput(label = "Enter the file name.",
                                                                inputId = "saveTableID"
                                                                ),
                                                      downloadButton(outputId = "downloadTableID", "Download")
                                         ),
                                         mainPanel(
                                           h5("Results for Individual Fits:"),
                                           DT::dataTableOutput(outputId = "resulttable"),
                                           #tableOutput(outputId = "resulttable"),
                                           h5("Summary of the Three Methods:"),
                                           tableOutput(outputId = "summarytable"),
                                           tableOutput(outputId = "summarytable2"),
                                           tableOutput(outputId = "summarytable3"),
                                           h5("Percent Error Between Methods:"),
                                           tableOutput(outputId = "error")
                                           )
                                         )
                                       )
                                     )
                            ),
                 tabPanel(title = "Help",
                          fluidPage(
                            mainPanel(
                              h1("How to Upload Data:"),
                              HTML("<li>Fill in the inputs necessary to perform calculations on the data set.</li>"), 
                              HTML("<li>Put the number of the sample you want to be the blank in the box, only enter one number</li>"), 
                              HTML("<li>You may check the box if you want to see the blank in your analysis.</li>"), 
                              HTML("<li>Enter the pathlengths for each data set as a comma separated list with no spaces.</li>"), 
                              HTML("<li>Enter the sequence information as a nucleic acid, a sequence and then complement(if applicable.</li>"), 
                              HTML("<li>Also write these as comma separated values with no spaces between them.</li>"), 
                              HTML("<li>Then use the drop down menus to select the wavelength and molecular state.</li>"), 
                              HTML("<li>Finally hit the browse button and select the data file(should be of type csv) from your computer.</li"), 
                              HTML("<li>The file should be in a format of column for temperature, blank column, then the columns for absorbance each followed by a blank column.</li>"), 
                              HTML("<li>No headers are necessary on the input file.</li>"),
                              HTML("<li>After the data is loaded in the Analysis and Results tabs will appear</li>"),
                              h1("Analysis Graphs:"),
                              HTML("<li>To view the graph of a specific sample click on the tab labeled with the sample number you would like to work with.<li>"),
                              HTML("<li>The best fit and first derivative lines can be shown on the graph by clicking on the boxes.</li>"), 
                              HTML("<li>The slider on the bottom is used to indicate the minimum and maximum values you would like considered when making a fit for the line.</li>"), 
                              HTML("<li>The point where these minimum and maximum values occur are shown by the vertical black lines on the graph.</li>"),
                              #h1("Fits")
                              h1("Van't Hoff Plots:"),
                              HTML("<li>The van't hoff page under results shows the van't hoff plot</li>"), 
                              HTML("<li>You may click individual points to remove them from the plot.</li>"), 
                              HTML("<li>To remove multiple points in one go you can click and drag on the graph to make a box.</li>"), 
                              HTML("<li>This box can be moved to fit over the points you want to remove.</li>"), 
                              HTML("<li>Once over the correct points hit the remove brushed button.</li>"), 
                              HTML("<li>If you want to add back the points you removed you may hit the reset plot button to restore the plot back to the original version.</li>"), 
                              HTML("<li>To save the version of the plot shown on the app enter a pdf of the van’t hoff plot, enter a name in the box and hit the download button.</li>"), 
                              HTML("<li>This will open the plot in a web browser.</li>"), 
                              HTML("<li>From there you may hit the print button on the webpage and instead of printing change the printer to save as pdf.</li>"),
                              h1("Result Tables:"),
                              HTML("<li>To save all of the result tables into one excel file enter what you want the file to be called.</li>"), 
                              HTML("<li>Then hit the download button.</li>"), 
                              HTML("<li>This will open a file explorer where you can then select where on your device you want the file to be saved.</li>"), 
                              HTML("<li>The excel file stores the tables in 3 different worksheets, one for each table.</li>"), 
                              HTML("<li>Method one and method two appear on different worksheets.</li>")
                              )
                            )
                          )
                 )
