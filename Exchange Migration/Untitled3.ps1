#2016-01-07 - Updated the script with a new function to support nested groups.
#Import Required PowerShell Modules
#Note - the Script Requires PowerShell 3.0!
Import-Module MSOnline

#Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword

#Connect to Office 365
Connect-MsolService -Credential $CloudCred
function Get-JDMsolGroupMember {
    param(
        [CmdletBinding(SupportsShouldProcess=$true)]
        [Parameter(Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [ValidateScript({Get-MsolGroup -ObjectId $_})]
        $ObjectId,
        [switch]$Recursive
    )
    begin {
        $MSOLAccountSku = Get-MsolAccountSku -ErrorAction Ignore -WarningAction Ignore
        if (-not($MSOLAccountSku)) {
            throw "Not connected to Azure AD, run Connect-MsolService"
        }
    }
    process {
        $UserMembers = Get-MsolGroupMember -GroupObjectId $objectID -MemberObjectTypes User -All
        if ($PSBoundParameters['Recursive']) {
            $Groups = Get-MsolGroupMember -GroupObjectId $objectID -MemberObjectTypes Group -All
            $Groups | ForEach-Object -Process {
                $UserMembers = " "
                $UserMembers += Get-JDMsolGroupMember -Recursive -ObjectId $_.ObjectId
            }
        }
        Write-Output ($UserMembers | Sort-Object -Property EmailAddress -Unique)

    }
    end {

    }
}


$Licenses = @{

                 'E4' = @{
                          LicenseSKU = 'irbt:ENTERPRISEWITHSCAL'
                          Group = 'DL-All'
                        }
            }
$UsageLocation = 'US'

foreach ($license in $Licenses.Keys) {

    $GroupName = $Licenses[$license].Group
    $GroupID = (Get-MsolGroup -All | Where-Object {$_.DisplayName -eq $GroupName}).ObjectId
    $AccountSKU = Get-MsolAccountSku | Where-Object {$_.AccountSKUID -eq $Licenses[$license].LicenseSKU}

    Write-Output "Checking for unlicensed $license users in group $GroupName with ObjectGuid $GroupID..."

    $GroupMembers = (Get-JDMsolGroupMember -ObjectId $GroupID -Recursive | Where-Object {$_.IsLicensed -eq $true}).EmailAddress

    if ($AccountSKU.ActiveUnits - $AccountSKU.consumedunits -lt $GroupMembers.Count) {
        Write-Warning 'Not enough licenses for all users, please remove user licenses or buy more licenses'
      }

        foreach ($User in $GroupMembers) {
          Try {
            Set-MsolUser -UserPrincipalName $User -UsageLocation $UsageLocation -ErrorAction Stop -WarningAction Stop
            Set-MsolUserLicense -UserPrincipalName $User -AddLicenses $AccountSKU.AccountSkuId -ErrorAction Stop -WarningAction Stop
            Write-Output "Successfully licensed $User with $license"
          } catch {
            Write-Warning "Error when licensing $User`r`n$_"
          }

        }

}
