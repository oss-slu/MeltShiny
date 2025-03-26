UIcode <- function(input, session) {
  observeEvent(
    eventExpr = input$seqHelp,
    handlerExpr = {
      showModal(modalDialog(
        title = "Help for Specify Sequences",
        "Please enter the nucleotide sequence in the correct format. For DNA sequences, 
         use only A, T, C, and G. For RNA sequences, use only A, U, C, and G. Ensure the 
         sequence is free from spaces, special characters, or numbers.",
        footer = modalButton("Understood"),
        easyClose = FALSE,
        fade = TRUE
      ))
    }
  )

  observeEvent(
    eventExpr = input$tmHelp,
    handlerExpr = {
      showModal(modalDialog(
        title = "Help for TM Methods",
        "nls: Nonlinear least squares; lm: Linear model.",
        footer = modalButton("Understood"),
        easyClose = FALSE,
        fade = TRUE
      ))
    }
  )

  observeEvent(
    eventExpr = input$datasetHelp,
    handlerExpr = {
      showModal(modalDialog(
        title = "Help for Dataset Input",
        "Ensure the dataset is in tidy format with headers: Sample, Pathlength, Temperature, Absorbance.",
        footer = modalButton("Understood"),
        easyClose = FALSE,
        fade = TRUE
      ))
    }
  )

  observeEvent(
    eventExpr = input$methodsHelp,
    handlerExpr = {
      showModal(modalDialog(
        title = "Help for Optional Methods",
        "NEED TO FIGURE OUT EXACTLY WHAT TO PUT HERE",
        footer = modalButton("Understood"),
        easyClose = FALSE,
        fade = TRUE
      ))
    }
  )

  # Navigate back to the "File" tab when "Back to Home" button is pressed.
  observeEvent(input$backToHome, {
    updateNavbarPage(session, "navbarPageID", selected = "File")
  })

  observeEvent(input$btn_general_info, {
    shinyjs::hide("upload_data_content")
    shinyjs::hide("analysis_graphs_content")
    shinyjs::hide("results_table_content")
    shinyjs::hide("exit_content")
    shinyjs::toggle("general_info_content")
  })
  
  observeEvent(input$btn_upload_data, {
    shinyjs::hide("general_info_content")
    shinyjs::hide("analysis_graphs_content")
    shinyjs::hide("results_table_content")
    shinyjs::hide("exit_content")
    shinyjs::toggle("upload_data_content")
  })
  
  observeEvent(input$btn_analysis_graphs, {
    shinyjs::hide("general_info_content")
    shinyjs::hide("upload_data_content")
    shinyjs::hide("results_table_content")
    shinyjs::hide("exit_content")
    shinyjs::toggle("analysis_graphs_content")
  })
  
  observeEvent(input$btn_results_table, {
    shinyjs::hide("general_info_content")
    shinyjs::hide("upload_data_content")
    shinyjs::hide("analysis_graphs_content")
    shinyjs::hide("exit_content")
    shinyjs::toggle("results_table_content")
  })
  
  observeEvent(input$btn_exit, {
    shinyjs::hide("general_info_content")
    shinyjs::hide("upload_data_content")
    shinyjs::hide("analysis_graphs_content")
    shinyjs::hide("results_table_content")
    shinyjs::toggle("exit_content")
  })
}