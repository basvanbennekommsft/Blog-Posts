# Introduction

This blogpost elaborates on the solution that was built to enforce the creation of Role Assignments at the resource scope only. Under this Markdown file, there are four folders, each serving a different purpose.

1. modules: this folder contains all the Bicep modules used to deploy the Azure services (e.g. Azure Function)
2. parameters: this folder contains all the parameters needed to deploy the artifacts in the solutions folder
3. pipelines: this folder contains the YAML pipeline that deploys the artifacts in the solutions folder
4. solutions: this folder contains the Bicep files and PowerShell scripts needed to deploy the solution

# Deployment