$cred = Get-Credential -Message 'Enter Domain\Username and Password'
$pwd = $cred.Password
$user = $cred.UserName
$key = 1..32 | ForEach-Object { Get-Random -Maximum 256 }
$pwdencrypted = $pwd | ConvertFrom-SecureString -Key $key

$private:ofs = ' '

$generatedScript = @()
$generatedScript += '$password = ''{0}''' -f $pwdencrypted
$generatedScript += '$key = ''{0}''' -f "$key"

$generatedScript += '$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split('' ''))' 
$generatedScript += '$cred = New-Object system.Management.Automation.PSCredential(''{0}'', $passwordSecure)' -f $user
$generatedScript += '$cred' 

$file = $psise.CurrentPowerShellTab.Files.Add()
$file.Editor.Text = $generatedScript | Out-String
$file.Editor.SetCaretPosition(1,1)