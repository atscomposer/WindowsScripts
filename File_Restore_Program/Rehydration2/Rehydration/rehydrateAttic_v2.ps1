###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 01-22-2016
# EDIT    : 01-22-2016
# COMMENT : Rehydrate archived files of File Server Attic
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

# Code allowing user to select server the archived file currently lives

#----------------------------------------------------------
# IMPORT AlphaFS MODULE AND CALL FUNCTIONS
#----------------------------------------------------------
Import-Module -Name "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\AlphaFS.2.0.1\lib\net451\AlphaFS.dll"

Function Invoke-GenericMethod {
    Param(
        $Instance,
        [String]$MethodName,
        [Type[]]$TypeParameters,
        [Object[]]$MethodParameters
    )

    [Collections.ArrayList]$Private:parameterTypes = @{}
    ForEach ($Private:paramType In $MethodParameters) { [Void]$parameterTypes.Add($paramType.GetType()) }

    $Private:method = $Instance.GetMethod($methodName, "Instance,Static,Public", $Null, $parameterTypes, $Null)

    If ($Null -eq $method) { Throw ('Method: [{0}] not found.' -f ($Instance.ToString() + '.' + $methodName)) }
    Else {
        $method = $method.MakeGenericMethod($TypeParameters)
        $method.Invoke($Instance, $MethodParameters)
    }
}

Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog
}


#----------------------------------------------------------
# Allow user to browse to select server and file that needs to be restored
#----------------------------------------------------------

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select a Computer"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objListBox.SelectedItem;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "File Server to Restore to:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80

[void] $objListBox.Items.Add("Attic")
[void] $objListBox.Items.Add("Caseyjones")
[void] $objListBox.Items.Add("hq-nas-01")

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$server='\\' + $objListBox.SelectedItem


$inputfile = Get-filename $server
$filename = $inputfile.SafeFileName
$fullPath = $inputfile.FileName
$dir = $fullPath | Split-Path

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------

        <# $path = "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\Restores\$($args[1])\"
        $logSuccess     = $path + "HQ-NAS-01_Copy_Success_$($args[1]).log"
        $logError       = $path + "HQ-NAS-01_Copy_Error_$($args[1]).log"
        $logRestore     = $path + "HQ-NAS-01_Copy_Restore_$($args[1]).log" #>

        if ($server -like '*Attic'){
            $AtticRestorePath = $dir -replace [Regex]::Escape("\\attic") , '\\hq-cifs-01\Attic-Restore'
            $restoredFilePath = $FullPath -replace [Regex]::Escape("\\attic") , '\\hq-cifs-01\Attic-Restore'
            $newFileName = $FileName + ".moved"
            $movedfileRename = $AtticRestorePath + "\" + $newFileName
            }
        if ($server -like '*hq-nas-01'){
            $AtticRestorePath = $dir -replace [Regex]::Escape("\\hq-nas-01") , '\\hq-cifs-01\Attic-Restore'
            $restoredFileFullPath = $FullPath -replace [Regex]::Escape("\\hq-nas-01") , '\\hq-cifs-01\Attic-Restore'
            $newFileName = $FileName + ".moved"
            $movedfileRename = $AtticRestorePath + "\" + $newFileName
            }
        if ($server -like '*caseyjones'){
            $AtticRestorePath = $dir -replace [Regex]::Escape("\\") , '\\hq-cifs-01\Attic-Restore\'
            $restoredFilePath = $FullPath -replace [Regex]::Escape("\\") , '\\hq-cifs-01\Attic-Restore\'
            $newFileName = $FileName + ".moved"
            $movedfileRename = $AtticRestorePath + "\" + $newFileName
            }
            $startDate = Get-Date
            if (Test-Path $AtticRestorePath){
                Write-host "STARTED on $StartDate :"
                Write-host "--------------------------------------------"
                Write-host "$(get-date): [SUCCESS]`t $($FullPath) exists and will be copied."

                Robocopy $AtticRestorePath $dir $FileName /V /FP /NP /DCOPY:T /COPYALL /R:0 /W:0 /MT:50
                    ## Check if file restore was successful
                    ## 
                    if ((gci $fullPath).length -ne "0"){
                        ## Rename file in Restore Directory
                        ##
                        Rename-Item -path $restoredFilePath -newname $newFileName 
                            ## Check to see if file rename was successful
                            ##
                            if (Test-Path $movedfileRename) {
                                ## Output to Success Log
                                ##
                                Write-Host "$(get-date): [SUCCESS]`t $($FullPath) filename has been changed in the restore directory"
                                $endDateSuccess = Get-Date
                                Write-Host "ENDED $endDateSuccess"
                                Write-Host "--------------------------------------------"
                            }## End of if statement
                            else {
                                $restoreErrorDate = Get-Date
                                Write-host "--------------------------------------------"
                                Write-host "$($restoreErrorDate): [ERROR]`t $($FullPath) filename was NOT changed correctly"
                                Write-host "--------------------------------------------"
                                ## Output pointer in Success Log stating the restore process was not successful
                                ##
                                Write-host "--------------------------------------------"
                                Write-host "$($restoreErrorDate): [ERROR]`t Rename process has errored at $($FullPath)"
                                Write-host "--------------------------------------------"
                            }## End of else statement
                    }## End of if statement
                    else {
                        ## Output to Error Log Error Message
                        ##
                        $restoreErrorDate = Get-Date
                        Write-host "--------------------------------------------"
                        "$($restoreErrorDate): [ERROR]'t $($FullPath) was NOT successfully restored."
                        Write-host "--------------------------------------------"
                        ## Output pointer in Success Log stating the restore process was not successful
                        ##
                        Write-host "--------------------------------------------"
                        Write-host "$($restoreErrorDate): [ERROR]`t Restore process has errored at $($FullPath)"
                        Write-host "--------------------------------------------"
                    }## End of else statement
                }## End of if statement
            else {
                $ErrorDate = Get-Date
                Write-host "--------------------------------------------"
                Write-host "$($ErrorDate): [ERROR]`t $($FullPath) does NOT exist on the Recovered drive."
                Write-host "--------------------------------------------"
                ## Output pointer in Success Log stating the restore process was not successful
                ##
                Write-host "--------------------------------------------"
                Write-host "$($ErrorDate): [ERROR]`t Restore process has errored at $($FullPath). File does not exist."
                Write-host "--------------------------------------------"
                } 

Read-host "Press Enter to exit..."
exit