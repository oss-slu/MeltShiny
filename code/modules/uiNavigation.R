# modules/ui_navigation.R

setupUINavigation <- function(input, output, session) {
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
