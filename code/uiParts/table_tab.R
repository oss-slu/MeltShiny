# Tab: table
tabPanel(
  title = "Table",
  fluidPage(
    sidebarLayout(
      sidebarPanel(
        h4("Options:"),
        actionButton(inputId = "resetTable1ID", label = "Reset Table"),
        hr(),
        textInput(label = "Enter the file name.", inputId = "saveNameTableID"),
        checkboxGroupInput(
          label = "Select parts:",
          inputId = "tableDownloadsPartsID",
          choices = list("Individual Fits", "Method Summaries", "Percent Error", "All of the Above")
        ),
        radioButtons(
          inputId = "tableFileFormatID",
          label = "Choose a file format:",
          choices = list("CSV" = "csv", "XLSX" = "xlsx"),
          selected = "xlsx"
        ),
        downloadButton(outputId = "downloadTableID", label = "Download")
      ),
      mainPanel(
        h5("Results for Individual Fits:"),
        DT::dataTableOutput(outputId = "individualFitsTable"),
        hr(),
        h5("Summary of the Three Methods:"),
        tableOutput(outputId = "methodSummaryTable"),
        hr(),
        h5("Percent Error Between Methods:"),
        tableOutput(outputId = "errorTable")
      )
    )
  )
)
