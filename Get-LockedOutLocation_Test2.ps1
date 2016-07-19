#Requires -Version 2.0
Function Get-LockedOutLocation
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

        #$PrimaryDC = Get-ADDomainController -Filter {HostName -like "HQ-DCW-03.*"}
        $DCs = Get-ADDomainController -Filter {HostName -like "HQ-DCW-*"}
        $Startdate = (Get-Date).AddHours(-1)
        $Enddate = Get-Date

        #Get User Info
        foreach ($DC in $DCs){
        Try
        {  
           Write-Verbose "Querying event log on $($DC.HostName)"
           #$LockOutEvents = Get-WinEvent -ComputerName $DC.HostName -FilterHashtable @{LogName='Security';Id=4740} -ErrorAction Stop | Sort-Object -Property TimeCreated -Descending
           #$filteredEvents = $LockOutEvents | Where-Object {$_.TimeCreated -gt $Startdate}
           $LockOutEvents = Get-EventLog -ComputerName $DC.HostName -LogName Security -After $Enddate -Before $Startdate | Where-Object {$_.EventID -eq 4740}
        }
        Catch 
        {          
           Write-Warning $_
           Continue
        }#end catch     
        }                         
        Foreach($Event in $FilteredEvents)
        {            
                $Event | Select-Object -Property @(
                @{Label = 'User';               Expression = {$_.Properties[0].Value}}
                @{Label = 'DomainController';   Expression = {$_.MachineName}}
                @{Label = 'EventId';            Expression = {$_.Id}}
                @{Label = 'LockedOutTimeStamp'; Expression = {$_.TimeCreated}}
                @{Label = 'Message';            Expression = {$_.Message -split "`r" | Select -First 1}}
                @{Label = 'LockedOutLocation';  Expression = {$_.Properties[1].Value}}
              )
            
       }#end foreach lockedout event
       
    }#end process
   
}#end function

#Search specific OUs (remove <##> to use)
$OUs =  "OU=Service Accounts,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com","OU=Service Accounts,OU=Unmanaged,DC=Wardrobe,DC=irobot,DC=com","OU=ADMIN,DC=Wardrobe,DC=irobot,DC=com"
$lockedOutUsers = $OUs | ForEach-Object {Search-ADAccount -SearchBase $_ -LockedOut}
$lockedOutUsers | ForEach-Object {Get-LockedOutLocation -Identity $_.SamAccountName}


#Search All Wardrobe Domain Users
#$lockedUsers = Search-ADAccount -SearchBase "DC=wardrobe,DC=irobot,DC=com" -LockedOut
#$lockedUsers | ForEach-Object {Get-LockedOutLocation -Identity $_.SamAccountName}
