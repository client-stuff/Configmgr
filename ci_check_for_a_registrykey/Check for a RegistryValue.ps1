<#
.Synopsis
   Reading a Registry key if it exist or not.
.DESCRIPTION
    Reading a registrykey if it exist then write (1=True) (0=False)
    #Author : Pontus Wendt
    #Homepage : https://Clientstuff.blog
#>
function Get-Registrykey
{
    [CmdletBinding()]
    param ()
   

    Begin
    {
    }
    Process
    {
    Try {
    $Result = Test-Path "HKLM:\Software\Classes\MJ"
     
    ForEach-Object {
            If($Result -match "True") { 
                } 
                
            ElseIf($Result -match "False") {
                }
                
                    }
     }
   catch {
   # Error hantering
   
   }
  


    }
    
    End
    {
    }
}

Get-Registrykey