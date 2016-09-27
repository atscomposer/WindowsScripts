###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 08-01-2016
# EDIT    : 08-01-2016
# COMMENT : MS Online License Verification for E4 licenses
# VERSION : 1.0
###########################################################

#Import modules required for the script to run
Import-Module MsOnline
Import-Module ActiveDirectory

#Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword

#Connect to Office 365
Connect-MsolService -Credential $CloudCred

#######################################################
#Script Variables
$Licenses = @{

                 'E4_iRobot' = @{
                          LicenseSKU = 'irbt:ENTERPRISEWITHSCAL'
                          Group = 'DL-All'
                        }
                 'E4_Endeavor' = @{
                          LicenseSKU = 'irbt:ENTERPRISEWITHSCAL'
                          Group = 'DL-Endeavor-All'
                        }
            }
$UsageLocation = 'US'
$date = get-Date -UFormat "%Y-%m-%d"
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Logfile = ($PSScriptRoot + "\MSOL-UserActivation_$date.log")

#Functions
Function LogWrite
{
Param ([string]$Logstring)
Add-Content $Logfile -value $logstring -ErrorAction Stop
Write-Host $logstring
}

#######################################################
#Start logging and check logfile access
try
{
	LogWrite -Logstring "**************************************************`r`nLicense activation job started at $(Get-date)`r`n**************************************************"
}
catch
{
	Throw "You don't have write permissions to $logfile, please start an elevated PowerShell prompt or change NTFS permissions"
}

#Find all license info, users in corresponding group and their UserPrincipalNames
foreach ($license in $Licenses.Keys){
    $GroupName = $Licenses[$license].Group
    $ADGroupMembers = (Get-ADGroupMember -Identity $GroupName -Recursive).SamAccountName
    $GroupMembers = $ADGroupMembers | Get-ADUser | where {$_.userprincipalName -ne $null -and $_.Enabled -ne $FALSE}
    $AccountSKU = Get-MsolAccountSku | Where-Object {$_.AccountSKUID -eq $Licenses[$license].LicenseSKU}

    #All MSOLUsers
    $AllUsers = $GroupMembers | ForEach-Object {Get-MsolUser -UserPrincipalName $_.UserPrincipalName}

   }

    #######################################################
    #Find all completely Unlicensed Users in O365
    $UnlicensedUsers = $AllUsers | Where-Object {$_.isLicensed -eq $FALSE}

    if ($AccountSKU.ActiveUnits - $AccountSKU.consumedunits -lt $UnlicensedUsers.Count) {
            LogWrite 'ERROR: Not enough licenses for all users, please remove user licenses or buy more licenses. Script will be stopped'
            Exit
            }

    #Remediate Completely Unlicensed Users
    $UnlicensedUsers | ForEach-Object {
        Try {
        Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation $UsageLocation -ErrorAction Stop -WarningAction Stop
        Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -AddLicenses $AccountSKU.AccountSkuId -ErrorAction Stop -WarningAction Stop
        LogWrite "Successfully licensed $_.UserPrincipalName with $Licenses[$license].LicenseSKUs"
        } catch {
        LogWrite "ERROR: Error when licensing $_.UserPrincipalName`r`n$_"
        }
    }

    #######################################################
    #Find all licensed users that are not licensed for OfficePro, Skype, OfficeWeb, and Exchange Online sub-licenses
    $AllLicensedUsers = $AllUsers | where-object {$_.Licenses.AccountSkuID -eq $AccountSKU.AccountSkuId}
    $UserLicensed = Foreach ($User in $AllLicensedUsers) {
        $License=[array]::indexof($User.Licenses.AccountSKUID,$AccountSKU.AccountSkuId)
        $User | Select-Object DisplayName, UserPrincipalName, <#@{Name="Planner";Expression={$_.Licenses[$license].ServiceStatus[0].ProvisioningStatus}}, @{Name="Sway";Expression={$_.Licenses[$license].ServiceStatus[1].ProvisioningStatus}}, @{Name="MDM";Expression={$_.Licenses[$license].ServiceStatus[2].ProvisioningStatus}}, @{Name="Yammer";Expression={$_.Licenses[$license].ServiceStatus[3].ProvisioningStatus}}, @{Name="AD_RMS";Expression={$_.Licenses[$license].ServiceStatus[4].ProvisioningStatus}}, @{Name="Skype(Plan3)";Expression={$_.Licenses[$license].ServiceStatus[5].ProvisioningStatus}},#> @{Name="OfficePro";Expression={$_.Licenses[$license].ServiceStatus[6].ProvisioningStatus}},<# @{Name="Skype(Plan2)";Expression={$_.Licenses[$license].ServiceStatus[7].ProvisioningStatus}},#> @{Name="OfficeWeb";Expression={$_.Licenses[$license].ServiceStatus[8].ProvisioningStatus}}, @{Name="SharePoint";Expression={$_.Licenses[$license].ServiceStatus[9].ProvisioningStatus}}, @{Name="Exchange";Expression={$_.Licenses[$license].ServiceStatus[10].ProvisioningStatus}}
    }
    $PartiallyUnlicensedUsers = $UserLicensed | where-object {<#$_.Planner -ne "Success" -or $_.Sway -ne "Success" -or $_.MDM -ne "Success" -or $_.Yammer -ne "Success" -or $_.AD_RMS -ne "Success" -or #> $_.OfficePro -ne "Success" <#-or $_.Skype -ne "Success"#> -or $_.OfficeWeb -ne "Success" -or $_.SharePoint -ne "Success" -or $_.Exchange -ne "Success" }

    #Remediate Partially Unlicensed Users
    $PartiallyUnlicensedUsers | ForEach-Object {
        Try {
        Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -RemoveLicenses $AccountSKU.AccountSkuId
        LogWrite "Successfully removed $($_.UserPrincipalName) from $Licenses[$license].LicenseSKU"
        Set-MsolUserLicense -UserPrincipalName $($_.UserPrincipalName) -AddLicenses $AccountSKU.AccountSkuId -ErrorAction Stop -WarningAction Stop
        LogWrite "Successfully licensed $($_.UserPrincipalName) with $Licenses[$license].LicenseSKU"
        } catch {
        LogWrite "ERROR: Error when licensing $($_.UserPrincipalName)`r`n$_"
        }
    }
}

LogWrite -Logstring "**************************************************`r`nLicense activation job completed at $(Get-date)`r`n**************************************************"

#######################################################
