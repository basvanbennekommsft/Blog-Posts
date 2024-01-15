<#
.SYNOPSIS
    This PowerShell script creates table-level Role Assignments on one or more Log Analytics workspaces, based on the input
    of the 'parameters.json' file.

.DESCRIPTION
    This PowerShell script creates table-level Role Assignments on one or more Log Analytics workspaces, based on the input
    of the 'parameters.json' file. Before creating the Role Assignments, the PowerShell script checks whether the input is
    valid. Subsequently, it checks which Role Assignments do not exist. Based on this information, the missing Role Assignments
    are created.

.PARAMETER logAnalyticsTableRolesFilePath [string]
    The path to the file in which the Log Analytics table-level Role Assignments are located.

  .EXAMPLE
  Create-AzureDevOpsBug.ps1 `
    -logAnalyticsTableRolesFilePath '<File path to the parameters.json file>'

  .INPUTS
  None.

  .OUTPUTS
  None.
#>

[CmdLetBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [String]$logAnalyticsTableRolesFilePath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Retrieve the input from the 'parameters.json' file
Write-Output "`nRetrieve the input from the '$($logAnalyticsTableRolesFilePath.Split('/')[-1])' file"
$logAnalyticsTableRoles = Get-Content -Path $logAnalyticsTableRolesFilePath -Raw | ConvertFrom-Json
#endregion

#region Conduct different checks before creating the table-level Role Assignments
Write-Output "`nConduct different checks before creating the table-level Role Assignments"
$logAnalyticsWorkspaces = $logAnalyticsTableRoles.logAnalyticsWorkspaces
$requiredRoleAssignments = @()

foreach ($logAnalyticsWorkspace in $logAnalyticsWorkspaces) {
    Set-AzContext -Subscription $logAnalyticsWorkspace.subscriptionName -Force | Out-Null

    # Check whether the Log Analytics workspaces exist
    Write-Verbose "`n`tCheck whether the '$($logAnalyticsWorkspace.name)' Log Analytics workspace exists"
    if ($existinglogAnalyticsWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $logAnalyticsWorkspace.resourceGroupName -Name $logAnalyticsWorkspace.name -ErrorAction SilentlyContinue) {
        Write-Verbose "`tThe '$($existinglogAnalyticsWorkspace.Name)' Log Analytics workspace does exist"
    }
    else {
        Write-Error "The '$($logAnalyticsWorkspace.name)' Log Analytics workspace does not exist so the PowerShell script is terminated"
    }

    $tableRoles = $logAnalyticsWorkspace.tableRoles
    foreach ($tableRole in $tableRoles) {
        # Check whether the identities exist
        Write-Verbose "`n`tCheck whether the '$($tableRole.identity.name)' $($tableRole.identity.type) exists"
        if ($tableRole.identity.type -eq 'User') {
            if ($existingUser = Get-AzADUser -ObjectId $tableRole.identity.objectId -ErrorAction SilentlyContinue) {
                Write-Verbose "`tThe '$($existingUser.UserPrincipalName)' $($tableRole.identity.type) does exist"
            }
            else {
                Write-Error "The '$($tableRole.identity.name)' $($tableRole.identity.type) does not exist so the PowerShell script is terminated"
            }
        }
        elseif ($tableRole.identity.type -eq 'Group') {
            if ($existingGroup = Get-AzADGroup -ObjectId $tableRole.identity.objectId -ErrorAction SilentlyContinue) {
                Write-Verbose "`tThe '$($existingGroup.DisplayName)' $($tableRole.identity.type) does exist"
            }
            else {
                Write-Error "The '$($tableRole.identity.name)' $($tableRole.identity.type) does not exist so the PowerShell script is terminated"
            }
        }
        elseif ($tableRole.identity.type -eq 'Service Principal') {
            if ($existingServicePrincipal = Get-AzADServicePrincipal -ObjectId $tableRole.identity.objectId -ErrorAction SilentlyContinue) {
                Write-Verbose "`tThe '$($existingServicePrincipal.DisplayName)' $($tableRole.identity.type) does exist"
            }
            else {
                Write-Error "The '$($tableRole.identity.name)' $($tableRole.identity.type) does not exist so the PowerShell script is terminated"
            }
        }
        else {
            Write-Error "The '$($tableRole.identity.type)' type is not supported so the PowerShell script is terminated"
        }

        # Check whether the tables exist
        $existinglogAnalyticsWorkspaceTables = (Get-AzOperationalInsightsTable -ResourceGroupName $existinglogAnalyticsWorkspace.ResourceGroupName -WorkspaceName $existinglogAnalyticsWorkspace.Name).Name
        $targetlogAnalyticsWorkspaceTables = $tableRole.tables
        foreach ($targetlogAnalyticsWorkspaceTable in $targetlogAnalyticsWorkspaceTables) {
            Write-Verbose "`n`tCheck whether the '$($targetlogAnalyticsWorkspaceTable)' table exists in the '$($existinglogAnalyticsWorkspace.Name)' Log Analytics workspace"
            if ($targetlogAnalyticsWorkspaceTable -in $existinglogAnalyticsWorkspaceTables) {
                Write-Verbose "`tThe '$($targetlogAnalyticsWorkspaceTable)' table does exist in the '$($existinglogAnalyticsWorkspace.Name)' Log Analytics workspace"
                $requiredRoleAssignment = [PSCustomObject]@{
                    ObjectId         = $tableRole.identity.objectId
                    Scope            = "$($existinglogAnalyticsWorkspace.ResourceId)/tables/$($targetlogAnalyticsWorkspaceTable)"
                    RoleDefinitionId = $tableRole.roleDefinition.Id
                }
                $requiredRoleAssignments += $requiredRoleAssignment
            }
            else {
                Write-Error "The '$($targetlogAnalyticsWorkspaceTable)' table does not exist in the '$($existinglogAnalyticsWorkspace.Name)' Log Analytics workspace so the PowerShell script is terminated"
            }
        }
    }
}

#region Check what table-level Role Assignments already exist
Write-Output "`nCheck what table-level Role Assignments already exist"
$toBeCreatedRoleAssignments = @()
foreach ($requiredRoleAssignment in $requiredRoleAssignments) {
    Write-Verbose "`n`tCheck whether the identity with objectId '$($requiredRoleAssignment.ObjectId)' has the Role Definition with id '$($requiredRoleAssignment.RoleDefinitionId)' assigned on the '$($requiredRoleAssignment.Scope.Split('/')[-1])' table"
    if ($null -eq (Get-AzRoleAssignment -ObjectId $requiredRoleAssignment.ObjectId -Scope $requiredRoleAssignment.Scope -RoleDefinitionId $requiredRoleAssignment.RoleDefinitionId -ErrorAction SilentlyContinue)) {
        Write-Verbose "`tThe Role Assignment does not exist and thus needs to be created"
        $toBeCreatedRoleAssignments += $requiredRoleAssignment
    }
    else {
        Write-Verbose "`tThe Role Assignment already exists"
    }
}
Write-Output "Out of the '$($requiredRoleAssignments.Count)' required Role Assignments, '$($toBeCreatedRoleAssignments.Count)' Role Assignment(s) do(es) not exist"
#endregion

#region Create the table-level Role Assignments that are required
if ($toBeCreatedRoleAssignments.Count -ne 0) {
    Write-Output "`nCreate the new table-level Role Assignments"
    foreach ($toBeCreatedRoleAssignment in $toBeCreatedRoleAssignments) {
        Write-Verbose "`n`tAdd the Role Definition with id '$($toBeCreatedRoleAssignment.RoleDefinitionId)' to the identity with objectId '$($toBeCreatedRoleAssignment.ObjectId)' on the '$($toBeCreatedRoleAssignment.Scope.Split('/')[-1])' table"
        try {
            New-AzRoleAssignment -ObjectId $toBeCreatedRoleAssignment.ObjectId -Scope $toBeCreatedRoleAssignment.Scope -RoleDefinitionId $toBeCreatedRoleAssignment.RoleDefinitionId | Out-Null
            Write-Verbose "`tCreated the new table-level Role Assignment"
        }
        catch {
            Write-Error "Failed to create the new table-level Role Assignment. Error: '$($Error)'"
        }
    }
    Write-Output "Successfully created the new table-level Role Assignments"
}
else {
    Write-Output "`nEnd the PowerShell script since '$($toBeCreatedRoleAssignments.Count)' new Role Assignments need to be created"
}
#endregion