$62Conf = Get-Mailbox -RecipientTypeDetails RoomMailbox | where-object {$_.Name -like "*6-2*"}

$AllOtherConf = Get-Mailbox -RecipientTypeDetails RoomMailbox | where-object {$_.Name -notlike "*6-2*"}

$62Conf | foreach-object {set-calendarprocessing -identity $_ -AllBookInPolicy $false -BookinPolicy "DL-Endeavor-All"}

$62Conf | foreach-object {get-calendarprocessing -identity $_}

$AllOtherConf | foreach-object {set-calendarprocessing -identity $_ -AllBookInPolicy $false -BookinPolicy "DL-All"}