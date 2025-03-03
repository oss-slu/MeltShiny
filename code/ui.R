source("uiParts/File.R")
source("uiParts/Analysis.R")
source("uiParts/Results.R")
source("uiParts/Help.R")

ui <- navbarPage(
  title = "MeltShiny",
  theme = shinytheme("flatly"),
  id = "navbarPageID",
  filePanel,
  analysisPanel,
  resultsPanel,
  helpPanel
)
