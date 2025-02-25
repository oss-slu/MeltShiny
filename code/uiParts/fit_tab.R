# Tab: fit
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
            actionButton(inputId = "manualFitID", label = "Fit Data")
          ),
          mainPanel()
        )
      )
    )
  )
)
