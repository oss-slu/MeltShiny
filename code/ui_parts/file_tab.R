# Tab: file
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
          label = "Cell number of blank",
          value = 1,
          inputId = "blankSampleID"
        ),
        checkboxInput(
          label = "No Blanks",
          value = FALSE,
          inputId = "noBlanksID"
        ),
        hr(style = "border-top: 1px solid #000000;"),
        textInput(
          label = "Enter the wavelength",
          value = "260",
          inputId = "wavelengthID"
        ),
        hr(style = "border-top: 1px solid #000000;"),
        textInput(
          label = "Temperature for concentration calculation (via Beer’s law)",
          value = "",
          inputId = "temperatureID"
        ),
        actionButton("submit", "Submit"),
        hr(style = "border-top: 1px solid #000000;"),
        radioButtons(
          inputId = "extinctConDecisionID",
          label = "Molar extinction coefficients:",
          choices = c("Nucleic acid sequence(s)", "Custom molar extinction coefficients"),
          selected = "Nucleic acid sequence(s)"
        ),
        selectInput(
          label = "Specify nucleic acid type",
          choices = c("RNA", "DNA"),
          selected = "RNA",
          inputId = "helixID"
        ),
        textInput(
          label = "Specify sequences",
          placeholder = "E.g: CGAAAGGU,ACCUUUCG",
          inputId = "seqID"
        ),
        actionButton(inputId = "seqHelp", icon("question")),
        checkboxGroupInput(
          label = "Optional methods",
          inputId = "methodsID",
          choices = list("Method 2", "Method 3"),
          selected = c("Method 2", "Method 3")
        ),
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
        selectInput(
          label = "Select the molecular state",
          choices = c("Heteroduplex", "Homoduplex", "Monomolecular"),
          selected = "Heteroduplex",
          inputId = "molecularStateID"
        ),
        actionButton(label = "Upload Data", inputId = "uploadData"),
        br(), br(),
        actionButton(
          label = "Reset Data",
          inputId = "resetData",
          style = "display: none;" # Initially hidden
        )
      ),
      mainPanel(tags$div(id = "placeholder"))
    )
  )
)
