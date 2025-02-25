# Tab: automatic
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
        h5("Click to automatically fit all graphs based on chosen iterations."),
        actionButton(inputId = "automaticFitID", label = "Fit Data")
      ),
      mainPanel()
    )
  )
)
