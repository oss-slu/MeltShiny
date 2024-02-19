# CI/CD Deployment Pipeline for MeltShiny

This is the current direction of the CI/CD pipeline for the automatic deployment of MeltShiny.

1. **Create a new token using shinyapp.io**
    Log into ShinyApps.io and create a new token
2. **Create a Docker File**
    Use Docker to deploy Shiny app. Use Docker to build, test, and deploy applications by packaging everything MeltShiny needs to run into a container. This includes system dependencies, R packages, and code.
3. **Configure GitHub Actions**
    Create a .YAML file to define the GitHub Actions workflow
4. **Define the Workflow**
    In the .YAML file, define the steps for the workflow. Look at [deploy.yaml] file for details.
5. **Configure Secrets**
    In your GitHub repository's settings, go to "Secrets" and add a new repository secret called SHINYAPPS_TOKEN. Set the value of this secret to your shinyapps.io account token. You can find your account token by logging in to your shinyapps.io account, going to the "Tokens" section, and creating a new token.
6. **Commit and Push**
    Commit the deploy.yaml file to your repository and push it to the main branch (or the branch specified in your workflow).
7. **Monitor and Confirm**
    Check the GitHub Actions logs to monitor the deployment process and troubleshoot any issues that may arise. You can also check your shinyapps.io account to verify that the app was deployed successfully.