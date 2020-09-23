# Check installed module
Get-InstalledModule
Find-Module -Name VMware.PowerCLI
Get-Module VMware* -ListAvailable



# Certificate and connection to vCenter
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
Connect-VIServer srv-vcenter-01.megasp.net                

# Tests to learn Powercli ....
Get-VM
Get-VMHost
Get-VirtualSwitch
Get-VirtualSwitch | Format-Table Name, Datacenter,MTU,VMHost
Get-Datacenter -Name ATX-01
Get-Datacenter -Name ATX-01 | Get-VM
Get-Datacenter -Name ATX-01 | Get-VDSwitch




# Variable assignement ATX-01 => $DC
$DC = Get-Datacenter -Name ATX-01


# Variable assignement Hosts
$vmhosts = $DC | Get-VMHost

# Variable Assignement VDS Name
$VDS = "ATX-VDS"
#$VDSNAME = Get-VDSwitch $VDS


# VDS Creation in DC $DC with Name $VDS 
New-VDSwitch -Name $VDS -Location $DC -NumUplinkPorts 4 -Version 7.0.0 -Mtu 9000 -LinkDiscoveryProtocol CDP -LinkDiscoveryProtocolOperation Both -ContactName "Nicolas MICHEL"  -ContactDetails "itops@customer.com"

# Port group creation within vDS $VDS Active links: 1,2 - Unused: 3,4
Get-VDSwitch $VDS | New-VDPortgroup -name "DPG-VLAN100-MGMT-INFRASTRUCTURE" | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort 'dvUplink1','dvUplink2' -UnusedUplinkPort​​ 'dvUplink3','dvUplink4'
Set-VDVlanConfiguration -VDPortgroup "DPG-VLAN100-MGMT-INFRASTRUCTURE" -VlanId "100"

# Port group creation within vDS $VDS Active links: 3,4 - Unused: 1,2
Get-VDSwitch $VDS | New-VDPortgroup -name "DPG-VLAN110-TEP-COMPUTE" | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort 'dvUplink3','dvUplink4' -UnusedUplinkPort​​ 'dvUplink1','dvUplink2'
Set-VDVlanConfiguration -VDPortgroup "DPG-VLAN110-TEP-COMPUTE" -VlanId "110"

# Port group creation within vDS $VDS Active links: 3,4 - Unused: 1,2 - OTHER METHOD
$DPG_TEP_EDGE_NAME = "DPG-VLAN120-TEP-EDGE"
$DPG_TEP_EDGE_VLAN_ID = "120"
Get-VDSwitch $VDS | New-VDPortgroup -name $DPG_TEP_EDGE_NAME | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -ActiveUplinkPort 'dvUplink3','dvUplink4' -UnusedUplinkPort​​ 'dvUplink1','dvUplink2'
Set-VDVlanConfiguration -VDPortgroup $DPG_TEP_EDGE_NAME -VlanId $DPG_TEP_EDGE_VLAN_ID

# Echo
Write-Host "Adding" $vmHosts "to" $VDS

# Add the hosts $vmhosts (ALL 3 ESXi) into the vDS
Get-VDSwitch -Name $VDS | Add-VDSwitchVMHost -VMHost $vmHosts


# Compute cluster definition + Hosts
$compute = $DC | Get-Cluster "Compute"
$vm_compute = $DC | Get-cluster $compute | Get-VMHost 

# Remove vmnic 0 from VSS on hosts in compute cluster compute  
$vmhostNetworkAdapter = Get-VMHost $vm_compute | Get-VMHostNetworkAdapter -Physical -Name vmnic0 | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false
$vmhostNetworkAdapter = Get-VMHost $vm_compute | Get-VMHostNetworkAdapter -Physical -Name vmnic0

# Add vmnic 0 to vds 
Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $VDS -VMHostNetworkAdapter $vmhostNetworkAdapter -Confirm:$false


#Migrate VMK0 to vmni1 (Attention, vmnic1 is mapped to dvuplink1 now ! :( ))
$vmk0 = $DC | Get-Cluster "Compute" | Get-VMHost | Get-VMHostNetworkAdapter -Name vmk0
Set-VMHostNetworkAdapter -PortGroup "DPG-VLAN100-MGMT-INFRASTRUCTURE" -VirtualNic $vmk0 -Confirm:$false | Out-Null


# Remove vmnic 1 from VSS on hosts in cluster compute  
$vmhostNetworkAdapter = Get-VMHost $vm_compute | Get-VMHostNetworkAdapter -Physical -Name vmnic1 | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false
$vmhostNetworkAdapter = Get-VMHost $vm_compute | Get-VMHostNetworkAdapter -Physical -Name vmnic1

# Add vmnic 0 to vds 
Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $VDS -VMHostNetworkAdapter $vmhostNetworkAdapter -Confirm:$false



# Management - Edge cluster definition + Hosts
$management = $DC | Get-Cluster "Management-Edge"
$vm_management = $DC | Get-cluster $management | Get-VMHost 


# Remove vmnic 0 from VSS on hosts in cluster edge  - Add 
$vmhostNetworkAdapter0 = Get-VMHost $vm_management | Get-VMHostNetworkAdapter -Physical -Name vmnic0 | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false
$vmhostNetworkAdapter0 = Get-VMHost $vm_management | Get-VMHostNetworkAdapter -Physical -Name vmnic0

# Add vmnic 0 to vds 
Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $VDS -VMHostNetworkAdapter $vmhostNetworkAdapter0 -Confirm:$false


#Migrate VMK0 to vmnic0 
$vmk0 = $DC | Get-Cluster $management | Get-VMHost | Get-VMHostNetworkAdapter -Name vmk0
Set-VMHostNetworkAdapter -PortGroup "DPG-VLAN100-MGMT-INFRASTRUCTURE" -VirtualNic $vmk0 -Confirm:$false | Out-Null

#Migrate virtual machine from hosts on edge to DVS Port group
Get-VM | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "DPG-VLAN100-MGMT-INFRASTRUCTURE" -Confirm:$false



# Remove vmnic 1,2,3 from VSS on hosts in cluster edge  - Add 
$vmhostNetworkAdapter1 = Get-VMHost $vm_management | Get-VMHostNetworkAdapter -Physical -Name vmnic1 | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false
$vmhostNetworkAdapter1 = Get-VMHost $vm_management | Get-VMHostNetworkAdapter -Physical -Name vmnic1
$vmhostNetworkAdapter2 = Get-VMHost $vm_management | Get-VMHostNetworkAdapter -Physical -Name vmnic2 | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false
$vmhostNetworkAdapter2 = Get-VMHost $vm_management | Get-VMHostNetworkAdapter -Physical -Name vmnic2
$vmhostNetworkAdapter3 = Get-VMHost $vm_management | Get-VMHostNetworkAdapter -Physical -Name vmnic3 | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false
$vmhostNetworkAdapter3 = Get-VMHost $vm_management | Get-VMHostNetworkAdapter -Physical -Name vmnic3


# Add vmnic 1,2,3 to vds 
Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $VDS -VMHostNetworkAdapter $vmhostNetworkAdapter1 -Confirm:$false
Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $VDS -VMHostNetworkAdapter $vmhostNetworkAdapter2 -Confirm:$false
Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $VDS -VMHostNetworkAdapter $vmhostNetworkAdapter3 -Confirm:$false

