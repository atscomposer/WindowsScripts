###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 05-28-2015
# EDIT    : 
# COMMENT : This script creates new Active Directory users,
#           including different kind of properties, based
#           on an input_create_ad_users.csv.
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOAD ASSEMBLIES AND MODULES
#----------------------------------------------------------
Try
{
  Import-Module ActiveDirectory -ErrorAction Stop
}
Catch
{
  Write-Host "[ERROR]`t ActiveDirectory Module couldn't be loaded. Script will stop!"
  Exit 1
}

#----------------------------------------------------------
#STATIC VARIABLES
#----------------------------------------------------------
$path     = "\\psf\Home\Downloads\create_ad_users"
$newpath  = $path + "\Test1.csv"
$log      = $path + "\create_ad_users.log"
$date     = Get-Date
$addn     = (Get-ADDomain).DistinguishedName
$dnsroot  = (Get-ADDomain).DNSRoot
$i        = 1

#----------------------------------------------------------
#START FUNCTIONS
#----------------------------------------------------------
Function Start-Commands
{
  Create-Users
}

Function Create-Users
{
  "Processing started (on " + $date + "): " | Out-File $log -append
  "--------------------------------------------" | Out-File $log -append
  Import-CSV $newpath | ForEach-Object {
      If (($_.givenName -eq "") -Or ($_.sn -eq ""))
      {
        Write-Host "[ERROR]`t Please provide valid GivenName, LastName and Initials. Processing skipped for line $($i)`r`n"
        "[ERROR]`t Please provide valid GivenName, LastName and Initials. Processing skipped for line $($i)`r`n" | Out-File $log -append
      }
      Else
      {
        # Set the target OU
        $location = "OU=Test,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"

        # Create sAMAccountName according to this 'naming convention':
        # "<FirstLettergivenName><LastName>_install" for example
        # ashuttleworth_install
        $sam = $_.sAMAccountName.ToLower()
        $exists = Get-ADUser -LDAPFilter "(sAMAccountName=$sam)"
        If(!$exists)
        {
          # Set all variables according to the table names in the Excel 
          # sheet / import CSV. The names can differ in every project, but 
          # if the names change, make sure to change it below as well.

          Try
          {
            Write-Host "[INFO]`t Creating user : $($sam)"
            "[INFO]`t Creating user : $($sam)" | Out-File $log -append
            New-ADUser $sam -GivenName $_.givenName `
            -Surname $_.sn -DisplayName ($_.givenName + " " + $_.sn) `
            -Description $_.Description -UserPrincipalName ($sam + "@" + $dnsroot) `
            -Department $_.Department
            Write-Host "[INFO]`t Created new user : $($sam)"
            "[INFO]`t Created new user : $($sam)" | Out-File $log -append
     
            $dn = (Get-ADUser $sam).DistinguishedName
       
            # Move the user to the OU ($location) you set above. If you don't
            # want to move the user(s) and just create them in the global Users
            # OU, comment the string below
            If ([adsi]::Exists("LDAP://$($location)"))
            {
              Move-ADObject -Identity $dn -TargetPath $location
              Write-Host "[INFO]`t User $sam moved to target OU : $($location)"
              "[INFO]`t User $sam moved to target OU : $($location)" | Out-File $log -append
            }
            Else
            {
              Write-Host "[ERROR]`t Targeted OU couldn't be found. Newly created user wasn't moved!"
              "[ERROR]`t Targeted OU couldn't be found. Newly created user wasn't moved!" | Out-File $log -append
            }
       
            # Rename the object to a good looking name (otherwise you see
            # the 'ugly' shortened sAMAccountNames as a name in AD. This
            # can't be set right away (as sAMAccountName) due to the 20
            # character restriction
            $newdn = (Get-ADUser $sam).DistinguishedName
            Rename-ADObject -Identity $newdn -NewName ($_.sn + ", " + $_.givenName + " Install")
            Write-Host "[INFO]`t Renamed $($sam) to $($_.givenName) $($_.sn) `r`n"
            "[INFO]`t Renamed $($sam) to $($_.givenName) $($_.sn)`r`n" | Out-File $log -append
          }
          Catch
          {
            Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n"
          }
        }
        Else
        {
          Write-Host "[SKIP]`t User $($sam) ($($_.givenName) $($_.sn)) already exists or returned an error!`r`n"
          "[SKIP]`t User $($sam) ($($_.givenName) $($_.sn)) already exists or returned an error!" | Out-File $log -append
        }
      }
    }
    $i++

  "--------------------------------------------" + "`r`n" | Out-File $log -append
}

Write-Host "STARTED SCRIPT`r`n"
Start-Commands
Write-Host "STOPPED SCRIPT"