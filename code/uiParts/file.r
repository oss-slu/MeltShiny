css <- "
.nav li a.disabled {
background-color: #D4D4D4 !important;
color: #333 !important;
cursor: not-allowed !important;
}
.img-half {
  width: 50%;
  max-width: 50%;
  height: auto;
  display: block;
  margin: 0 auto;
  padding: 0;
}
img{
clear: both;
}
"

filePanel <- tabPanel(
  title = "File",
  fluidPage(
    tags$head(
      # Smooth scroll-to-top JS handler
      tags$script(HTML("
        Shiny.addCustomMessageHandler('scrollToTop', function(message) {
          window.scrollTo({ top: 0, behavior: 'smooth' });
        });
      "))
    ),
    sidebarLayout(
      sidebarPanel(
        useShinyjs(),
        inlineCSS(css),
        fileInput("inputFileID", "Select the dataset file", multiple = FALSE, accept = ".csv"),
        actionButton("datasetHelp", icon("question")),
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
        selectInput("molecularStateID", "Select the Molecular State", 
                    choices = c("Heteroduplex", "Homoduplex", "Monomolecular"), 
                    selected = "Heteroduplex"),
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
              checkboxGroupInput("methodsID", "Optional Methods", choices = list("Method 2", "Method 3"), 
                                 selected = c("Method 2", "Method 3")),
              actionButton("methodsHelp", icon("question")),
              hr(),
              radioButtons("Tm_methodID", "Choose a Tm Method", choices = c("nls", "lm", "polynomial"), selected = "nls"),
              checkboxInput("weightedTmID", "Weighted Tm for Method 2", value = FALSE),
              actionButton("tmHelp", icon("question"))
            )
          )
        ),
        hr(),
        actionButton("uploadData", "Upload Data"),
        br(), br(),
        actionButton("resetData", "Reset Data", style = "display: none;")
      ),
      mainPanel(
        # Spinner in main panel
        div(
          id = "loadingSpinner",
          style = "display: none; text-align: center;",
          tags$img(src = "spinner.gif", height = "100px")
        ),
        
        tags$div(id = "placeholder")
      )
    )
  )
)