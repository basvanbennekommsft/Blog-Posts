# Introduction

This blogpost elaborates on the solution that was built to enforce the creation of Role Assignments at the resource scope only. Under this Markdown file, there are four folders, each serving a different purpose.

1. modules: this folder contains all the Bicep modules used to deploy the Azure services (e.g. Azure Function)
2. parameters: this folder contains all the parameters needed to deploy the artifacts in the solutions folder
3. pipelines: this folder contains the YAML pipeline that deploys the artifacts in the solutions folder
4. solutions: this folder contains the Bicep files and PowerShell scripts needed to deploy the solution

# Deployment

The deployment of the solution is split over three seperate stages.

1. Automation: this stage in the YAML pipeline deploys the standard automation resources (e.g. Storage Account) and the Role Assignment for the System-assigned Managed Identity
2. Function: this stage in the YAML pipeline zips the artifacts of the Function and subsequently uses these to deploy the Function on the Function App
3. Monitoring: this stage in the YAML pipeline deploys the standard monitoring resources (e.g. Action Group)

The reason that the YAML pipeline is build in this way is because of dependencies. For instance, the Function needs to be deployed on the Function App before you can target it in the Action Group. If you would like to use the artifacts in this repository to deploy the solution, you need to change all the `<REPLACE>` items (e.g. Service Connection) as these differ per user. On top of that, the YAML pipeline is based on Azure Pipelines and thus needs to be tweaked when you would like to use another deployment method such as GitHub Actions.

# Feedback

If anything is unclear or requires improvement, feel free to reach out to me directly. Apart from that, you can open a Pull Request to address the improvement directly.