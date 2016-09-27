###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 07-20-2015
# EDIT    : 
# COMMENT : This script creates new Active Directory users,
#           including different kind of properties, based
#           on an AD, OU-based query.
# VERSION : 2.0
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
$path     = "\\HQ-SCCMFS-01\Packages\Scripts\Change\create_ad_users"
$log      = $path + "\create_ad_users_v2.log"
$date     = Get-Date
$addn     = (Get-ADDomain).DistinguishedName
$dnsroot  = (Get-ADDomain).DNSRoot
$i        = 1
$TestOUs   = "ou=Service_Desk,ou=IT,ou=*IT Use Only - Internal,ou=iRobot Users,dc=wardrobe,dc=irobot,dc=com","ou=Test - Marc,ou=IT,ou=*IT Use Only - Internal,ou=iRobot Users,dc=wardrobe,dc=irobot,dc=com"
$ous      = "ou=**Employees,ou=iRobot Users,dc=wardrobe,dc=irobot,dc=com","ou=**Contractors,ou=iRobot Users,dc=wardrobe,dc=irobot,dc=com","ou=**Interns,ou=iRobot Users,dc=wardrobe,dc=irobot,dc=com"
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
 $TestOUs | ForEach { Get-ADUser -Filter * -SearchBase $_ } | ForEach-Object {
      If (($_.givenName -eq "") -Or ($_.surname -eq ""))
      {
        Write-Host "[ERROR]`t Please provide valid GivenName, LastName and Initials. Processing skipped for line $($i)`r`n"
        "[ERROR]`t Please provide valid GivenName, LastName and Initials. Processing skipped for line $($i)`r`n" | Out-File $log -append
      }
      Else
      {
        # Set the target OU
        $location = "OU=Install_Accounts,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"

        # Create sAMAccountName according to this 'naming convention':
        # "<FirstLettergivenName><LastName>_install" for example
        # ashuttleworth_install

        $sam = $_.sAMAccountName.ToLower()

        If ($sam.length -lt 12){
                $numberx = $sam.length
            }
        Else {$numberx = 12}
        
        $sam12 = $sam.Substring( 0, $numberx)
        $samfinal = $sam12 + "_install"
        $exists = Get-ADUser -LDAPFilter "(sAMAccountName=$samfinal)"
        If(!$exists)
        {
          # Set all variables according to the table names in the Excel 
          # sheet / import CSV. The names can differ in every project, but 
          # if the names change, make sure to change it below as well.

          Try
          {
            Write-Host "[INFO]`t Creating user : $($samfinal)"
            "[INFO]`t Creating user : $($samfinal)" | Out-File $log -append
            New-ADUser $samfinal -GivenName $_.givenName `
            -Surname $_.surname -DisplayName ($_.givenName + " " + $_.surname + " Install") `
            -Description $_.Description -UserPrincipalName ($samfinal + "@" + $dnsroot) `
            -Department $_.Department
            Write-Host "[INFO]`t Created new user : $($samfinal)"
            "[INFO]`t Created new user : $($samfinal)" | Out-File $log -append
     
            $dn = (Get-ADUser $samfinal).DistinguishedName
       
            # Move the user to the OU ($location) you set above. If you don't
            # want to move the user(s) and just create them in the global Users
            # OU, comment the string below
            If ([adsi]::Exists("LDAP://$($location)"))
            {
              Move-ADObject -Identity $dn -TargetPath $location
              Write-Host "[INFO]`t User $samfinal moved to target OU : $($location)"
              "[INFO]`t User $samfinal moved to target OU : $($location)" | Out-File $log -append
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
            $newdn = (Get-ADUser $samfinal).DistinguishedName
            Rename-ADObject -Identity $newdn -NewName ($_.surname + ", " + $_.givenName + " Install")
            Write-Host "[INFO]`t Renamed $($samfinal) to $($_.givenName) $($_.surname) `r`n"
            "[INFO]`t Renamed $($samfinal) to $($_.givenName) $($_.surname)`r`n" | Out-File $log -append
          }
          Catch
          {
            Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n"
          }
        }
        Else
        {
          Write-Host "[SKIP]`t User $($samfinal) ($($_.givenName) $($_.surname)) already exists or returned an error!`r`n"
          "[SKIP]`t User $($samfinal) ($($_.givenName) $($_.surname)) already exists or returned an error!'r'n" | Out-File $log -append
        }
      }
    }
    $i++

  "--------------------------------------------" + "`r`n" | Out-File $log -append
}

Write-Host "STARTED SCRIPT`r`n"
Start-Commands
Write-Host "STOPPED SCRIPT"