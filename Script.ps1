#Folders to be deleted
$tempPath = "D:\temp\"
$ProfilePath = "D:\PROFILE_WORK\Office\"

#temp file for MondayCounter 
$saveItem = "./Mondays.txt"

#Homedirectory of Script
$curDir = Get-Location

$FilePath = (Get-ChildItem $curDir | Where-Object { ($_.PSIsContainer -ne $true) -and ($_.Extension -eq ".ps1") }).FullName

#Checking for UserID because it is needed in TaskScheduler
$user = whoami

#Checking if MondayCounter Temp file exist and if not it will be created anf filled with "Monday: 0"
#and a task is created that executes the script every Monday at 10:00
if (!(Test-Path $saveItem)) {
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $FilePath
    $trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Monday -At 10am
    $principal = New-ScheduledTaskPrincipal -UserId $user
    $settings = New-ScheduledTaskSettingsSet -WakeToRun

    Register-ScheduledTask -TaskName "DirectoryCleanFaerberTo" -Action $action -Principal $principal -Trigger $trigger -Settings $settings
	
	if (Get-ScheduledTask "DirectoryCleanFaerberTo") {
		$output = ("Mondays: " + 0)
		$Output | Out-File -FilePath $saveItem
	}
}

#Get the current Monday count from the File
$variable = Get-Item -Path $saveItem | Select-String -Pattern "Mondays: "
$result = $variable -match "Mondays: (?<content>.*)"

[int]$FileContent = $matches['content']

#now that the script has its content we can add 1 to the count and save it
$FileContent = $FileContent + 1

$output = ("Mondays: " + $FileContent)
$Output | Out-File -FilePath $saveItem


#cheching if "D:\Temp" exist, if so it will be deleted and recreated    
If (Test-Path $tempPath) {
    Remove-Item $tempPath -Recurse
    New-Item -Path $tempPath -ItemType Directory
}
    
#if MondayCounter is equal to 4 the other Path ("D:\PROFILE_WORK\Office\") will be deleted and recreated
#also the counter will be reseted to 0
If($FileContent -eq "4") {
    If (Test-Path $ProfilePath) {
        Remove-Item $ProfilePath -Recurse
        New-Item $ProfilePath -ItemType Directory

        $output = ("Mondays: " + 0)
        $Output | Out-File -FilePath $saveItem
    }
}

Start-Sleep -Seconds 3