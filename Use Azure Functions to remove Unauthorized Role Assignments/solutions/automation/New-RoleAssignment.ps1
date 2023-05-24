<#
.SYNOPSIS
    This PowerShell script will create a Role Assignment for the System-assigned Managed Identity of the Function App.

.DESCRIPTION
    This PowerShell script will create a Role Assignment for the System-assigned Managed Identity of the Function App. As a result,
    the Function can execute its PowerShell code as it will have the right Role Assignment.
    - Input: the 'parameters.json' provides information on the names of the Azure services in scope

.PARAMETER SubscriptionId [String]
    The Id of the Subscription in which the Function App and its associated System-assigned Managed Identity are located.

.PARAMETER AutomationResourcesParameterFilePath [String]
    The path to the the 'parameters.json' provides information on the names of the Azure services in scope.

.PARAMETER Location [String]
    The location of the Function App and its associated System-assigned Managed Identity.

.PARAMETER RoleDefinitionName [String]
    The name of the Role Definition that needs to be assigned to the System-assigned Managed Identity.

.PARAMETER ManagementGroupName [String]
    The name of the Management Group on which the Role Definition needs to be assigned to the System-assigned Managed Identity.
#>

[CmdLetBinding()]
Param (
    [Parameter (Mandatory = $true)]
    [String] $SubscriptionId,

    [Parameter (Mandatory = $true)]
    [String] $AutomationResourcesParameterFilePath,

    [Parameter (Mandatory = $true)]
    [String] $Location,

    [Parameter (Mandatory = $true)]
    [String] $RoleDefinitionName,

    [Parameter (Mandatory = $true)]
    [String] $ManagementGroupName
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Set the Azure context to the right Subscription
Write-Output "`nSet the Azure context to the right Subscription"
Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
#endregion

#region Retrieve the content of the Automation Resources parameter file
Write-Output "`nRetrieve the content of the Automation Resources parameter file"
$automationResources = (Get-Content -Path $AutomationResourcesParameterFilePath -Raw | ConvertFrom-Json).parameters
#endregion

# region Define the names of the Azure services based on the naming convention
Write-Output "`nDefine the names of the Azure services based on the naming convention"
If ($Location -eq 'westeurope') {
    $locationAbbreviation = 'we'
    Write-Verbose "`tThe location abbreviation is set to '$($locationAbbreviation)'"
}
Else {
    $locationAbbreviation = 'ne'
    Write-Verbose "`tThe location abbreviation is set to '$($locationAbbreviation)'"
}

Write-Verbose "`tDefine the names of the Resource Group and Function App"
$resourceGroupName = "tech-community-blog-01-rg"
$functionAppName = "tech-community-blog-01-fa"
#endregion

# region Retrieve the Resource Group, Function App and System-assigned Managed Identity to see whether they exist
Write-Output "`nRetrieve the Resource Group, Function App and System-assigned Managed Identity to see whether they exist"
If ($resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -Location $Location) {
    Write-Verbose "`tThe '$($resourceGroup.ResourceGroupName)' Resource Group exists"
    If ($functionApp = Get-AzFunctionApp -ResourceGroupName $resourceGroup.ResourceGroupName -Name $functionAppName) {
        Write-Verbose "`tThe '$($functionApp.Name)' Function App exists"
        If ($functionApp.IdentityType -eq 'SystemAssigned') {
            $systemAssignedManagedIdentityObjectId = $functionApp.IdentityPrincipalId
            Write-Verbose "`tThe '$($functionApp.Name)' Function App has a System-assigned Managed Identity"
        }
        Else {
            Write-Error "The '$($functionApp.Name)' Function App does not have a System-assigned Managed Identity so the Role Assignment cannot be created"
        }
    }
    Else {
        Write-Error "The '$($functionAppName)' Function App does not exist so the Role Assignment cannot be created"
    }
}
Else {
    Write-Error "The '$($resourceGroupName)' Resource Group does not exist so the Role Assignment cannot be created"
}
#endregion

# region Check whether the Role Assignment exists for the System-assigned Managed Identity and create it when missing
Write-Output "`nCheck whether the Role Assignment exists for the System-assigned Managed Identity and create it when missing"
$managementGroup = Get-AzManagementGroup -GroupName $ManagementGroupName
If ($existingRoleAssignment = Get-AzRoleAssignment -ObjectId $systemAssignedManagedIdentityObjectId -RoleDefinitionName $RoleDefinitionName -Scope $managementGroup.Id) {
    Write-Output "`tThe System-assigned Managed Identity already has the '$($RoleDefinitionName)' Role Definition assigned on the '$($managementGroup.DisplayName)' Management Group"
}
Else {
    Write-Output "`tThe System-assigned Managed Identity does not have the '$($RoleDefinitionName)' Role Definition assigned on the '$($managementGroup.DisplayName)' Management Group"
    Try {
        New-AzRoleAssignment -ObjectId $systemAssignedManagedIdentityObjectId -RoleDefinitionName $RoleDefinitionName -Scope $managementGroup.Id | Out-Null
        Write-Output "`tThe '$($RoleDefinitionName)' Role Definition has been assigned on the '$($managementGroup.DisplayName)' Management Group"
    }
    Catch {
        Write-Error $_
    }
}
#endregion