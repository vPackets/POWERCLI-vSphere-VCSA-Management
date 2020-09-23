#----------------- Start of code capture -----------------

#---------------QueryAvailableDvsSpec---------------
$recommended = $true
$_this = Get-View -Id 'DistributedVirtualSwitchManager-DVSManager'
$_this.QueryAvailableDvsSpec($recommended)

#---------------QueryAvailableDvsSpec---------------
$recommended = $true
$_this = Get-View -Id 'DistributedVirtualSwitchManager-DVSManager'
$_this.QueryAvailableDvsSpec($recommended)

#---------------AddDVPortgroup_Task---------------
$spec = New-Object VMware.Vim.DVPortgroupConfigSpec[] (1)
$spec[0] = New-Object VMware.Vim.DVPortgroupConfigSpec
$spec[0].Name = 'DPG-VLAN100-MGMT-INFRASTRUCTURE'
$spec[0].DefaultPortConfig = New-Object VMware.Vim.VMwareDVSPortSetting
$spec[0].DefaultPortConfig.Vlan = New-Object VMware.Vim.VmwareDistributedVirtualSwitchVlanIdSpec
$spec[0].DefaultPortConfig.Vlan.VlanId = 100
$spec[0].DefaultPortConfig.Vlan.Inherited = $false
$spec[0].NumPorts = 8
$spec[0].Type = 'earlyBinding'
$spec[0].AutoExpand = $true
$spec[0].VmVnicNetworkResourcePoolKey = '-1'
$_this = Get-View -Id 'VmwareDistributedVirtualSwitch-dvs-52'
$_this.AddDVPortgroup_Task($spec)

#---------------QueryAvailableDvsSpec---------------
$recommended = $true
$_this = Get-View -Id 'DistributedVirtualSwitchManager-DVSManager'
$_this.QueryAvailableDvsSpec($recommended)

#---------------ReconfigureDVPortgroup_Task---------------
$spec = New-Object VMware.Vim.DVPortgroupConfigSpec
$spec.ConfigVersion = '1'
$spec.DefaultPortConfig = New-Object VMware.Vim.VMwareDVSPortSetting
$spec.DefaultPortConfig.UplinkTeamingPolicy = New-Object VMware.Vim.VmwareUplinkPortTeamingPolicy
$spec.DefaultPortConfig.UplinkTeamingPolicy.NotifySwitches = New-Object VMware.Vim.BoolPolicy
$spec.DefaultPortConfig.UplinkTeamingPolicy.NotifySwitches.Inherited = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.NotifySwitches.Value = $true
$spec.DefaultPortConfig.UplinkTeamingPolicy.RollingOrder = New-Object VMware.Vim.BoolPolicy
$spec.DefaultPortConfig.UplinkTeamingPolicy.RollingOrder.Inherited = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.RollingOrder.Value = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.Inherited = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.FailureCriteria = New-Object VMware.Vim.DVSFailureCriteria
$spec.DefaultPortConfig.UplinkTeamingPolicy.FailureCriteria.Inherited = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.FailureCriteria.CheckBeacon = New-Object VMware.Vim.BoolPolicy
$spec.DefaultPortConfig.UplinkTeamingPolicy.FailureCriteria.CheckBeacon.Inherited = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.FailureCriteria.CheckBeacon.Value = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder = New-Object VMware.Vim.VMwareUplinkPortOrderPolicy
$spec.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.ActiveUplinkPort = New-Object String[] (2)
$spec.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.ActiveUplinkPort[0] = 'dvUplink1'
$spec.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.ActiveUplinkPort[1] = 'dvUplink2'
$spec.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.Inherited = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.StandbyUplinkPort = New-Object String[] (0)
$spec.DefaultPortConfig.UplinkTeamingPolicy.Policy = New-Object VMware.Vim.StringPolicy
$spec.DefaultPortConfig.UplinkTeamingPolicy.Policy.Inherited = $false
$spec.DefaultPortConfig.UplinkTeamingPolicy.Policy.Value = 'loadbalance_srcid'
$_this = Get-View -Id 'DistributedVirtualPortgroup-dvportgroup-55'
$_this.ReconfigureDVPortgroup_Task($spec)