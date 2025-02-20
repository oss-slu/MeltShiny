navbarMenu(
    title = "Results",
    tabPanel(
      title = "van't Hoff Plot",
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
            h5("Download van't Hoff:"),
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
  )