<#
.Synopsis
   Service_WIM_Proper_way.ps1
.DESCRIPTION
    Created: 2018-12-10
    Version: 1.0

    Author : Pontus Wendt
    Homepage : https://clientstuff.blog

    Disclaimer: This script is provided "AS IS" with no warranties, confers no rights and
    is not supported by the author.
.EXAMPLE
    NA
#>

#Import Modules
Import-Module ConfigurationManager

set-location "C:Program Files (x86)Microsoft Configuration ManagerAdminConsole\bin" import-module .ConfigurationManager.psd1
	
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)

#Set som variables to match your env

#write the name of the month you want to service, make sure this match you folder that you created.
$Month = "Nov"

#Specify the name of the new wim file.
$WimName = "W10-1803-$Month.wim"

#Path to the folder structure you created, in my example C:\WIM-Servicing
$Path =  "C:\WIM-Servicing"

#Path to the destination folder, where your others Wim files are,
$DestinationPath = "\\CM01\Sourcefiles\Images"

#path to the Mountpath, while servicing the wim file will the image be mounted by dism, so we need an empty folder.
$MountedPath = "C:\MountWim"

#Create mount folder
New-Item -ItemType Directory -Path $MountedPath -ErrorAction SilentlyContinue

#Copy the "original wim file"
Copy-Item "$Path\install.wim" -Destination "$Path\$Month\install.wim" -ErrorAction Silentlycontinue

#Take me to the service wim location
Set-location $Path

#Service the wim file & copying it to the new location
.\Service_WIM.ps1 -SourceImage "$Path\$Month\install.wim" -MountDir $MountedPath -DestinationImage $DestinationPath -WinVersion "Windows 10 Enterprise"

#change location
Set-Location P01:


#Import Operating system image
New-CMOperatingSystemImage -Name $WimName -Path "D:\Service_WIM\"

#Configure WIM file to match our env
Set-CMOperatingSystemImage -Name $WimName -EnableBinaryDeltaReplication $true -CopyToPackageShareOnDistributionPoint $true

#Done
