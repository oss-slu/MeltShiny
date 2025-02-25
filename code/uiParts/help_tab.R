# Tab: help
tabPanel(
  title = "Help",
  fluidPage(
    useShinyjs(),
    sidebarLayout(
      sidebarPanel(
        actionButton("backToHome", "Back to Home", icon = icon("home"))
      ),
      mainPanel(
        actionButton("btn_general_info", "Show General Information"),
        actionButton("btn_upload_data", "Show How to Upload Data"),
        actionButton("btn_analysis_graphs", "Show Analysis Graphs"),
        actionButton("btn_results_table", "Show Results Table"),
        actionButton("btn_exit", "Show Exit Instructions"),
        div(id = "general_info_content", hidden = TRUE, h3("GENERAL INFORMATION:"), "The program opens on the Upload page..."),
        div(id = "upload_data_content", hidden = TRUE, h3("HOW TO UPLOAD DATA:"), "Instructions for data upload..."),
        div(id = "analysis_graphs_content", hidden = TRUE, h3("ANALYSIS GRAPHS:"), "Graph interaction instructions..."),
        div(id = "results_table_content", hidden = TRUE, h3("RESULTS TABLE:"), "Instructions on saving tables..."),
        div(id = "exit_content", hidden = TRUE, h3("EXIT:"), "To close the program, close the browser tab and terminal.")
      )
    )
  )
)
