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
 )