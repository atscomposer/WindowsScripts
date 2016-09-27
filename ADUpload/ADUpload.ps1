
###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 08-18-2015
# EDIT    : 
# COMMENT : This script updates AD User information based 
#           on a CSV file provided by HR.
# VERSION : 1.0
###########################################################

#----------------------------------------------------------
# Import AD Module
#----------------------------------------------------------
Import-Module ActiveDirectory

#----------------------------------------------------------
# Functions (Future Open File Dialog Box Feature)
#----------------------------------------------------------
<#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog
}

$computer = [Microsoft.VisualBasic.Interaction]::InputBox("Input the server where the CSV is hosted") 

$server='\\' + $computer


$inputfile = Get-filename $server
$filename = $inputfile.SafeFileName
$fullpath = $inputfile.FileName #>

#----------------------------------------------------------
# Script Variable (TO BE MODIFIED)
#----------------------------------------------------------
$fullpath = "\\hq-sccmfs-01\packages\Scripts\Adam's Scripts\ADUpload\AD Upload-April2016.csv"

#----------------------------------------------------------
# Script (DO NOT MODIFY BELOW)
#----------------------------------------------------------
$csv = Import-Csv $fullpath

# Get DNs of DL All Groups
$HQemp = (Get-ADGroup DL-Employees-HQ).DistinguishedName
$HQCont = (Get-ADGroup DL-Contractors-HQ).DistinguishedName
$HQIntern = (Get-ADGroup DL-Interns-HQ).DistinguishedName
$CAemp = (Get-ADGroup DL-Employees-CA-Pasadena).DistinguishedName
$CACont = (Get-ADGroup DL-Contractors-CA-Pasadena).DistinguishedName
$CAIntern = (Get-ADGroup DL-Interns-CA-Pasadena).DistinguishedName
$Remoteemp = (Get-ADGroup DL-Employees-Offsite).DistinguishedName
$RemoteCont = (Get-ADGroup DL-Contractors-Offsite).DistinguishedName
$RemoteIntern = (Get-ADGroup DL-Interns-Offsite).DistinguishedName
$UKemp = (Get-ADGroup DL-Employees-Europe).DistinguishedName
$UKCont = (Get-ADGroup DL-Contractors-Europe).DistinguishedName
$UKIntern = (Get-ADGroup DL-Interns-Europe).DistinguishedName
$Chinaemp = (Get-ADGroup DL-Employees-China).DistinguishedName
$ChinaCont = (Get-ADGroup DL-Contractors-China).DistinguishedName
$ChinaIntern = (Get-ADGroup DL-Interns-China).DistinguishedName
$HKemp = (Get-ADGroup DL-Employees-HongKong).DistinguishedName
$HKCont = (Get-ADGroup DL-Contractors-HongKong).DistinguishedName
$HKIntern = (Get-ADGroup DL-Interns-HongKong).DistinguishedName

foreach ($i in $csv){
    set-aduser $i.username -Department $i.department -Title $i.jobtitle -Manager $i.ManagerUsername -Office $i.location
    if (($i.EmploymentClassification -eq "Regular") -or ($i.EmploymentClassification -eq "Intern")){set-aduser $i.username -Company "iRobot Corporation"}

    if (($i.EmploymentClassification -eq "Regular") -and ($i.location -eq "US - Massachusetts")){Add-ADGroupMember -identity $HQemp -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Regular") -and ($i.location -eq "US - California")){Add-ADGroupMember -identity $CAemp -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Regular") -and (($i.location -eq "US - Remote") -or ($i.location -eq "Canada"))){Add-ADGroupMember -identity $Remoteemp -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Regular") -and ($i.location -eq "United Kingdom")){Add-ADGroupMember -identity $UKemp -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Regular") -and ($i.location -eq "China")){Add-ADGroupMember -identity $Chinaemp -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Regular") -and ($i.location -eq "Hong Kong")){Add-ADGroupMember -identity $HKemp -members $i.username -Confirm:$false}

    if (($i.EmploymentClassification -eq "Contractor") -and ($i.location -eq "US - Massachusetts")){Add-ADGroupMember -identity $HQCont -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Contractor") -and ($i.location -eq "US - California")){Add-ADGroupMember -identity $CACont -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Contractor") -and (($i.location -eq "US - Remote") -or ($i.location -eq "Canada"))){Add-ADGroupMember -identity $RemoteCont -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Contractor") -and ($i.location -eq "United Kingdom")){Add-ADGroupMember -identity $UKCont -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Contractor") -and ($i.location -eq "China")){Add-ADGroupMember -identity $ChinaCont -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Contractor") -and ($i.location -eq "Hong Kong")){Add-ADGroupMember -identity $ChinaIntern -members $i.username -Confirm:$false}

    if (($i.EmploymentClassification -eq "Intern") -and ($i.location -eq "US - Massachusetts")){Add-ADGroupMember -identity $HQIntern -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Intern") -and ($i.location -eq "US - California")){Add-ADGroupMember -identity $CAIntern -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Intern") -and (($i.location -eq "US - Remote") -or ($i.location -eq "Canada"))){Add-ADGroupMember -identity $RemoteIntern -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Intern") -and ($i.location -eq "United Kingdom")){Add-ADGroupMember -identity $UKIntern -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Intern") -and ($i.location -eq "China")){Add-ADGroupMember -identity $ChinaIntern -members $i.username -Confirm:$false}
    if (($i.EmploymentClassification -eq "Intern") -and ($i.location -eq "Hong Kong")){Add-ADGroupMember -identity $HKIntern -members $i.username -Confirm:$false}

    if ($i.USPerson -eq "No"){Add-ADGroupMember -identity "Non-US-Persons" -members $i.username -Confirm:$false}
} 