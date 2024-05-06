# CI/CD Deployment Pipeline for MeltShiny

This provides information for the CI/CD pipeline for the automatic deployment of MeltShiny.

1. **dockerfile**
    Create a dockerfile. Inside the dockerfile use `FROM rocker/shiny:latest` to use a Shiny Server pre-installed image. You cannot run the dockerfile with an Apple Silicon chip as the rocker image is not compatible. For testing, make sure it is done on Linux. Additional testing notes are added in the dockerfile. See `dockerfile` for more info. 

2. **deploy.R script**   
    This is the script that the dockerfile commands after it is activated in the deploy-shiny.yaml. the error_on_missing_name function is a function that strips quotation marks to make sure that the account info is correct. 

    The variables "SHINY_ACC_NAME", "TOKEN", and "SECRET" are variables used, so the github workflow can attach the GitHub secret when executing the dockerfile.

    Remember, the deploy.r relies on the dockerfile to execute, and the dockerfile relies on the github workflow.

3. **Configure Secrets**
    In your GitHub repository's settings, go to "Secrets and variables" and click on the "Actions" tab. There are three  repository secrets called "SHINY_ACC_NAME", "SECRET", AND "TOKEN". These should be the exact same name as the variables in the deploy.R script. You cannot see the secrets, but they can be changed. 
    
    **IF YOU NEED A NEW TOKEN**
    To get a new token, go to shinyapps.io and log in with the `oss@slu.edu` account information. Once logged, click on the oss Set the value of this secret to your shinyapps.io account icon, and it should provide a drop down column. Click on "Tokens". To be safe, create a new token by selecting the green bar, "Add Token". This will create a new Token with its corresponding secret. Copy the Token. Go back to the github repository secrets. Click on the TOKEN pencil to edit. Paste the token into and click "Update secret." Do the same thing for the secret token. Copy the Secret Token. Go back to the github repository secrets. Click on the SECRET pencil to edit. Paste the secret into and click "Update secret."

    THE ACCOUNT NAME SHOULD NEVER BE EDITED UNLESS THE APP IS TRANSFERRED TO ANOTHER SHINYAPPS.IO ACCOUNT. If that is the case, follow the same directions, and edit the "SHINY_ACC_NAME to include the name of the new shinyapps.io account.

4. **deploy-shiny.yaml**
    This workflow will be triggered weekly on Monday at 11:59 PM. This workflow will push and automatically deploy the code that is currently in the main branch. It will force an automatic update on shinyapps.io. When this workflow is triggered, the primary thing that it is doing is:

    1. Automatically building the dockerfile and pulling in all the github secrets information that was created earlier. 
    2. Once it builds the dockerfile image, it runs the `CMD Rscript deploy.R`. This triggers the "deploy.R script that is contained within the dockerfile, and with the github secret information provided in the workflow, it deploys the app. 

    Remember, the deploy.r relies on the dockerfile to execute, and the dockerfile relies on the github workflow.

5. **Questions or Help**
    Reach out to me on github (MassiPapi) or slack for any confusion or help.