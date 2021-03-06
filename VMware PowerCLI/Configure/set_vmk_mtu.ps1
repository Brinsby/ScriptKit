# This file is part of ScriptKit.
#
#    ScriptKit is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    ScriptKit is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with ScriptKit.  If not, see <http://www.gnu.org/licenses/>
#
#===================================================================================
#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2014
#Version: 1.00.01
#Description: Updates the MTU size for specified VMKERNEL virtual nics (vmk0, vmk1, vmk2, etc.)
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2014 Rynardt Spies
#==============================================================================================

#Configure the following variables before running the script.
$vcenter = "vcenter.domain"
#Set the MTU size on the following vmk nics, separated by comas.
$vmks = @("vmk1")
#Desired MTU Size (1500=Standard, 9000=Jumbo-Frames)
$setMTUvalue = 1500

#Clear the console screen
Clear Screen

write-Output "Connecting to vSphere Environment $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter. Check server address."
	break
	}
Write-Output "Successfully connected to: $ConnectionResult"

#Import hosts from a CSV file which contains the fields: HostName
$hosts = Import-csv "set_vmk_mtu-list.csv"

foreach ($importedHost in $hosts){
	$esxhost = Get-VMhost $importedHost.HostName
	foreach ($vmk in $vmks){
		#Set the MTU for each specified vmk to whatever is specified in $setMTUvalue
		$vmk = Get-VmHostNetworkAdapter -VMHost $esxhost -vmkernel | where{$_.Name -eq $vmk}
		$vmkmtu = $vmk.mtu
		Write-Output "The current MTU size for $vmk on $esxhost is $vmkmtu"
		Set-VMHostNetworkAdapter -VirtualNic $vmk -mtu $setMTUvalue -confirm:$false
		$vmk = Get-VMHostNetworkAdapter -VMHost $esxhost -vmkernel | where{$_.Name -eq $vmk}
		$vmkmtu = $vmk.mtu
		Write-Output "The MTU size for $vmk on $esxhost has now been set to $vmkmtu"
	}
}
Write-Output "Disconnecting from vSphere Environment: $vcenter"
disconnect-viserver $vcenter -confirm:$false