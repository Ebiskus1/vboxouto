@echo off
rem $Id: win_postinstall.cmd $
rem rem @file
rem Post installation script template for Windows.
rem
rem This runs after the target system has been booted, typically as
rem part of the first logon.
rem

rem
rem Copyright (C) 2017-2022 Oracle and/or its affiliates.
rem
rem This file is part of VirtualBox base platform packages, as
rem available from https://www.virtualbox.org.
rem
rem This program is free software; you can redistribute it and/or
rem modify it under the terms of the GNU General Public License
rem as published by the Free Software Foundation, in version 3 of the
rem License.
rem
rem This program is distributed in the hope that it will be useful, but
rem WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
rem General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with this program; if not, see <https://www.gnu.org/licenses>.
rem
rem SPDX-License-Identifier: GPL-3.0-only
rem

rem Globals.
set MY_LOG_FILE=nul

rem Log header.
echo *** started >> %MY_LOG_FILE%
echo *** CD=%CD% >> %MY_LOG_FILE%
echo *** Environment BEGIN >> %MY_LOG_FILE%
set >> %MY_LOG_FILE%
echo *** Environment END >> %MY_LOG_FILE%




rem
rem Install the guest additions.
rem

rem First find the CDROM with the GAs on them.
set MY_VBOX_ADDITIONS=E:\vboxadditions
if exist %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe goto found_vbox_additions
set MY_VBOX_ADDITIONS=D:\vboxadditions
if exist %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe goto found_vbox_additions
set MY_VBOX_ADDITIONS=F:\vboxadditions
if exist %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe goto found_vbox_additions
set MY_VBOX_ADDITIONS=G:\vboxadditions
if exist %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe goto found_vbox_additions
set MY_VBOX_ADDITIONS=E:
if exist %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe goto found_vbox_additions
set MY_VBOX_ADDITIONS=F:
if exist %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe goto found_vbox_additions
set MY_VBOX_ADDITIONS=G:
if exist %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe goto found_vbox_additions
set MY_VBOX_ADDITIONS=D:
if exist %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe goto found_vbox_additions
set MY_VBOX_ADDITIONS=E:\vboxadditions
:found_vbox_additions
echo *** MY_VBOX_ADDITIONS=%MY_VBOX_ADDITIONS%\ >> %MY_LOG_FILE%

rem Then add signing certificate to trusted publishers
echo *** Running: %MY_VBOX_ADDITIONS%\cert\VBoxCertUtil.exe ... >> %MY_LOG_FILE%
%MY_VBOX_ADDITIONS%\cert\VBoxCertUtil.exe add-trusted-publisher %MY_VBOX_ADDITIONS%\cert\vbox*.cer --root %MY_VBOX_ADDITIONS%\cert\vbox*.cer >> %MY_LOG_FILE% 2>&1
echo *** ERRORLEVEL: %ERRORLEVEL% >> %MY_LOG_FILE%

rem Then do the installation.
echo *** Running: %MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe /S >> %MY_LOG_FILE%
%MY_VBOX_ADDITIONS%\AntidetectWindowsAdditions.exe /S
echo *** ERRORLEVEL: %ERRORLEVEL% >> %MY_LOG_FILE%








rem
rem Run user command.
rem
echo *** Running custom user command ... >> %MY_LOG_FILE%
title PLEASE DON'T CLOSE THIS WINDOW & type %MY_VBOX_ADDITIONS%\ascii.art & net accounts /maxpwage:unlimited > nul & powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0 & powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0 & explorer %MY_VBOX_ADDITIONS%\etc\qres\qres.cmd & powershell "Set-ExecutionPolicy Bypass -Force" & echo. & reg.exe add HKLM\Software\Policies\Microsoft\Windows\OneDrive /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f > nul
setx /m MESA_GL_VERSION_OVERRIDE 4.6>nul & setx /m MESA_GLES_VERSION_OVERRIDE 3.1>nul & setx /m MESA_GLSL_VERSION_OVERRIDE 460>nul & setx /m ANTIDETECT_RENDERER "NVIDIA GeForce GTX 1080 (ASUS)">nul & xcopy /e /y /i %MY_VBOX_ADDITIONS%\etc\BurntToast "%userprofile%\Documents\WindowsPowerShell\modules\BurntToast" > nul & timeout 2 > nul & pushd %MY_VBOX_ADDITIONS%\etc\Fonts & powershell -encodedCommand QQBkAGQALQBUAHkAcABlACAALQBBAHMAcwBlAG0AYgBsAHkATgBhAG0AZQAgAFMAeQBzAHQAZQBtAC4ARAByAGEAdwBpAG4AZwANAAoARgBvAHIARQBhAGMAaAAoACQAZgBvAG4AdABkAGkAcgAgAGkAbgAgAEcAZQB0AC0AQwBoAGkAbABkAEkAdABlAG0AIAAtAEQAaQByAGUAYwB0AG8AcgB5ACkADQAKAHsADQAKACAAIAAgACAAJABmAG8AbgB0AHMAIAA9ACAARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQAgAC0AUABhAHQAaAAgACIAJABmAG8AbgB0AGQAaQByAFwAKgAiACAALQBJAG4AYwBsAHUAZABlACAAJwAqAC4AdAB0AGYAJwAsACcAKgAuAG8AdABmACcAIAB8ACAAUwBvAHIAdAAtAE8AYgBqAGUAYwB0ACAAewBHAGUAdAAtAFIAYQBuAGQAbwBtAH0AIAB8ACAAUwBlAGwAZQBjAHQAIAAtAEYAaQByAHMAdAAgACgARwBlAHQALQBSAGEAbgBkAG8AbQAgACAALQBNAGkAbgAgADEAMAAgAC0ATQBhAHgAIAAyADAAKQANAAoAIAAgACAAIABGAG8AcgBFAGEAYwBoACgAJABmAG8AbgB0AGYAaQBsAGUAIABpAG4AIAAkAGYAbwBuAHQAcwApAA0ACgAgACAAIAAgAHsADQAKACAAIAAgACAAIAAgACAAIAAkAGYAbwBuAHQAQwBvAGwAIAA9ACAAWwBTAHkAcwB0AGUAbQAuAEQAcgBhAHcAaQBuAGcALgBUAGUAeAB0AC4AUAByAGkAdgBhAHQAZQBGAG8AbgB0AEMAbwBsAGwAZQBjAHQAaQBvAG4AXQA6ADoAbgBlAHcAKAApAA0ACgAgACAAIAAgACAAIAAgACAAJABmAG8AbgB0AEMAbwBsAC4AQQBkAGQARgBvAG4AdABGAGkAbABlACgAJABmAG8AbgB0AGYAaQBsAGUAKQANAAoAIAAgACAAIAAgACAAIAAgACQAZgBvAG4AdABuAGEAbQBlACAAPQAgAFsAUwB0AHIAaQBuAGcAWwBdAF0AJABmAG8AbgB0AEMAbwBsAC4ARgBhAG0AaQBsAGkAZQBzAC4ATgBhAG0AZQANAAoAIAAgACAAIAAgACAAIAAgACQAZgBvAG4AdABDAG8AbAAuAEQAaQBzAHAAbwBzAGUAKAApAA0ACgAgACAAIAAgACAAIAAgACAAaQBmACgAJABmAG8AbgB0AG4AYQBtAGUAKQANAAoAIAAgACAAIAAgACAAIAAgAHsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAkAGYAbwBuAHQAZgBpAGwAZQAyACAAPQAgACQAZgBvAG4AdABmAGkAbABlAC4ATgBhAG0AZQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACQAYwBtAGQAcwB0AHIAIAA9ACAAIgBjAG8AcAB5ACAALwB5ACAAIgAiACQAZgBvAG4AdABmAGkAbABlACIAIgAgACUAVwBJAE4ARABJAFIAJQBcAEYAbwBuAHQAcwAgAD4AIABuAHUAbAAgADIAPgAmADEAIAAmACYAIAByAGUAZwAgAGEAZABkACAAIgAiAEgASwBMAE0AXABTAE8ARgBUAFcAQQBSAEUAXABNAGkAYwByAG8AcwBvAGYAdABcAFcAaQBuAGQAbwB3AHMAIABOAFQAXABDAHUAcgByAGUAbgB0AFYAZQByAHMAaQBvAG4AXABGAG8AbgB0AHMAIgAiACAALwB2ACAAIgAiACQAZgBvAG4AdABuAGEAbQBlACAAKABUAHIAdQBlAFQAeQBwAGUAKQAiACIAIAAvAHQAIABSAEUARwBfAFMAWgAgAC8AZAAgACIAIgAkAGYAbwBuAHQAZgBpAGwAZQAyACIAIgAgAC8AZgAgAD4AIABuAHUAbAAiAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAJABjAG0AZABzAHQAcgAgAHwAIABjAG0AZAANAAoAIAAgACAAIAAgACAAIAAgAH0ADQAKACAAIAAgACAAfQANAAoAfQANAAoA > nul & popd
pushd %MY_VBOX_ADDITIONS%\etc\Fonts && cd Glyphs && powershell -encodedCommand JABmAG8AbgB0AHMAIAA9ACAAQAAoACkAOwAgAEYAbwByAEUAYQBjAGgAKAAkAGYAbwBuAHQAZABpAHIAIABpAG4AIABHAGUAdAAtAEMAaABpAGwAZABJAHQAZQBtACAALQBEAGkAcgBlAGMAdABvAHIAeQApACAAewAgACQAZgBvAG4AdABzACAAKwA9ACAARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQAgAC0AUABhAHQAaAAgACIAJABmAG8AbgB0AGQAaQByAFwAKgAiACAAfAAgACUAewAkAF8ALgBGAHUAbABsAE4AYQBtAGUAfQAgAH0ADQAKACQAZgBvAG4AdABzACAAPQAgACQAZgBvAG4AdABzACAAfAAgAFMAbwByAHQALQBPAGIAagBlAGMAdAAgAHsARwBlAHQALQBSAGEAbgBkAG8AbQB9ACAAfAAgAFMAZQBsAGUAYwB0ACAALQBGAGkAcgBzAHQAIAAoAEcAZQB0AC0AUgBhAG4AZABvAG0AIAAgAC0ATQBpAG4AIAAwACAALQBNAGEAeAAgACgAJABmAG8AbgB0AHMALgBMAGUAbgBnAHQAaAArADEAKQApAA0ACgBGAG8AcgBFAGEAYwBoACgAJABmAG8AbgB0ACAAaQBuACAAJABmAG8AbgB0AHMAKQAgAHsAIAAkAGYAbwBuAHQAZgBpAGwAZQAgAD0AIABTAHAAbABpAHQALQBQAGEAdABoACAAJABmAG8AbgB0ACAALQBsAGUAYQBmADsAIAAkAGMAbQBkAHMAdAByACAAPQAgACIAdABhAGsAZQBvAHcAbgAgAC8ARgAgACIAIgAlAHcAaQBuAGQAaQByACUAXABGAG8AbgB0AHMAXAAkAGYAbwBuAHQAZgBpAGwAZQAiACIAIAA+ACAAbgB1AGwAIAAyAD4AJgAxACAAJgAmACAAaQBjAGEAYwBsAHMAIAAiACIAJQB3AGkAbgBkAGkAcgAlAFwARgBvAG4AdABzAFwAJABmAG8AbgB0AGYAaQBsAGUAIgAiACAALwBnAHIAYQBuAHQAIAAlAHUAcwBlAHIAbgBhAG0AZQAlADoARgAgAD4AIABuAHUAbAAgADIAPgAmADEAIAAmACYAIABjAG8AcAB5ACAALwB5ACAAIgAiACQAZgBvAG4AdAAiACIAIAAlAHcAaQBuAGQAaQByACUAXABGAG8AbgB0AHMAXAAgAD4AIABuAHUAbAAgADIAPgAmADEAIgA7ACAAJABjAG0AZABzAHQAcgAgAHwAIABjAG0AZAAgAH0A > nul & popd
%MY_VBOX_ADDITIONS%\etc\SoundVolumeView\SoundVolumeView.exe /SetDefaultFormat "Speakers" 16 88200 2
reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v InstallDate /t REG_DWORD /d 1658704234 /f > nul
reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v InstallTime /t REG_QWORD /d 133031778340000000 /f > nul
powershell -File %MY_VBOX_ADDITIONS%\etc\network_test.ps1 & netsh advfirewall firewall add rule name="IPv6 protocol 41" action=block protocol=41 dir=out > nul & netsh advfirewall firewall add rule name="IPv6 protocol 43" action=block protocol=43 dir=out > nul & netsh advfirewall firewall add rule name="IPv6 protocol 44" action=block protocol=44 dir=out > nul & netsh advfirewall firewall add rule name="IPv6 protocol 58" action=block protocol=58 dir=out > nul & netsh advfirewall firewall add rule name="IPv6 protocol 59" action=block protocol=59 dir=out > nul & netsh advfirewall firewall add rule name="IPv6 protocol 60" action=block protocol=60 dir=out > nul & netsh advfirewall firewall add rule name="IPv6 protocol 41" action=block protocol=41 dir=in > nul & netsh advfirewall firewall add rule name="IPv6 protocol 43" action=block protocol=43 dir=in > nul & netsh advfirewall firewall add rule name="IPv6 protocol 44" action=block protocol=44 dir=in > nul & netsh advfirewall firewall add rule name="IPv6 protocol 58" action=block protocol=58 dir=in > nul & netsh advfirewall firewall add rule name="IPv6 protocol 59" action=block protocol=59 dir=in > nul & netsh advfirewall firewall add rule name="IPv6 protocol 60" action=block protocol=60 dir=in > nul & powershell "New-BurntToastNotification -AppLogo '%userprofile%\Documents\WindowsPowerShell\modules\BurntToast\logo2.png' -Text 'Antidetect 4', 'IPv6 leak Blocked'" & timeout 5 > nul
%MY_VBOX_ADDITIONS%\etc\wub\wub.exe /D /P & powershell "New-BurntToastNotification -AppLogo '%userprofile%\Documents\WindowsPowerShell\modules\BurntToast\logo2.png' -Text 'Antidetect 4', 'Windows Update Disabled'" & timeout 5 > nul
netsh advfirewall firewall add rule name="DNS-QUIC UDP Block" protocol=udp localport=80,443,484,563,843,9443,9898,9909,9912,29232,44394 remoteport=80,443,484,563,843,9443,9898,9909,9912,29232,44394 dir=out action=block > nul & netsh advfirewall firewall add rule name="DNS-QUIC TCP Block" protocol=tcp localport=80,443,484,563,843,9443,9898,9909,9912,29232,44394 remoteport=80,443,484,563,843,9443,9898,9909,9912,29232,44394 dir=out action=block > nul & netsh advfirewall firewall add rule name="DNS-QUIC UDP Block" protocol=udp localport=80,443,484,563,843,9443,9898,9909,9912,29232,44394 remoteport=80,443,484,563,843,9443,9898,9909,9912,29232,44394 dir=in action=block > nul & netsh advfirewall firewall add rule name="DNS-QUIC TCP Block" protocol=tcp localport=80,443,484,563,843,9443,9898,9909,9912,29232,44394 remoteport=80,443,484,563,843,9443,9898,9909,9912,29232,44394 dir=in action=block > nul & powershell "New-BurntToastNotification -AppLogo '%userprofile%\Documents\WindowsPowerShell\modules\BurntToast\logo2.png' -Text 'Antidetect 4', 'DNS over QUIC Leak Blocked'" & timeout 5 > nul
type %MY_VBOX_ADDITIONS%\etc\akamai.txt >> %windir%\system32\drivers\etc\hosts & powershell "New-BurntToastNotification -AppLogo '%userprofile%\Documents\WindowsPowerShell\modules\BurntToast\logo2.png' -Text 'Antidetect 4', 'Akamai Blocked'" & timeout 1 > nul
net stop lmhosts > nul & timeout 5 > nul & net stop netbt > nul & timeout 5 > nul & sc config netbt start= disabled > nul & sc config lmhosts start= disabled > nul & powershell "New-BurntToastNotification -AppLogo '%userprofile%\Documents\WindowsPowerShell\modules\BurntToast\logo2.png' -Text 'Antidetect 4', 'NetBios Leak Blocked'" & timeout 5 > nul
xcopy /e /y /i %MY_VBOX_ADDITIONS%\Tools\tun2socks "%userprofile%\Desktop\tun2socks" > nul & timeout 2 > nul
pushd "%userprofile%\Desktop\tun2socks"
del /f /q start.bat > nul
>>start.bat echo @echo off&&>>start.bat echo pushd "%%~dp0"
>>start.bat echo tun2socks.exe --dns-addresses=62.217.61.161 --product-mode=no --proxyserver=212.83.138.192 --proxyport=33497 --proxyuser= --proxypassword=
>>start.bat echo popd
start "" start.bat
popd
echo Waiting for tun2socks to start...
:loop
timeout /t 1 > nul
tasklist /v /fi "imagename eq cmd.exe" |find "VEthernet (tun2socks@" >nul && goto :exitloop
goto :loop
:exitloop
echo Waiting for tun2socks to connect...
timeout 10 > nul
echo Installing BgInfo... & copy /y %MY_VBOX_ADDITIONS%\etc\BGinfo\Bginfo64.exe %windir%\ > nul & copy /y %MY_VBOX_ADDITIONS%\etc\BGinfo\bginfo-config.bgi %windir%\ > nul & powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\Bginfo64.lnk');$s.TargetPath='Bginfo64.exe';$s.Arguments='/nolicprompt bginfo-config.bgi /timer:0';$s.WorkingDirectory='%windir%';$s.Save()" & cd %windir% && Bginfo64.exe /nolicprompt bginfo-config.bgi /timer:0 & pushd %tmp% && echo Installing Chrome and randomizing Client IDs... && powershell "$ProgressPreference = 'SilentlyContinue'; $uri = 'https://dl.google.com/tag/s/appguid%%3D%%7B8A69D345-D564-463C-AFF1-A69D9E530F96%%7D%%26iid%%3D%%7B' + [guid]::NewGuid().ToString().ToUpper() + '%%7D%%26lang%%3Den%%26browser%%3D4%%26usagestats%%3D0%%26appname%%3DGoogle%%2520Chrome%%26needsadmin%%3Dprefers%%26ap%%3Dx64-stable-statsdef_1%%26installdataindex%%3Dempty/chrome/install/ChromeStandaloneSetup64.exe'; $ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36 Edg/111.0.1661.41'; $res = Invoke-WebRequest -UseBasicParsing -Method Head -useragent $ua -uri $uri; $StatusCode = $res.StatusCode; if ($StatusCode -eq 200) { Write-Host -NoNewLine Downloading installer ($res.Headers['Content-Length']/1024.0/1024.0).ToString('#.##')  MB... }; Invoke-WebRequest -useragent $ua -uri $uri -OutFile chrome_installer.exe; Write-Host '    OK'" && start "Installing Chrome" /wait chrome_installer.exe /silent /install && powershell "$ins = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate; $ins += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion; $ins | ?{ $_.DisplayName -match 'chrome' } | Foreach-Object { Write-Host 'Installed',$_.DisplayName,'version',$_.DisplayVersion }"
popd
echo Setting Chrome as default browser... &%MY_VBOX_ADDITIONS%\etc\SetDefaultBrowser\SetDefaultBrowser.exe HKLM "Google Chrome" & powershell "$lnk = (New-Object -ComObject Wscript.Shell).CreateShortcut([Environment]::GetFolderPath('CommonDesktopDirectory') + '\Google Chrome.lnk'); $lnk.Arguments='--force-disable-variation-ids --reset-variation-state'; $lnk.Save()" & echo Installing random Chrome extensions... & reg add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" /v "1" /t REG_SZ /d "gighmmpiobklfepjocnamgkkbiglidom" /f > nul
reg add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" /v "2" /t REG_SZ /d "chhjbpecpncaggjpdakmflnfcopglcmi" /f > nul
reg add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" /v "3" /t REG_SZ /d "hgmhmanijnjhaffoampdlllchpolkdnj" /f > nul
reg add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" /v "4" /t REG_SZ /d "ailcmbgekjpnablpdkmaaccecekgdhlh" /f > nul
powershell "Get-WmiObject Win32_Volume -Filter 'DriveType=5' | select -exp DriveLetter | foreach-object { (New-Object -comObject Shell.Application).Namespace(17).ParseName($_).InvokeVerb('Eject') }" & exit


echo *** done >> %MY_LOG_FILE%
