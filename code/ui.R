source("uiParts/file.R")
source("uiParts/analysis.R")
source("uiParts/results.R")
source("uiParts/help.R")

ui <- navbarPage(
  title = "MeltShiny",
  theme = shinytheme("flatly"),
  id = "navbarPageID",
  filePanel,
  analysisPanel,
  resultsPanel,
  helpPanel
)
