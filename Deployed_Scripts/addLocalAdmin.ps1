$computername = $env:computername
$username = 'IRBT'

$computer = [ADSI]"WinNT://$computername,computer"

$encrypted = “01000000d08c9ddf0115d1118c7a00c04fc297eb010000002″
$password = ConvertTo-SecureString -string $encrypted
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password

##$password = 'topSecret@99'
$desc = 'Automatically created local admin account'
$user = $computer.Create($cred)
$group = [ADSI]("WinNT://$computername/administrators,group")

$colUsers = ($objComputer.psbase.children |
    Where-Object {$_.psBase.schemaClassName -eq "User"} |
        Select-Object -expand Name)

$blnFound = $colUsers -contains $username

if ($blnFound)
    {"The user account exists."}
else
    {
$user.SetPassword($password)
$user.Setinfo()
$user.description = $desc
$user.setinfo()
$group.add("WinNT://$username,user")

}

$members = net localgroup administrators | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4
$adminusers = $true

if (!($members -contains $username))
{ 
$adminusers = $false
break;
}

write-host $adminusers