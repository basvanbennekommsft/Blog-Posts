<#
  .SYNOPSIS
  This PowerShell script remediates non-compliant Policy Definitions by creating one or multiple Remediation Tasks.

  .DESCRIPTION
  The Start-PolicyDefinitionRemediation.ps1 PowerShell script checks the Azure Policy state. When there are one or
  multiple non-compliant Policy Definitions, the PowerShell script creates a Remediation Task for each and every
  one of them. If one or multiple Remediation Tasks fail, their respective objects are added to a PowerShell
  variable for that is outputted for later use in the Azure DevOps Pipeline.

  .EXAMPLE
  Start-PolicyDefinitionRemediation.ps1

  .INPUTS
  None.

  .OUTPUTS
  The Start-PolicyDefinitionRemediation.ps1 PowerShell script outputs multiple string values for logging purposes,
  a JSON string containing all the failed Remediation Tasks and a boolean value, both of which are used in a later
  stage of the Azure DevOps Pipeline.
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Set the variables that are used in the rest of the PowerShell script
Write-Verbose "`nSet the variables that are used in the rest of the PowerShell script"
$today = Get-Date
$yesterday = $today.AddDays(-1)
$createAzureDevOpsBug = $false
#endregion

#region Get the Azure Policy state and select all the unique non-compliant Policy Definitions
Write-Output "`nGet the Azure Policy state and select all the unique non-compliant Policy Definitions"
$complianceState = Get-AzPolicyState -From $yesterday -To $today

Write-Verbose "`nSelect all the non-compliant instances"
$nonCompliantInstances = $complianceState | Where-Object -FilterScript { $_.ComplianceState -eq 'NonCompliant' }

Write-Verbose "`nSelect all the unique non-compliant Policy Definitions"
$noncompliantPolicyDefinitions = $nonCompliantInstances | Select-Object -Property PolicyDefinitionName, PolicyDefinitionReferenceId, PolicyAssignmentId, PolicyAssignmentScope -Unique
Write-Output "`At the moment, there is/are '$($noncompliantPolicyDefinitions.Count)' unique non-compliant Policy Definition(s)"
#endregion

#region Create a Remediation Task for each of the non-compliant Policy Definitions
$failedPolicyRemediationTasks = @()
foreach ($noncompliantPolicyDefinition in $noncompliantPolicyDefinitions) {
    Write-Output "`nThe '$($noncompliantPolicyDefinition.PolicyDefinitionName)' Policy Definition, assigned by the '$($noncompliantPolicyDefinition.PolicyAssignmentId.Split("/")[-1])' Policy Assignment is not compliant and thus needs to be remediated"
    try {
        if (!($noncompliantPolicyDefinition.PolicyDefinitionReferenceId)) {
            Write-Verbose "`tThe '$($noncompliantPolicyDefinition.PolicyDefinitionName)' Policy Definition is not part of a Policy Set. Therefore, the 'Start-AzPolicyRemediation' command does not use the -PolicyDefinitionReferenceId parameter"
            $params = @{
                'Name'               = $noncompliantPolicyDefinition.PolicyDefinitionName
                'PolicyAssignmentId' = $noncompliantPolicyDefinition.PolicyAssignmentId
            }
        }
        else {
            Write-Verbose "`tThe '$($noncompliantPolicyDefinition.PolicyDefinitionName)' Policy Definition is part of a Policy Set. Therefore, the 'Start-AzPolicyRemediation' command does use the -PolicyDefinitionReferenceId parameter"
            $params = @{
                'Name'                        = $noncompliantPolicyDefinition.PolicyDefinitionName
                'PolicyAssignmentId'          = $noncompliantPolicyDefinition.PolicyAssignmentId
                'PolicyDefinitionReferenceId' = $noncompliantPolicyDefinition.PolicyDefinitionReferenceId
            }
        }
        $newPolicyRemediationTask = Start-AzPolicyRemediation @params
        if ($newPolicyRemediationTask.ProvisioningState -eq 'Succeeded') {
            Write-Output "`tThe provisioning state of the Remediation Task is set to Succeeded. Moving on to the next non-compliant Policy Definition"
        }
        elseif ($newPolicyRemediationTask.ProvisioningState -eq 'Failed') {
            Write-Output "`tThe provisioning state of the Remediation Task is set to Failed. Adding it to the array of failed Remediation Tasks"
            $failedPolicyRemediationTask = [PSCustomObject]@{
                'Remediation Task Name' = $newPolicyRemediationTask.Name
                'Remediation Task Id'   = $newPolicyRemediationTask.Id
                'Policy Assignment Id'  = $newPolicyRemediationTask.PolicyAssignmentId
                'Provisioning State'    = $newPolicyRemediationTask.ProvisioningState
            }
            $failedPolicyRemediationTasks += $failedPolicyRemediationTask
        }
        else {
            Write-Output "`tThe Remediation Task has not succeeded or failed right away. Continuing to check the provisioning state until it changes to Succeeded or Failed"
            do {
                Start-Sleep -Seconds 60
                $existingPolicyRemediationTask = Get-AzPolicyRemediation -ResourceId $newPolicyRemediationTask.Id
                if ($existingPolicyRemediationTask.ProvisioningState -eq 'Succeeded') {
                    Write-Output "`tThe provisioning state of the Remediation Task has changed to Succeeded. Moving on to the next non-compliant Policy Definition"
                }
                elseif ($existingPolicyRemediationTask.ProvisioningState -eq 'Failed') {
                    Write-Output "`tThe provisioning state of the Remediation Task has changed to Failed. Adding it to the array of failed Remediation Tasks"
                    $failedPolicyRemediationTask = [PSCustomObject]@{
                        'Remediation Task Name' = $existingPolicyRemediationTask.Name
                        'Remediation Task Id'   = $existingPolicyRemediationTask.Id
                        'Policy Assignment Id'  = $existingPolicyRemediationTask.PolicyAssignmentId
                        'Provisioning State'    = $existingPolicyRemediationTask.ProvisioningState
                    }
                    $failedPolicyRemediationTasks += $failedPolicyRemediationTask
                    break
                }
                else {
                    Write-Output "`tThe provisioning state of the Remediation Task has not changed to Failed or Succeeded. Continuing to check the provisioning state"
                }
            } until ($existingPolicyRemediationTask.ProvisioningState -eq 'Succeeded')
        }
    }
    catch {
        Write-Error $_
    }
}
#endregion

#region When one or multiple Remediation Tasks failed, output the failedPolicyRemediationTasks for later use in the Azure DevOps Pipeline
if ($failedPolicyRemediationTasks.Count -ge 1) {
    Write-Output "`nUnfortunately, '$($failedPolicyRemediationTasks.Count)' Remediation Task(s) has/have failed. Outputting the failedPolicyRemediationTasksJsonString variable as for later use in the Azure DevOps Pipeline"
    $failedPolicyRemediationTasksJsonString = $failedPolicyRemediationTasks | ConvertTo-Json -Depth 10 -Compress
    Write-Output "##vso[task.setvariable variable=failedPolicyRemediationTasksJsonString;isOutput=true]$($failedPolicyRemediationTasksJsonString)"
    $createAzureDevOpsBug = $true
}
else {
    Write-Output "`nNo Remediation Tasks have failed. Ending the Azure DevOps Pipeline"
    $createAzureDevOpsBug = $false
}
Write-Output "##vso[task.setvariable variable=createAzureDevOpsBug;isOutput=true]$($createAzureDevOpsBug)"
#endregion