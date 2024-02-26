# CI/CD Deployment Pipeline for MeltShiny

This is the current direction of the CI/CD pipeline for the automatic deployment of MeltShiny.

1. **Create a new token using shinyapp.io**
    Log into ShinyApps.io and create a new token
2. **Create a deploy script**   
    This will consist of a file called, "deploy.R", and it will specify which files consist of MeltShiny.
3. **Create a Docker File**
    Use Docker to deploy Shiny app. Use Docker to build, test, and deploy applications by packaging everything MeltShiny needs to run into a container. This includes system dependencies, R packages, and code.
4. **Configure GitHub Actions**
    Create a .YAML file to define the GitHub Actions workflow to first push MeltShiny.
5. **Define the Workflow**
    In the .YAML file, define the steps for the workflow. This .YAML will be used only once to deploy the app the first time. All other times it will rely on the [update-meltshiny.yaml] Look at [deploy.yaml] file for details.
6. **Configure Secrets**
    In your GitHub repository's settings, go to "Secrets" and add a new repository secret called SHINYAPPS_TOKEN. Set the value of this secret to your shinyapps.io account token. You can find your account token by logging in to your shinyapps.io account, going to the "Tokens" section, and creating a new token.
7. **Commit and Push**
    Commit the deploy.yaml file to your repository and push it to the main branch (or the branch specified in your workflow).

# Biweekly Update for Deployment
8. **Create Update Script**
    This script will update the data. When there are changes to the codebase, those changes will be applied to the next update. The script is called "update.R"
9. **Set up GitHub Actions for update.R script**
    Look at [update-meltshiny.yaml]. It will update every two weeks to be in sync with final sprint.
10. **Monitor and Confirm**
    Check the GitHub Actions logs to monitor the deployment process and troubleshoot any issues that may arise. You can also check your shinyapps.io account to verify that the app was deployed successfully.