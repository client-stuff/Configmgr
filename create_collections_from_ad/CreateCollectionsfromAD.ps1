<#
.Synopsis
   CreateCollectionsfromAD.ps1
.DESCRIPTION
    Created: 2018-11-13
    Version: 1.0

    Author : Pontus Wendt
    Twitter: @pontuswendt
    Blog   : https://clientstuff.blog

    Disclaimer: This script is provided "AS IS" with no warranties, confers no rights and
    is not supported by the author.
.EXAMPLE
    NA
#>


#Import Modules
Import-Module ConfigurationManager
Import-Module ActiveDirectory


#Variables
#The logpath of your script
$Logpath = "C:\Logging\Log.log"
#Domain
$Domain = "test.pontus.com"
#Domain in ADSI
$DomainADSI ="DC=test,DC=pontus,DC=com"
#Gather the OU folders, that will be created, every folder you search for will be created.
$GADOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $DomainADSI -SearchScope OneLevel -Properties CanonicalName | Select-Object Name
#SCCM Query
$query="select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemOUName like '$domain/Computers%'"
#Specify the sitecode of your SCCM
$SiteCode = "X01:"
#SCCM folder you want to move your collections to (you need to create this folder before you run)
$CMFolderPath = "$SiteCode\DeviceCollection\Computers from OU"
#You need to mofidy one more step is under the Add collection funciton


#Change Location to primary site
Set-Location $SiteCode 

#Functions
#WriteLog function
Function WriteLog ($message)
{
    $TZbias = (Get-WmiObject -Query “Select Bias from Win32_TimeZone”).bias
    $Time = Get-Date -Format “HH:mm:ss.fff”
    $Date = Get-Date -Format “MM-dd-yyyy”
    $Output = "<![LOG[$($message)]LOG]!><time=""$($Time)+$($TZBias)"" date=""$($Date)"" type=""1"">“
    Out-File -InputObject $Output -Append -Encoding Default –FilePath "$Logpath"
}

#AddCollection function
Function AddCollection
{
    #Check if name already exists
    if ($null -ne (Get-CMDeviceCollection -Name "$Collectionname"))
    {
        WriteLog "$Collectionname exists. Skipping."
        return 
     }  
   
     #Check if OU structure have XX
    if ($Collectionname -eq "XX")
    {
        WriteLog "$Collectionname have equals name as XX. Skipping."
        return     
    }

    Try
    {
        WriteLog "Adding $Collectionname"
        
        $Schedule = New-CMSchedule -RecurInterval Hours -RecurCount 1
        WriteLog "Created Schedule: $Schedule"
        
        WriteLog "Creating collection $Collectionname"

        
        ##MODIFY THIS ALSO##
        $query="select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemOUName like '$domain/$names/Clients/XX/%'"
        
        WriteLog "Creating $Collectionname with query $query"
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName "$Collectionname" -QueryExpression $query -RuleName "$Collectionname"
        WriteLog "Moving $Collectionname"

        $CollID = Get-CMDeviceCollection -Name $Collectionname
        Move-CMObject -FolderPath $CMFolderPath -ObjectId $CollID.CollectionID

        #Wait a bit
        Start-Sleep 10

    }
    catch
    {
        Write-Host "Failed to create collection $($_.Exception.Message) $($_.Exception.ItemName)"
    }
}

#------------------------------------------------------------


#OU from csv foreach in foreach
foreach ($Collectionname in $GADOU.Name) {

WriteLog "Adding $Collectionname"

Get-ADOrganizationalUnit -Identity "OU=$Collectionname,$DomainADSI"


AddCollection $Collectionname


}



