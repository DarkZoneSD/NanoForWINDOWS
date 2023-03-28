#Prompt the user if he agrees with the installation
function Get-SomeInput
{
	Write-Host "[" -NoNewline; Write-Host "y" -f Green -NoNewline; Write-Host "/" -NoNewline; Write-Host "n" -f Red -NoNewline; Write-Host "]" -NoNewline
	$input = read-host "This Programm will need to install 7Zip, press y if you agree (Or have it already installed). Press n if you wish to exit"
	
	switch ($input) `
	{
		'y' {
			Get-SomeOtherInput
		}
		
		'n' {
			Return
		}
		
		default {
			write-host 'You may only answer y or n, please try again.'
			Get-SomeInput
		}
	}
}
#Prompt the user if he wants to install 7Zip for Powershell
function Get-SomeOtherInput
{
	Write-Host "[" -NoNewline; Write-Host "y" -f Green -NoNewline; Write-Host "/" -NoNewline; Write-Host "n" -f Red -NoNewline; Write-Host "]" -NoNewline
	$input = read-host "Do you want to install 7Zip for Powershell? (Press n if you have it already installed)"
	
	switch ($input) `
	{
		'y' {
			Install-7Zip
		}
		
		'n' {
			EverythingElse
		}
		
		default {
			write-host 'You may only answer y or n, please try again.'
			Get-SomeOtherInput
		}
	}
}
#Installs Nano - Gets called if User Input == n in the last prompt. 
#Gets called by teh Install7Zip Function if the User Input == y 
function EverythingElse
{
	Invoke-WebRequest -Uri "https://files.lhmouse.com/nano-win/nano-win_10172_v7.2-17-g587c85c4e.7z" -OutFile "$env:TEMP\nano-win10172.7z"
	$sourcefile = "$env:TEMP\nano-win10172.7z"
	Expand-7Zip -ArchiveFileName $sourcefile -TargetPath "$env:TEMP\nano-win10172"
	
	Invoke-WebRequest -Uri "https://github.com/scopatz/nanorc/archive/refs/heads/master.zip" -OutFile "$env:TEMP\nanorc.zip"
	$sourcefile = "$env:TEMP\nanorc.zip"
	Expand-7Zip -ArchiveFileName $sourcefile -TargetPath "$env:TEMP\nanorc"
	
	(mkdir C:\nano) -and (mkdir C:\nano\bin) -and (mkdir C:\nano\nanorc) -and (mkdir C:\nano\doc)
	$sharePath = "$env:TEMP\nano-win10172\pkg_i686-w64-mingw32\share"
	
	Copy-Item "$env:TEMP\nano-win10172\pkg_i686-w64-mingw32\bin\nano.exe" "C:\nano\bin\nano.exe"
	Copy-Item "$env:TEMP\nanorc\nanorc-master\*.nanorc" "C:\nano\nanorc\" -Exclude gitcommit.nanorc, html.j2.nanorc, twig.nanorc, zshrc.nanorc
	Copy-Item "$sharePath\doc\nano\*.html" "C:\nano\doc\"
	Copy-Item "$sharePath\nano\*.nanorc" "C:\nano\nanorc\" -Force
	Copy-Item "$sharePath\nano\extra\*.nanorc" "C:\nano\nanorc\" -Force
	Copy-Item "$env:TEMP\nano-win10172\.nanorc" "$env:USERPROFILE\.nanorc"
	
	Add-Content -Path $env:USERPROFILE\.nanorc "include ""/nano/nanorc/*.nanorc"" "
	
	[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";C:\nano\bin", "Machine")
	# Link last cursor position files:
	New-Item -ItemType SymbolicLink -Path "C:\ProgramData\.local\share\nano\filepos_history" -Target "$env:USERPROFILE\.local\share\nano\filepos_history" -Force
	# Link .nanorc files:
	New-Item -ItemType SymbolicLink -Path "C:\ProgramData\.nanorc" -Target "$env:USERPROFILE\.nanorc" -Force
}

function Install-7Zip
{
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
	Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
	Install-Module -Name 7Zip4PowerShell -Force
	
	EverythingElse
}
Get-SomeInput
Return
