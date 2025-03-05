# Contains the File Upload UI, Advanced Settings, and Dataset-related inputs

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


filePanel <- tabPanel(
  title = "File",
  fluidPage(
    sidebarLayout(
      sidebarPanel(
        useShinyjs(),
        inlineCSS(css),
        fileInput("inputFileID", "Select the dataset file", multiple = FALSE, accept = ".csv"),
        hr(),
        textInput("blankSampleID", "Cell number of blank", value = 1),
        checkboxInput("noBlanksID", "No Blanks", value = FALSE),
        hr(),
        textInput("wavelengthID", "Enter the wavelength", value = "260"),
        hr(),
        selectInput("helixID", "Specify nucleic acid type", choices = c("RNA", "DNA"), selected = "RNA"),
        hr(),
        textInput("seqID", "Specify sequences", placeholder = "E.g: CGAAAGGU,ACCUUUCG"),
        actionButton("seqHelp", icon("question")),
        hr(),
        actionButton("toggleAdvanced", "Advanced Settings"),
        br(), br(),
        shinyjs::hidden(
          div(id = "advancedSettings",
            wellPanel(
              textInput("temperatureID", "Enter highest dataset temperature for Beer's law", value = ""),
              actionButton("submit", "Submit"),
              hr(),
              radioButtons("extinctConDecisionID", "Extinction coefficient calculation", 
                           choices = c("Nucleic acid sequence(s)", "Custom molar extinction coefficients"), 
                           selected = "Nucleic acid sequence(s)"),
              hr(),
              checkboxGroupInput("methodsID", "Optional methods", choices = list("Method 2", "Method 3"), 
                                 selected = c("Method 2", "Method 3")),
              hr(),
              radioButtons("Tm_methodID", "Choose a Tm method", choices = c("nls", "lm", "polynomial"), selected = "nls"),
              checkboxInput("weightedTmID", "Weighted tm for method 2", value = FALSE),
              actionButton("tmHelp", icon("question")),
              hr(),
              selectInput("molecularStateID", "Select the molecular state", 
                          choices = c("Heteroduplex", "Homoduplex", "Monomolecular"), selected = "Heteroduplex")
            )
          )
        ),
        hr(),
        actionButton("uploadData", "Upload Data"),
        br(), br(),
        actionButton("resetData", "Reset Data", style = "display: none;") # Initially hidden
      ),
      mainPanel(
        tags$div(id = "placeholder")
      )
    )
  )
)
