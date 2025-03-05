# Includes the "Graphs" and "Fit" panels for data analysis.

analysisPanel <- navbarMenu(
  title = "Analysis",
  tabPanel(
    title = "Graphs",
    tabsetPanel(id = "tabs"),
    mainPanel()
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
              actionButton("manualFitID", "Fit Data")
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
              textInput("autoFitIterationsID", "Enter the number of iterations.", value = 1000, placeholder = "E.g: 1000"),
              h5("Click to automatically fit all graphs based on chosen iterations."),
              actionButton("automaticFitID", "Fit Data")
            ),
            mainPanel()
          )
        )
      )
    )
  )
)
