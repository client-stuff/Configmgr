#This script att Variables to a bunch of computers in a collection

#Author : Pontus Wendt
#Homepage : https://Clientstuff.blog

# Site configuration
$SiteCode = "PS1" # Site code 
$ProviderMachineName = "CM01.corp.viamonstra.com" # SMS Provider machine name

# Import the ConfigurationManager.psd1 module 
if($null -eq (Get-Module ConfigurationManager)) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
# Connect to the site's drive if it is not already present
if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams


#Variables
$CollectionName = "Poppes Company"

#The variable value that you know
$City = "Stockholm"
#The variables you want to add
$SpecificLocation = "Kista"
$HouseName= "House201"

#CSV Path
$Path = "C:\Script\$Collectionname.csv"


#Gathering all the computers inside a collection to a variable
$computer = Get-CmCollectionMember -CollectionName $CollectionName | Select-Object Name
$Computers = $Computer."name"


#Gathering computers to a csv file
remove-item $path -ErrorAction SilentlyContinue
$i=1
$Computers | ForEach-Object {
Set-Location "$($SiteCode):\" @initParams
$Computer = $_
$Variable = Get-CMDeviceVariable -DeviceName $_ | Select-Object name, value | Where-Object {$_.name -eq "City"}
set-location "C:\"

    $hash = @{
                "Computername" = $Computer
                "Variable" = $Variable
            }
$newRow = New-object Psobject -Property $Hash
Export-Csv $Path -InputObject $newrow -Append -Force
write-host -ForegroundColor Cyan "Added $_ to CSV file, Computer number $i"
$i++
start-sleep -Milliseconds 100
}


#Gathering data with all who have a specific Country to a List
Set-location "C:\"
$Data = Import-csv $Path
$List = @()
$Data | ForEach-Object{

if ($_.Variable -eq "@{name=City; value=$City}")
    {
        $List += $_.Computername
    }
}
$List

# Add variables to Device-object with that country code
$k=1
Set-Location "$($SiteCode):\" @initParams
$List | ForEach-Object {
New-CMDeviceVariable -Devicename $_ -VariableName "SpecificLocation" -VariableValue $SpecificLocation
New-CMDeviceVariable -Devicename $_ -VariableName "HouseName" -VariableValue $HouseName
write-host -ForegroundColor yellow "Adding Variables to computer $_, Computer number $k"
$k++
start-sleep -Milliseconds 100
}