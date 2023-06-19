@echo off

:loop
timeout /t 1 > nul
tasklist /fi "windowtitle eq PUMPER" |find "cmd.exe" >nul && goto :loop

title PUMPER

powershell "New-BurntToastNotification -AppLogo '%userprofile%\Documents\WindowsPowerShell\modules\BurntToast\logo.png' -Text 'Social Rate Pumper', 'Stage #3 - Lets go to Amazon!'"

pushd "%~dp0" 
taskkill /f /im msedge.exe > nul 2>&1
powershell -File run_AZ.ps1
taskkill /f /im msedgedriver.exe > nul 2>&1
taskkill /f /im msedge.exe > nul 2>&1
popd

powershell "New-BurntToastNotification -AppLogo '%userprofile%\Documents\WindowsPowerShell\modules\BurntToast\logo.png' -Text 'Social Rate Pumper', 'Stage #3 Finished!'"
powershell "New-BurntToastNotification -AppLogo '%userprofile%\Documents\WindowsPowerShell\modules\BurntToast\logo.png' -Text 'Social Rate Pumper', 'That's enough for Amazon. You can start work.'"