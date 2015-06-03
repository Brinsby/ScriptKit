$report = @(); $vms = get-vm; foreach ($vm in $vms){foreach ($vhd in $vm.VirtualHardDisks){$maxvhdsize = [math]::Round($vhd.MaximumSize/1024/1024/1024,1); $vhdsize = [math]::Round($vhd.Size/1024/1024/1024,1); $row = "" | select VMName, VMCPath, VHDCount, VHDLocation, VHDSize, MaxVHDSize, VMCluster; $row.VMName = $vm.Name; $row.VMCPath = $vm.VMCPath; $row.VHDCount = $vm.VirtualHardDisks.Count; $row.VHDLocation = $vhd.Location; $row.VHDSize = $vhdSize; $row.MaxVHDSIze = $MaxVHDSize; $row.VMCluster = $vm.VMHost.HostCluster.Name; $report += $row;};};$report | export-csv C:\Temp\Hyper-V-VMs.csv -NoTypeInformation