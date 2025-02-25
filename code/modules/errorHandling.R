# modules/error_handling.R
handleError <- function(session, title, message) {
  showModal(
    modalDialog(
      title = title,
      message,
      easyClose = TRUE,
      footer = modalButton("Close")
    )
  )
  
  # After the modal is dismissed, reset the session (triggered by uploadData)
  observeEvent(session$input$uploadData, {
    delay(5000, {
      session$reload()
    })
  })
}
