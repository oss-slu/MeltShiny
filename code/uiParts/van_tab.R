# Tab: van
tabPanel(
  title = "van't Hoff Plot",
  fluidPage(
    sidebarLayout(
      sidebarPanel(
        h4("Options:"),
        actionButton(inputId = "removeBrushedID", label = "Remove Brushed Points"),
        hr(),
        actionButton(inputId = "resetVantID", label = "Reset Plot"),
        hr(),
        textInput(label = "Enter the file name.", inputId = "saveNameVantID"),
        radioButtons(
          inputId = "vantDownloadFormatID",
          label = "Choose a file format:",
          choices = c("PDF" = "pdf", "JPEG" = "jpeg", "PNG" = "png"),
          selected = "pdf"
        ),
        downloadButton(outputId = "downloadVantID", label = "Download")
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
)
