# Covers the "van't Hoff Plot" and "Table" sections for displaying results.

resultsPanel <- navbarMenu(
  title = "Results",
  tabPanel(
    title = "van't Hoff Plot",
    value = "vantHoffPlotTab",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          h4("Options:"),
          hr(),
          h5("Brushed points:"),
          actionButton("removeBrushedID", "Remove"),
          hr(),
          h5("Reset plot:"),
          actionButton("resetVantID", "Reset"),
          hr(),
          h5("Download van't Hoff:"),
          textInput("saveNameVantID", "Enter the file name."),
          radioButtons("vantDownloadFormatID", "Choose a file format:", 
                       choices = c("PDF" = "pdf", "JPEG" = "jpeg", "PNG" = "png"), selected = "pdf"),
          downloadButton("downloadVantID", "Download")
        ),
        mainPanel(
          conditionalPanel(condition = "!output.vantPlot", "Loading...", style = "font-size: 29px;"),
          plotOutput("vantPlot", click = "vantClick", brush = brushOpts(id = "vantBrush"))
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
          hr(),
          h5("Reset individual fits table:"),
          actionButton("resetTable1ID", "Reset"),
          hr(),
          h5("Download table:"),
          textInput("saveNameTableID", "Enter the file name."),
          checkboxGroupInput("tableDownloadsPartsID", "Select parts:", 
                             choices = list("Individual Fits", "Method Summaries", "Percent Error", "All of the Above")),
          radioButtons("tableFileFormatID", "Choose a file format:", choices = list("CSV" = "csv", "XLSX" = "xlsx"), selected = "xlsx"),
          downloadButton("downloadTableID", "Download")
        ),
        mainPanel(
          h5("Results for Individual Fits:"),
          DT::dataTableOutput("individualFitsTable"),
          hr(),
          h5("Summary of the Three Methods:"),
          tableOutput("methodSummaryTable"),
          hr(),
          h5("Percent Error Between Methods:"),
          tableOutput("errorTable")
        )
      )
    )
  )
)
