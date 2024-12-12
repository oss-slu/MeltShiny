library(shinytest2)

test_that("Upload Data Button Updates Datasets", {
  app <- AppDriver$new(name = "upload-data")

  # Simulate clicking the 'uploadData' button
  app$set_inputs(uploadData = "click")

  # Snapshot the app's state after the action
  app$expect_values()
})

test_that("Temperature Updates on Submit", {
  app <- AppDriver$new(name = "temperature-update")

  # Set input temperatureID
  app$set_inputs(temperatureID = "25")

  # Simulate clicking the 'submit' button
  app$set_inputs(submit = "click")
  
  # Snapshot the app's state after the action
  app$expect_values()
})

test_that("Valid Inputs Pass Validation", {
  app <- AppDriver$new(name = "valid-inputs")

  # Set mock valid inputs
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
  
  # Snapshot the app's state after the action
  app$expect_values()
})