process_meltR_object <- function() {
  req(is_valid_input)
  
  if (datasetsUploadedID() == TRUE) {
    disable(selector = '.navbar-nav a[data-value="Help"')
    disable(selector = '.navbar-nav a[data-value="File"')
    disable("blankSampleID")
    disable("inputFileID")
    disable("datasetsUploadedID")
    disable("noBlanksID")
    disable("uploadData")
    
    Sys.sleep(5)
    
    enable(selector = '.navbar-nav a[data-value="Help"')
    enable(selector = '.navbar-nav a[data-value="File"')
  }

  if (datasetsUploadedID() == TRUE) {
    logInfo("CREATING MELTR OBJECT")

    # Send stored input values to the connecter class to create a MeltR object
    myConnecter <<- connecter(
      df = masterFrame,
      NucAcid = helix,
      wavelength = wavelengthVal,
      blank = blank,
      Tm_method = tmMethodVal,
      outliers = NA,
      Weight_Tm_M2 = weightedTmVal,
      Mmodel = molStateVal,
      methods = chosenMethods,
      concT = concTVal
    )
    
    myConnecter$constructObject()

    # Store data necessary for generating the Van't Hoff plot and the results table
    vantData <<- myConnecter$gatherVantData()
    individualFitData <<- myConnecter$indFitTableData()

    # Variable that handles the points on the Van't Hoff plot for removal
    if (chosenMethods[2] == TRUE && molStateVal != "Monomolecular.2State") {
      vals <<- reactiveValues(keeprows = rep(TRUE, nrow(vantData)))
      showTab("navbarPageID", "vantHoffPlotTab")
      
      # Initially render the Van't Hoff Plot
      renderVantHoffPlot()
    } else if (molStateVal == "Monomolecular.2State") {
      hideTab("navbarPageID", "vantHoffPlotTab")
    }
  }
}
