$schema =[DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
## I'm looking for user attributes and the property I'm looking for is an optional attribute
## The rangeUpper attribute is what tells us the max length of what can go into that particular attribute
$schema.FindClass('user').optionalproperties | select name,rangeupper | where {$_.rangeupper -ne $null} | fl
