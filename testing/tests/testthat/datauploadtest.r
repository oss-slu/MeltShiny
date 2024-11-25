# test-my-app.R
library(shinytest2)

test_that("Upload Data Button Updates Datasets", {
  app <- AppDriver$new("path/to/app", name = "test-app")

  # Simulate clicking the 'uploadData' button
  app$set_inputs(uploadData = "click")

  # Check that datasetsUploadedID is updated to TRUE
  expect_true(app$get_value(input = "datasetsUploadedID"))
  
  # Check that the "resetData" button is shown
  expect_visible(app$find_element("#resetData"))
})

test_that("Temperature Updates on Submit", {
  app <- AppDriver$new("path/to/app", name = "test-app")

  # Set input temperatureID
  app$set_inputs(temperatureID = "25")

  # Simulate clicking the 'submit' button
  app$set_inputs(submit = "click")

  # Check that the concTVal matches the input
  expect_equal(app$get_output("concTVal"), 25)

  # Check that the appropriate log message is generated
  expect_true(grepl("TEMPERATURE UPDATED TO 25 - REPROCESSING", app$get_logs()))
})

test_that("Valid Inputs Pass Validation", {
  app <- AppDriver$new("path/to/app", name = "test-app")

  # Mock valid inputs
  app$set_inputs(
    noBlanksID = TRUE,
    helixID = "DNA,ATCG",
    seqID = "AGCT",
    wavelengthID = "260",
    blankSampleID = "",
    molecularStateID = "Monomolecular",
    inputFileID = list(datapath = "path/to/test.csv")
  )

  # Trigger upload
  app$set_inputs(uploadData = "click")

  # Check that is_valid_input is TRUE
  expect_true(app$get_output("is_valid_input"))
})

test_that("Invalid Inputs Trigger Modal", {
  app <- AppDriver$new("path/to/app", name = "test-app")

  # Mock invalid inputs
  app$set_inputs(
    noBlanksID = FALSE,
    blankSampleID = "not_a_number"
  )

  # Trigger upload
  app$set_inputs(uploadData = "click")

  # Check for modal dialog
  expect_true(app$find_element(".modal-title"))
})
