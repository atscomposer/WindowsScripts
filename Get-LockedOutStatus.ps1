﻿#Requires -Version 2.0
Function Get-LockedOutStatus
{
<#
.SYNOPSIS
	This function will locate the computer that processed a failed user logon attempt which caused the user account to become locked out.

.DESCRIPTION
	This function will locate the computer that processed a failed user logon attempt which caused the user account to become locked out. 
	The locked out location is found by querying the PDC Emulator for locked out events (4740).  
	The function will display the BadPasswordTime attribute on all of the domain controllers to add in further troubleshooting.

.EXAMPLE
	PS C:\>Get-LockedOutLocation -Identity Joe.Davis


	This example will find the locked out location for Joe Davis.
.NOTE
	This function is only compatible with an environment where the domain controller with the PDCe role to be running Windows Server 2008 SP2 and up.  
	The script is also dependent the ActiveDirectory PowerShell module, which requires the AD Web services to be running on at least one domain controller.
	Author:Jason Walker
	Last Modified: 3/20/2013
#>
    [CmdletBinding()]

    Param(
      [Parameter(Mandatory=$True)]
      [String]$Identity      
    )

    Begin
    { 
        $DCCounter = 0 
        $LockedOutStats = @()   
                
        Try
        {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        Catch
        {
           Write-Warning $_
           Break
        }
    }#end begin
    Process
    {
        
        #Get all domain controllers in domain
        $DomainControllers = Get-ADDomainController -Filter *
        $PDCEmulator = ($DomainControllers | Where-Object {$_.OperationMasterRoles -contains "PDCEmulator"})
        
        Write-Verbose "Finding the domain controllers in the domain"
        Foreach($DC in $DomainControllers)
        {
            $DCCounter++
            Write-Progress -Activity "Contacting DCs for lockout info" -Status "Querying $($DC.Hostname)" -PercentComplete (($DCCounter/$DomainControllers.Count) * 100)
            Try
            {
                $UserInfo = Get-ADUser -Identity $Identity  -Server $DC.Hostname -Properties AccountLockoutTime,LastBadPasswordAttempt,BadPwdCount,LockedOut -ErrorAction Stop
            }
            Catch
            {
                Write-Warning $_
                Continue
            }
            If($UserInfo.LastBadPasswordAttempt)
            {    
                $LockedOutStats += New-Object -TypeName PSObject -Property @{
                        Name                   = $UserInfo.SamAccountName
                        SID                    = $UserInfo.SID.Value
                        LockedOut              = $UserInfo.LockedOut
                        BadPwdCount            = $UserInfo.BadPwdCount
                        BadPasswordTime        = $UserInfo.BadPasswordTime            
                        DomainController       = $DC.Hostname
                        AccountLockoutTime     = $UserInfo.AccountLockoutTime
                        LastBadPasswordAttempt = ($UserInfo.LastBadPasswordAttempt).ToLocalTime()
                    }          
            }#end if
        }#end foreach DCs
        $LockedOutStats | Format-Table -Property Name,LockedOut,DomainController,BadPwdCount,AccountLockoutTime,LastBadPasswordAttempt -AutoSize
       
    }#end process
   
}#end functionS

#Search specific OUs (remove <##> to use)
$OUs =  "OU=Service Accounts,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com","OU=Service Accounts,OU=Unmanaged,DC=Wardrobe,DC=irobot,DC=com","OU=ADMIN,DC=Wardrobe,DC=irobot,DC=com"
$lockedOutUsers = $OUs | ForEach-Object {Search-ADAccount -SearchBase $_ -LockedOut}
$lockedOutUsers | ForEach-Object {Get-LockedOutStatus -Identity $_.SamAccountName}

#Search All Wardrobe Domain Users
$lockedUsers = Search-ADAccount -SearchBase "DC=wardrobe,DC=irobot,DC=com" -LockedOut
$lockedUsers | ForEach-Object {Get-LockedOutStatus -Identity $_.SamAccountName}