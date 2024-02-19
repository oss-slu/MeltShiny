css <- "
.nav li a.disabled {
background-color: #D4D4D4 !important;
color: #333 !important;
cursor: not-allowed !important;
}"

ui <- navbarPage(
  title = "MeltShiny",
  theme = shinytheme("flatly"),
  id = "navbarPageID",
  navbarMenu(
    title = "File",
    tabPanel(
      title = "Add Dataset",
      fluidPage(
        sidebarLayout(
          sidebarPanel(
            useShinyjs(),
            inlineCSS(css),
            textInput(
              label = "Enter the blank",
              value = 1,
              inputId = "blankSampleID"
            ),
            checkboxInput(
              label = "No Blanks",
              value = FALSE,
              inputId = "noBlanksID"
            ),
            #hr(style = "border-top: 1px solid #000000;"),
            #textInput(
            #  label = "Enter the pathlengths",
            #  placeholder = "E.g: 2,5,3,2",
            #  inputId = "pathlengthID"
            #),
            hr(style = "border-top: 1px solid #000000;"),
            selectInput(
              label = "Select the wavelengthID",
              choices = c("300", "295", "290", "285", "280", "275", "270", "265", "260", "255", "250", "245", "240", "235", "230"), # nolint
              selected = "260",
              inputId = "wavelengthID"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            textInput(
              label = "Enter the temperature used to calculate the concentration with Beers law", # nolint
              value = 90,
              inputId = "temperatureID"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            selectInput(
              label = "Specify nucelic acid type",
              choices = c("RNA","DNA"),
              selected = "RNA",
              inputId = "helixID"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            textInput(
              label = "Specify sequences",
              placeholder  = "E.g: CGAAAGGU,ACCUUUCG",
              inputId = "seqID"
            ),
            radioButtons(
              inputId = "extinctConDecisionID",
              label = "Decide if you want to have the molar extinction coefficients calculated or provide them manually", # nolint
              choices = c("Nucleic acid sequence(s)", "Custom molar extinction coefficients"), # nolint
              selected = "Nucleic acid sequence(s)"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            checkboxGroupInput(
              label = "Optional methods",
              inputId = "methodsID",
              choices = list(
                "Method 2",
                "Method 3"
              ),
              selected = c(
                "Method 2",
                "Method 3"
              )
            ),
            hr(style = "border-top: 1px solid #000000;"),
            radioButtons(
              inputId = "Tm_methodID",
              label = "Choose a Tm method",
              choices = c("nls", "lm", "polynomial"),
              selected = "nls"
            ),
            checkboxInput(
              label = "Weighted tm for method 2",
              value = FALSE,
              inputId = "weightedTmID"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            selectInput(
              label = "Select the molecular state",
              choices = c("Heteroduplex", "Homoduplex", "Monomolecular"),
              selected = "Heteroduplex",
              inputId = "molecularStateID"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            fileInput(
              label = "Select the dataset file",
              multiple = FALSE,
              accept = ".csv",
              inputId = "inputFileID"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            actionButton(
              label = "Upload Data",
              inputId = "uploadData"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            checkboxInput(
              label = "All Datasets Uploaded?",
              value = FALSE,
              inputId = "datasetsUploadedID"
            ),
            #After all the datasets have been uploaded, the page will freeze before the analysis and results tabs are enabled.
            
          ),
          mainPanel(tags$div(id = "placeholder"))
        )
      )
    )
  ),
  navbarMenu(
    title = "Analysis",
    tabPanel(
      title = "Graphs",
      tabsetPanel(id = "tabs"),
      mainPanel(
      )
    ),
    tabPanel(
      title = "Fit",
      tabsetPanel(
        type = "tabs",
        tabPanel(
          title = "Manual",
          fluidPage(
            sidebarLayout(
              sidebarPanel(
                h5("Click to fit all graphs based on the chosen baselines."),
                actionButton(
                  inputId = "manualFitID",
                  label = "Fit Data"
                )
              ),
              mainPanel()
            )
          )
        ),
        tabPanel(
          title = "Automatic",
          fluidPage(
            sidebarLayout(
              sidebarPanel(
                textInput(
                  label = "Enter the number of iterations.",
                  placeholder = "E.g: 1000",
                  value = 1000,
                  inputId = "autoFitIterationsID"
                ),
                h5("Click to automatically fit all graphs based on chosen iterations."), # nolint
                actionButton(
                  inputId = "automaticFitID",
                  label = "Fit Data"
                )
              ),
              mainPanel()
            )
          )
        )
      )
    )
  ),
  navbarMenu(
    title = "Results",
    tabPanel(
      title = "Vant Hoff Plot",
      fluidPage(
        sidebarLayout(
          sidebarPanel(
            h4("Options:"),
            hr(style = "border-top: 1px solid #000000;"),
            h5("Brushed points:"),
            actionButton(
              inputId = "removeBrushedID",
              label = "Remove"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            h5("Reset plot:"),
            actionButton(
              inputId = "resetVantID",
              label = "Reset"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            h5("Download Vant Hoff:"),
            textInput(
              label = "Enter the file name.",
              inputId = "saveNameVantID"
            ),
            radioButtons(
              inputId = "vantDownloadFormatID",
              label = "Choose a file format:",
              choices = c("PDF" = "pdf", "JPEG" = "jpeg", "PNG" = "png"),
              selected = "pdf"
            ),
            downloadButton(
              outputId = "downloadVantID",
              label = "Download"
            )
          ),
          mainPanel(
            conditionalPanel(
              condition = "!output.vantPlot",
              "Loading...", style = "font-size: 29px;"
            ),
            plotOutput(
              outputId = "vantPlot",
              click = "vantClick",
              brush = brushOpts(id = "vantBrush")
            )
          )
        )
      )
    ),
    tabPanel(
      title = "Table",
      fluidPage(
        sidebarLayout(
          sidebarPanel(
            h4("Options:"),
            hr(style = "border-top: 1px solid #000000;"),
            h5("Reset individual fits table:"),
            actionButton(
              inputId = "resetTable1ID",
              label = "Reset"
            ),
            hr(style = "border-top: 1px solid #000000;"),
            h5("Download table:"),
            textInput(
              label = "Enter the file name.",
              inputId = "saveNameTableID"
            ),
            checkboxGroupInput(
              label = "Select parts:",
              inputId = "tableDownloadsPartsID",
              choices = list(
                "Individual Fits",
                "Method Summaries",
                "Percent Error",
                "All of the Above"
              ),
            ),
            radioButtons(
              inputId = "tableFileFormatID",
              label = "Choose a file format:",
              choices = list("CSV" = "csv", "XLSX" = "xlsx"), selected = "xlsx"
            ),
            downloadButton(
              outputId = "downloadTableID",
              label = "Download"
            )
          ),
          mainPanel(
            h5("Results for Individual Fits:"),
            DT::dataTableOutput(outputId = "individualFitsTable"),
            hr(style = "border-top: 1px solid #000000;"),
            h5("Summary of the Three Methods:"),
            tableOutput(outputId = "methodSummaryTable"),
            hr(style = "border-top: 1px solid #000000;"),
            h5("Percent Error Between Methods:"),
            tableOutput(outputId = "errorTable")
          )
        )
      )
    )
  ),
  tabPanel(
    title = "Help",
    fluidPage(
      mainPanel(
        h3("General information:"),
        HTML("<li>The program will open to the Upload page. This page is divided in two, a panel on the left for inputs and # nolint
                                   a panel on the right for the processed datasets.</li>"), # nolint
        HTML("<li>Each processed dataset will appear as a seperate table with unique captions and entry numbers. There will be five columns- row number, Sample, Pathlength, Temperature, and Absorbance. # nolint
                                   The tables can be thought of as layers, with chunks for each sample layered on top of oneanother.# nolint
                                   For each table, you may choose how many entries to show and navigate through pages. </li>"), # nolint
        HTML("<li>At the very top of the screen, there is a navigation bar, where there are four options- File, Analysis, Results, and Help.# nolint
                                   The Analysis and Results tabs will remain inactive until you have indicated you are done configuring inputs and uploading datasets.</li>"), # nolint
        HTML("<li>The help page will always be available should you need to reference it at any point.</li>"), # nolint
        HTML("<li>The upload tab under the File menu will also be available after you have indicated you are done uploading. The inputs on the left will be disabled, but you can still# nolint
                                   view and interact with the datasets for reference.</li>"), # nolint
        h3("How to Upload Data:"),
        h4("Applicable to each dataset:"),
        HTML("<li>For each dataset you upload, enter the number of the sample, in integer form, that will serve as the blank.# nolint
                                   By default, the blank value will be 1. If there are no blanks for a dataset, toggle the No Blank checkbox.</li>"), # nolint
        HTML("<li>For each dataset you upload, enter the pathlengths for each sample as a comma separated list with no spaces.</li>"), # nolint
        h4("Applicable to all datasets:"),
        HTML("<li>Use the drop down menu to select the wavelength in nm. By default, the value will be 260. Note, that for DNA, only a wavelength of 260 is allowed.</li>"), # nolint
        HTML("<li>Use the drop down menu to select the temperature used to calculate the concentration with Beers law.# nolint
                                   By default, the value will be 90.</li>"),
        HTML("<li>Enter the extinction coefficient information in the following format- nucleic acid, an appropriate sequence for that nucleotide, and, if applicable, its complement.</li>"), # nolint
        HTML("<li>Decide if you want to use methods 2 and 3. If method 2 is unselected, the Vant Hoff plot will not be generated. By default, both optional methods are selected.</li>"), # nolint
        HTML("<li>Decide which Tm method to use. Either nls to use the Tms from the fits in Method 1, lm to use a numeric method based on linear regression of fraction# nolint
                                   unfolded calculated with method 1, or polynomial to calculate Tms using the first derivative of a polynomial that approximates each curve.# nolint
                                   By default, nls is chosen.</li>"),
        HTML("<li>If you chose the nls method for Tm method and method 2 was selected, you have the option to turn on weighted non-line regression for method 2.# nolint
                                   If TRUE, method 2 will use the port algorithm to weight the regression in method 2 to standard errors in the Tm determined with method 1.# nolint
                                   By default, this checkbox is left unselected.</li>"), # nolint
        HTML("<li>Use the drop down menu to select the molecular model you want to fit. By default Heteroduplex is chosen.</li>"), # nolint
        HTML("<li>Hit the browse button and use the file manager select the data file from your computer. The file should be of csv format.# nolint
                                   The file should follow the following format temperature column, empty column, and a series of absorbance columns, with each seperated by an empty column.# nolint
                                   There should also not be any column headers.</li>"), # nolint
        h4("Done uploading datasets:"),
        HTML("<li>Select the checkbox at the very bottom of the sidepanel to indicated you are done uploading datasets.</li>"), # nolint
        HTML("<li>The Analysis and Results tabs will be enabled after all the datasets have been uploaded.</li>"), # nolint
        hr(style = "border-top: 1px solid #000000;"),
        h3("Analysis Graphs:"),
        HTML("<li>To access the analysis graphs, click the Analysis navbar menu, followed by the Graphs menu option. This will take you to a page with a series of# nolint
                                   tab panels, indicating the sample. Note, the blanks will not have a tab.</li>"), # nolint
        HTML("<li>To view the graph of a specific sample, click on the tab labeled with the sample number.</li>"), # nolint
        HTML("<li>The best fit and first derivative lines can be shown on the graph by toggling the checkboxes. A marker for the maximum of the first derivative is always shown.</li>"), # nolint
        HTML("<li>The range slider on the bottom of each graph is used to indicate the minimum and maximum values you would like considered when indicating a region for fitting.# nolint
                                   Note, the graph region will show only the selected range on the slider.</li>"), # nolint
        hr(style = "border-top: 1px solid #000000;"),
        h3("Fitting the analysis graphs:"),
        hr(style = "border-top: 1px solid #000000;"),
        h3("Van't Hoff Plots:"),
        HTML("<li>The van't hoff page under results shows the van't hoff plot</li>"), # nolint
        HTML("<li>You may click individual points to remove them from the plot.</li>"), # nolint
        HTML("<li>To remove multiple points in one go you can click and drag on the graph to make a box.# nolint
                                   This box can be moved to fit over the points you want to remove. Once over the correct points hit the remove button on the side panel.</li>"), # nolint
        HTML("<li>If you want to restore the plot back to the original version, press the restore button on the side panel.</li>"), # nolint
        HTML("<li>To save the version of the plot, enter enter a name in the box, choose the file format, and hit the download button.# nolint
                                   This will download the file directly to your download folder. If you prefer to choose where the file should be downloaded,# nolint
                                   change your web browser permission to ask where to download each file.</li>"), # nolint
        hr(style = "border-top: 1px solid #000000;"),
        h3("Results Table:"),
        HTML("<li>You can remove outliers on the individual fits portion of the results table by pressing the remove button. This will remove the row# nolint
                                   from the table. If you wish to restore the table, press the restore button on the side panel.</li>"), # nolint
        HTML("<li>To save the version of the table, enter enter a name in the box, choose which parts of the table to save, choose the file format,# nolint
                                   and hit the download button. This will download the file directly to your download folder. If you prefer to choose where the file# nolint
                                   should be downloaded, change your web browser permission to ask where to download each file.</li>"), # nolint
        hr(style = "border-top: 1px solid #000000;"),
        h3("Exit:"),
        HTML("<li>To close the program, close the browser tab. Then close the terminal application.</li>") # nolint
      )
    )
  )
)
