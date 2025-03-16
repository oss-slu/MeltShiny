source("uiParts/file.r")
source("uiParts/analysis.r")
source("uiParts/results.r")
source("uiParts/help.r")

ui <- navbarPage(
  title = "MeltShiny",
  theme = shinytheme("flatly"),
  id = "navbarPageID",
  filePanel,
  analysisPanel,
  resultsPanel,
  helpPanel
)
