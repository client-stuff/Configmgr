<#
.Synopsis
   _Collection_relations.ps1
.DESCRIPTION
    Created: 2019-08-03
    Version: 1.0

    Author : Pontus Wendt
    Twitter: @pontuswendt
    Blog   : https://clientstuff.blog

    Disclaimer: This script is provided "AS IS" with no warranties, confers no rights and
    is not supported by the author.
.EXAMPLE
    NA
#>

################ MSG BOX ###################
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$Title = 'Collection relations by Pontus Wendt'
$Collection = 'Enter your Collection'

$msg = [Microsoft.VisualBasic.Interaction]::InputBox($Collection, $Title)

############################################

############ Custom Variables ##############
$Site = "P01:"
$ServerInstance = "CM01.poppe.com"
$Database = "CM_P01"

##### Convert COL-NAME to COL-ID ###########
#Import Modules
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"

#Change location to the current sitecode
Set-Location $Site

$Collection = Get-CMCollection -Name $msg | Select-Object "CollectionID"

$CollectionID = $Collection.CollectionID

############################################


#########   SQL THINGS   ###################
Import-module SQLPS -DisableNameChecking

Set-Location SQLServer:\

$query = "
(
select distinct
v_Collection.Name as 'Collection Dependency Name',
v_Collection.CollectionID,
vSMS_CollectionDependencies.SourceCollectionID as 'SourceCollection',
Case When
vSMS_CollectionDependencies.relationshiptype = 1 then 'Limited To ' + v_Collection.name + ' (' + vSMS_CollectionDependencies.SourceCollectionID + ')'
when vSMS_CollectionDependencies.relationshiptype = 2 then 'Include ' + v_Collection.name + ' (' + vSMS_CollectionDependencies.SourceCollectionID + ')'
when vSMS_CollectionDependencies.relationshiptype = 3 then 'Exclude ' + v_Collection.name + ' (' + vSMS_CollectionDependencies.SourceCollectionID + ')'
end as 'Type of Relationship'
from v_Collection
join vSMS_CollectionDependencies on vSMS_CollectionDependencies.DependentCollectionID = v_Collection.CollectionID
where vSMS_CollectionDependencies.SourceCollectionID = '$CollectionID'
)
"

$sqldata = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query -QueryTimeout 360


############################################

############# OUTPUT BOX ###################

$sqldata | Out-GridView

Read-host "Press enter to exit"
Exit