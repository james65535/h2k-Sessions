<#
    Simple vSphere VM Creation Script
    Written by James McAfee
    Version: 1.0 - March 12th, 2018
#>

Get-Module -Name VMware* -ListAvailable | Import-Module
$vcUser = ""
$vcPass = ""
$vcServer = "vcsa-01a.corp.local"
$vmHost = "esx-01a.corp.local"
$vmDatastore = "ds-iscsi01"

function createVMs {
    Param ([int]$numVMs)
    for ($i = 0; $i -lt $numVMs;$i++) {
        $vmName = ([char](65+$i))
        $result = New-VM -Name $vmName -VMHost $vmHost -Datastore $vmDatastore -DiskGB 1 -MemoryGB 1 -NumCpu 1 -Portgroup "VM Network"
    }
}

write-host "Starting script"
$server = Connect-VIserver -server $vcServer -user $vcUser -password $vcPass

$startVMList = Get-VM
write-host $startVMList

createVMs -numVMs 2

$endVMList = Get-VM
write-host $endVMList

Disconnect-VIServer -server $server -Confirm:$false
write-host "Ending script"
Read-Host -Prompt "Hit key to end"