$VCSAHostname = "192.168.8.105"
$VCSAUsername = "administrator@tanzu.local"
$VCSAPassword =  "VMware!"
$DatacenterName = "TCE-Datacenter"
$DatastoreName = "local-vmfs1" ## This must match your setup. The ESXi default is datastore1. I have 2 and name them local-vmfs1 and local-vmfs2.
$ClusterName = "TCE-Cluster"
$ESXiHostname = "192.168.8.100"
$ESXiPassword = "VMware!"
$ResourcePoolName= "TCE-ResourcePool"
$VMFolderName = "TCE-VMs"

### These command may need to be run the 1st time, from inside of pwsh>
###Install-Module VMware.PowerCLI -Scope CurrentUser
###Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore

$vc = Connect-VIServer $VCSAHostname -User $VCSAUsername -Password $VCSAPassword

Write-Host "Disabling Network Rollback for 1-NIC VDS ..."
Get-AdvancedSetting -Entity $vc -Name "config.vpxd.network.rollback" | Set-AdvancedSetting -Value false -Confirm:$false

Write-Host "Creating vSphere Datacenter ${DatacenterName} ..."
New-Datacenter -Server $vc -Name $DatacenterName -Location (Get-Folder -Type Datacenter -Server $vc)

Write-Host "Creating vSphere Cluster ${ClusterName} ..."
New-Cluster -Server $vc -Name $ClusterName -Location (Get-Datacenter -Name $DatacenterName -Server $vc) -DrsEnabled -HAEnabled

Write-Host "Creating vSphere ResourcePools"
New-ResourcePool -Name $ResourcePoolName  -Server $vc -Location (Get-Cluster -Name $ClusterName)
New-ResourcePool -Name ManagementResources  -Server $vc -Location (Get-ResourcePool -Name $ResourcePoolName)
New-ResourcePool -Name WorkloadResources  -Server $vc -Location (Get-ResourcePool -Name $ResourcePoolName)

Write-Host "Createing vSphere VM Folders"
New-Folder -Name $VMFolderName -Location (Get-Folder -Name "vm") 
New-Folder -Name ManagementVMs -Location (Get-Folder -Name $VMFolderName -Type "VM") 
New-Folder -Name WorkloadVMs -Location (Get-Folder -Name $VMFolderName -Type "VM") 

Write-Host "Disabling Network Redudancy Warning ..."
(Get-Cluster -Server $vc $ClusterName) | New-AdvancedSetting -Name "das.ignoreRedundantNetWarning" -Type ClusterHA -Value $true -Confirm:$false

Write-Host "Adding ESXi host ${ESXiHostname} ..."
Add-VMHost -Server $vc -Location (Get-Cluster -Name $ClusterName) -User "root" -Password $ESXiPassword -Name $ESXiHostname -Force
