# Manages the "Help" panel with extra resources.

helpPanel <-  tabPanel(
  title = "Help",
  fluidPage(
    useShinyjs(),  # Include shinyjs for toggle functionality

    tags$head(
        tags$style(HTML("
          .btn-custom {
            padding: 5px 10px;
            background-color: #2C3E50;
            border: none;
          }
          .sidebar-panel-custom {
            width: 154px;
            padding: 10px;
          }
          .main-panel-custom {
            margin-left: 200px;
          }
        "))
      ),
      sidebarLayout(
        sidebarPanel(
          class = "sidebar-panel-custom",
          actionButton("backToHome", "Back to Home", icon = icon("home"), class = "btn-custom")
        ),
      
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
        HTML("For each dataset you upload, enter the number of the samples, in integer form, that will serve as the blank. By default, the blank value will be 1. If there are no blanks for a dataset, toggle the No Blank checkbox. For each dataset you upload, enter the pathlengths for each sample as a comma separated list with no spaces."),
        div(img(src = "Upload_Sequence.png", class="img-half", alt = "Screenshot showing the Upload , blank and sequences sections")),
        hr(style = "border-top: 1px solid #000000;"),
        h4("Applicable to all datasets:"),
        HTML("Use the textbox to input the wavelength in nm. By default, the value will be 260. Note, that for DNA, only a wavelength of 260 is allowed. Use the textbox to input the temperature used to calculate the concentration with Beers law. By default, the value will autopopulate with the highest temperature found in the dataset. "),
        div(img(src = "Wavelength_Temp.png", class="img-half",alt = "Screenshot showing the Wavelength and Temperature")),
        HTML("Enter the extinction coefficient information in the following format- nucleic acid, an appropriate sequence for that nucleotide, and, if applicable, its complement. "),
        div(img(src = "Coefficient.png",class="img-half",  alt = "Screenshot showing the Coefficients")),
        HTML("Decide if you want to use methods 2 and 3. If method 2 is unselected, the van't Hoff plot will not be generated. By default, both optional methods are selected. "),
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
        h3("van't Hoff Plots:"),
        HTML("The van't Hoff page under results shows the van't Hoff plot. You may click individual points to remove them from the plot. To remove multiple points in one go you can click and drag on the graph to make a box. This box can be moved to fit over the points you want to remove. Once over the correct points hit the remove button on the side panel. Additionaly there will be no vant Hoff plot generated when monomolecular is selected as an option. "),
        div(img(src = "van'tHoff.png", class="img-half", alt = "Screenshot showing the how to remove box of points")),
        div(img(src = "RemovedPoints.png", class="img-half", alt = "Screenshot showing the how to removed box of points")),
        HTML("If you want to restore the plot back to the original version, press the restore button on the side panel. "), 
        div(img(src = "ResetButton.png",  class="img-half", alt = "Screenshot showing the reset option")),
        div(img(src = "ResetPoints.png", class="img-half", alt = "Screenshot showing the points appearing after clicking on reset button")),
        HTML("To save the version of the plot, enter a name in the box, choose the file format, and hit the download button. This will download the file directly to your downloads folder. If you prefer to choose where the file should be downloaded, change your web browser permissions to ask where to download each file."),
        div(img(src = "Download.png",class="img-half", alt = "Screenshot showing the download option")),

      ),
      
      # RESULTS TABLE Button
      actionButton("btn_results_table", "Show Results Table", class = "btn-primary", style = "width:100%; margin-bottom:10px"),
      div(id = "results_table_content", hidden = TRUE,
        hr(style = "border-top: 1px solid #000000;"),
        h3("RESULTS TABLE:"),
        hr(style = "border-top: 1px solid #000000;"),
        HTML("To save the version of the table, enter a name in the box, choose which parts of the table to save, choose the file format, and hit the download button. This will download the file directly to your downloads folder. If you prefer to choose where the file should be downloaded, change your web browser permissions to ask where to download each file."),
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
