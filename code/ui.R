# ui.R is essentially the skeleton of the application and its visual component. 
# It is populated and dynamically changed by server.R

css <- "
.nav li a.disabled {
background-color: #D4D4D4 !important;
color: #333 !important;
cursor: not-allowed !important;
}
.img-half {
  width: 50%;    /* Image width will never exceed 100% of the container */
  max-widh:50%,
  height: auto;       /* Height will adjust automatically to maintain aspect ratio */
  display: block;     /* Ensure the image takes up the full block */
  margin: 0 auto;     /* Center the image */
  padding:0;
}
img{
clear:both;
}
"

ui <- navbarPage(
  title = "MeltShiny",
  theme = shinytheme("flatly"),
  id = "navbarPageID",
  tabPanel(
    title = "File",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          useShinyjs(),
          inlineCSS(css),
          fileInput(
            label = "Select the dataset file",
            multiple = FALSE,
            accept = ".csv",
            inputId = "inputFileID"
          ),
          hr(style = "border-top: 1px solid #000000;"),
          textInput(
            label = "Sample number of blank",
            value = 1,
            inputId = "blankSampleID"
          ),
          checkboxInput(
            label = "No Blanks",
            value = FALSE,
            inputId = "noBlanksID"
          ),
          hr(style = "border-top: 1px solid #000000;"),
          selectInput(
            label = "Select the wavelength",
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
          radioButtons(
            inputId = "extinctConDecisionID",
            label = "Decide if you want to have the molar extinction coefficients calculated or provide them manually", # nolint
            choices = c("Nucleic acid sequence(s)", "Custom molar extinction coefficients"), # nolint
            selected = "Nucleic acid sequence(s)"
          ),
          hr(style = "border-top: 1px solid #000000;"),
          selectInput(
            label = "Specify nucleic acid type",
            choices = c("RNA","DNA"),
            selected = "RNA",
            inputId = "helixID"
          ),
          hr(style = "border-top: 1px solid #000000;"),
          textInput(
            label = "Specify sequences",
            placeholder = "E.g: CGAAAGGU,ACCUUUCG",
            inputId = "seqID"
          ),
          actionButton(
            inputId = "seqHelp",
            icon("question")
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
          actionButton(
            inputId = "tmHelp",
            icon("question")
          ),
          hr(style = "border-top: 1px solid #000000;"),
          selectInput(
            label = "Select the molecular state",
            choices = c("Heteroduplex", "Homoduplex", "Monomolecular"),
            selected = "Heteroduplex",
            inputId = "molecularStateID"
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
          )
        ),
        mainPanel(
          tags$div(id = "placeholder")
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
    useShinyjs(),  # Include shinyjs for toggle functionality
    mainPanel(width = 12,  # Set full width for the Help page
      hr(style = "border-top: 1px solid #000000;"),
      
      # GENERAL INFORMATION Button
      actionButton("btn_general_info", "Show General Information", class = "btn-primary", style = "width:100%; margin-bottom:10px"),
      div(id = "general_info_content", hidden = TRUE,
        h3("GENERAL INFORMATION:"),
        hr(style = "border-top: 1px solid #000000;"),
        HTML("The program will open to the Upload page. This page is divided in two, a panel on the left for inputs and a panel on the right for the processed datasets."),
        div(img(src = "Upload_Processed.png", class="img-half", alt = "Screenshot showing the general information of the upload page")),
        HTML("Each processed dataset will appear as a separate table with unique captions and entry numbers. There will be five columns- row number, Sample, Pathlength, Temperature, and Absorbance."),
        div(img(src = "Processed_Data.png", class="img-half", alt = "Screenshot showing the Processed Dataset of the upload page",style = "clear:both")),
        hr(style = "border-top: 1px solid #000000;"),
        HTML("For each table, you may choose how many entries to show and navigate through pages."),
        div(img(src = "Navigation_Entries.png",class="img-half", alt = "Screenshot showing the entries and navigation")),
        HTML("At the very top of the screen, there is a navigation bar, where there are four options- File, Analysis, Results, and Help."),
        HTML("The Analysis and Results tabs will remain inactive until you have indicated you are done configuring inputs and uploading datasets. "),
        div(img(src = "Active_Inactive.png",class="img-half", alt = "Screenshot showing the Active and Inactive parts of Navigation bar")),
        HTML("The help page will always be available should you need to reference it at any point."),
        HTML("The inputs on the left will be disabled, but you can still view and interact with the datasets for reference."), 
        hr(style = "border-top: 1px solid #000000;")
      ),
      
      # HOW TO UPLOAD DATA Button
      actionButton("btn_upload_data", "Show How to Upload Data", class = "btn-primary", style = "width:100%; margin-bottom:10px"),
      div(id = "upload_data_content", hidden = TRUE,
        hr(style = "border-top: 1px solid #000000;"),
        h3("HOW TO UPLOAD DATA:"),
        hr(style = "border-top: 1px solid #000000;"),
        h4("Applicable to each dataset:"),
        HTML("For each dataset you upload, enter the number of the sample, in integer form, that will serve as the blank. By default, the blank value will be 1. If there are no blanks for a dataset, toggle the No Blank checkbox. For each dataset you upload, enter the pathlengths for each sample as a comma separated list with no spaces."),
        div(img(src = "Upload_Sequence.png", class="img-half", alt = "Screenshot showing the Upload , blank and sequences sections")),
        hr(style = "border-top: 1px solid #000000;"),
        h4("Applicable to all datasets:"),
        HTML("Use the drop down menu to select the wavelength in nm. By default, the value will be 260. Note, that for DNA, only a wavelength of 260 is allowed. Use the drop down menu to select the temperature used to calculate the concentration with Beers law. By default, the value will be 90. "),
        div(img(src = "Wavelength_Temp.png", class="img-half",alt = "Screenshot showing the Wavelength and Temperature")),
        HTML("Enter the extinction coefficient information in the following format- nucleic acid, an appropriate sequence for that nucleotide, and, if applicable, its complement. "),
        div(img(src = "Coefficient.png",class="img-half",  alt = "Screenshot showing the Coefficients")),
        HTML("Decide if you want to use methods 2 and 3. If method 2 is unselected, the Vant Hoff plot will not be generated. By default, both optional methods are selected. "),
        div(img(src = "Method.png", class="img-half",alt = "Screenshot showing the Method Selection")),
        HTML("Decide which Tm method to use. Either nls to use the Tms from the fits in Method 1, lm to use a numeric method based on linear regression of fraction unfolded calculated with method 1, or polynomial to calculate Tms using the first derivative of a polynomial that approximates each curve. By default, nls is chosen. If you chose the nls method for Tm method and method 2 was selected, you have the option to turn on weighted non-line regression for method 2. If TRUE, method 2 will use the port algorithm to weight the regression in method 2 to standard errors in the Tm determined with method 1. By default, this checkbox is left unselected. "),
        div(img(src = "Tm_Method.png",class="img-half",alt = "Screenshot showing the Tm Method Selection")),
        HTML("Use the drop down menu to select the molecular model you want to fit. By default Heteroduplex is chosen. Hit the browse button and use the file manager select the data file from your computer. The file should be of csv format. The file should follow the following format temperature column, empty column, and a series of absorbance columns, with each seperated by an empty column. There should also not be any column headers."),
        div(img(src = "Molecular.png",class="img-half", alt = "Screenshot showing the Molecular Method Selection")),
        hr(style = "border-top: 1px solid #000000;"),
        h4("Done uploading datasets:"),
        HTML("Select the checkbox at the very bottom of the sidepanel to indicate you are done uploading datasets. The Analysis and Results tabs will be enabled after all the datasets have been uploaded."),
        div(img(src = "Enabled.png",class="img-half",alt = "Screenshot showing the Enabled Navbar",)),
        hr(style = "border-top: 1px solid #000000;")
      ),
      
      # ANALYSIS GRAPHS Button
      actionButton("btn_analysis_graphs", "Show Analysis Graphs", class = "btn-primary", style = "width:100%; margin-bottom:10px"),
      div(id = "analysis_graphs_content", hidden = TRUE,
        hr(style = "border-top: 1px solid #000000;"),
        h3("ANALYSIS GRAPHS:"),
        hr(style = "border-top: 1px solid #000000;"),
        HTML("To access the analysis graphs, click the Analysis navbar menu, followed by the Graphs menu option. "),
        div(img(src = "Analysis.png",  class="img-half",alt = "Screenshot showing the Analysis and Graphs  Navbar"),
        HTML("This will take you to a page with a series of tab panels, indicating the sample, ")),
        div(img(src = "Samples.png",  class="img-half",alt = "Screenshot showing the Samples")),
        HTML("click on the tab labeled with the sample number. The best fit and first derivative lines can be shown on the graph by toggling the checkboxes. "),
        div(img(src = "BestFit_Derivative.png",class="img-half", alt = "Screenshot showing the BestFit Derivatives")),
        HTML("A marker for the maximum of the first derivative is always shown. The range slider on the bottom of each graph is used to indicate the minimum and maximum values you would like considered when indicating a region for fitting. Note, the graph region will show only the selected range on the slider."),
        div(img(src = "Slider.png",class="img-half", alt = "Screenshot showing the Slider")),
        hr(style = "border-top: 1px solid #000000;"),
        h3("FITTING THE ANALYSIS GRAPHS:"),
        hr(style = "border-top: 1px solid #000000;"),
        h3("Van't Hoff Plots:"),
        HTML("The van't hoff page under results shows the van't hoff plot. You may click individual points to remove them from the plot. To remove multiple points in one go you can click and drag on the graph to make a box. This box can be moved to fit over the points you want to remove. Once over the correct points hit the remove button on the side panel. "),
        div(img(src = "VantHoff_1.png", class="img-half", alt = "Screenshot showing the how to remove box of points")),
        div(img(src = "VantHoff_2.png", class="img-half", alt = "Screenshot showing the how to removed box of points")),
        HTML("If you want to restore the plot back to the original version, press the restore button on the side panel. "), 
        div(img(src = "Reset.png",  class="img-half", alt = "Screenshot showing the reset option")),
        div(img(src = "Points.png", class="img-half", alt = "Screenshot showing the points appearing after clicking on reset button")),
        HTML("To save the version of the plot, enter enter a name in the box, choose the file format, and hit the download button. This will download the file directly to your download folder. If you prefer to choose where the file should be downloaded, change your web browser permission to ask where to download each file."),
        div(img(src = "Download.png",class="img-half", alt = "Screenshot showing the download option")),

      ),
      
      # RESULTS TABLE Button
      actionButton("btn_results_table", "Show Results Table", class = "btn-primary", style = "width:100%; margin-bottom:10px"),
      div(id = "results_table_content", hidden = TRUE,
        hr(style = "border-top: 1px solid #000000;"),
        h3("RESULTS TABLE:"),
        hr(style = "border-top: 1px solid #000000;"),
        HTML("To save the version of the table, enter enter a name in the box, choose which parts of the table to save, choose the file format, and hit the download button. This will download the file directly to your download folder. If you prefer to choose where the file should be downloaded, change your web browser permission to ask where to download each file."),
        div(img(src = "Download_Table.png",class="img-half", alt = "Screenshot showing the download table option")),

      ),
      
      # EXIT Button
      actionButton("btn_exit", "Show Exit Instructions", class = "btn-primary", style = "width:100%; margin-bottom:10px"),
      div(id = "exit_content", hidden = TRUE,
        hr(style = "border-top: 1px solid #000000;"),
        h3("EXIT:"),
        hr(style = "border-top: 1px solid #000000;"),
        HTML("To close the program, close the browser tab. Then close the terminal application.")
      )
    )
  )
)
)
