source("File.R")
source("Analysis.R")
source("Results.R")
source("Help.R")

ui <- navbarPage(
  title = "MeltShiny",
  theme = shinytheme("flatly"),
  id = "navbarPageID",
  filePanel,
  analysisPanel,
  resultsPanel,
  helpPanel
)
