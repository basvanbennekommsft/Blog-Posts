using namespace System.Net

# Input bindings are passed in via param block
param($Request, $TriggerMetadata)

# Set the default PowerShell configuration
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Retrieve the properties of the Alert
Write-Output "Retrieve the properties of the Alert"
$alert = $Request.Body.data
$roleAssignmentResourceIds = $alert.essentials.alertTargetIDs

ForEach ($roleAssignmentResourceId in $roleAssignmentResourceIds) {
    Write-Output "The Id of the Role Assignment is '$($roleAssignmentResourceId)'"

    # Retrieve the properties of the Role Assignment
    Write-Output "Retrieve the properties of the Role Assignment"
    Try {
        $accessToken = Get-AzAccessToken
        $uri = ('https://management.azure.com{0}?api-version=2022-04-01' -f $roleAssignmentResourceId)
        $headers = @{
            'Accept'        = 'application/json'
            'x-ms-version'  = '2014-06-01'
            'Authorization' = "Bearer $($accessToken.Token)"
            "Content-Type"  = 'application/json'
        }
        $roleAssignment = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
        Write-Output "Succesfully retrieved the properties of the Role Assignment"
    }
    Catch {
        Write-Warning "The Role Assignment with Id '$($roleAssignmentResourceId)' cannot be found so it must have been removed already"
        Return
    }

    # Remove the Role Assignment if it exists
    If ($roleAssignment) {
        Write-Output "The Role Assignment exists and thus needs to be removed"
        Try {
            $params = @{
                'ObjectId'         = $roleAssignment.properties.principalId
                'RoleDefinitionId' = $roleAssignment.properties.roleDefinitionId.Split('/')[-1]
                'Scope'            = $roleAssignment.properties.scope
            }
            Remove-AzRoleAssignment @params | Out-Null
            Write-Output "Succesfully removed the Role Assignment"
        }
        Catch {
            Write-Error $_
        }
    }
    Else {
        Write-Output "The Role Assignment does not exist and thus cannot be removed"
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
    }
)