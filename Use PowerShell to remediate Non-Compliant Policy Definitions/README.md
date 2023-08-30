# Introduction

This blogpost elaborates on the solution that was built to automatically remediate non-compliant Policy Definitions across an Azure environment. Under this Markdown file, there are two folders, each serving a different purpose.

1. pipelines: this folder contains the YAML pipeline that deploys the artifacts in the solutions folder
2. solutions: this folder contains the PowerShell scripts needed to deploy the solution

# Deployment

The deployment of the solution is split across four separate Tasks in one Stage.

1. Retrieve Personal Access Token: this Task in the YAML pipeline retrieves the Personal Access Token (PAT) that is needed to authenticate to either Azure DevOps or GitHub in a later Task
2. Start Policy Definition Remediation: this Task in the YAML pipeline checks the Azure Policy compliance state and starts one or multiple Remediation Tasks when one or multiple non-compliant Policy Definitions have been discovered
3. Create Azure DevOps Bug: this Task in the YAML pipeline creates a Bug on the current Iteration of a team's Board when one or multiple Remediation Tasks have failed and the selected tool is Azure DevOps. This Bug contains a HTML table with references to the failed Remediation Tasks in the Azure portal
4. Create GitHub Issue: this Task in the YAML pipeline creates an Issue in GitHub when one or multiple Remediation Tasks have failed and the selected tool is GitHub. This Bug contains a HTML table with references to the failed Remediation Tasks in the Azure portal

The reason that the YAML pipeline is build in this way is because of dependencies. If you would like to use the artifacts in this repository to deploy the solution, you need to change all the `<REPLACE>` items (e.g. Service Connection) as these differ per user. On top of that, you need to define whether you use Azure DevOps or GitHub and set the 'tooling' parameter accordingly. Note, when you set the 'tooling' parameter to 'AzureDevOps', the 'GitHub Parameters' do not have to be set and vice versa.

# Feedback

If anything is unclear or requires improvement, feel free to reach out to me directly. Apart from that, you can open a Pull Request to address the improvement directly.