Connect-AzAccount
Set-AzContext -Subscription "db68ec67-eb93-4c28-ba2f-c6c63066827f"$ResourceGroupName = "dev"$VMName="test-vm"
$Location = "Central India"
$SnapshotName = "test-snap3"
$SnapRG = "snaprgv"
$Diskrg = "diskrgv"
$GoldenVm = "goldenvm"$VMOSDisk=(Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName).StorageProfile.OsDisk.Name
$Disk = Get-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $VMOSDisk
$SnapshotConfig = New-AzureRmSnapshotConfig -SourceUri $Disk.Id -CreateOption Copy -Location $Location
$Snapshot=New-AzureRmSnapshot -Snapshot $SnapshotConfig -SnapshotName $SnapshotName -ResourceGroupName $SnapRG# 2- Creating a new managed disk using the newly created snapshot above.$StorageType = "StandardSSD_LRS"
$NewDiskName="test-vm-os-disk1"
$NewOSDiskConfig = New-AzureRmDiskConfig -AccountType $StorageType -Location $Location -CreateOption Copy -SourceResourceId $Snapshot.Id
$newOSDisk=New-AzureRmDisk -Disk $NewOSDiskConfig -ResourceGroupName $Diskrg -DiskName $NewDiskName# 3 - Creating a new VM using the new managed disk we've created from a snapshot earlier.$NewvirtualMachineName="test-vm-2"
$virtualNetworkName="dev-vnet"
$NewvirtualMachineSize="Standard_D4d_v4"
$VNet = Get-AzureRmVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $ResourceGroupName
$NIC = New-AzureRmNetworkInterface -Name ($NewvirtualMachineName.ToLower()+"_NIC") -ResourceGroupName $GoldenVm -Location $Location -SubnetId $VNet.Subnets[0].Id
$VirtualMachine = New-AzureRmVMConfig -VMName $NewvirtualMachineName -VMSize $NewvirtualMachineSize
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -ManagedDiskId $newOSDisk.Id -CreateOption Attach -Windows
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzureRmVMBootDiagnostics -VM $VirtualMachine -Disable
New-AzureRmVM -VM $VirtualMachine -ResourceGroupName $GoldenVm -Location $snapshot.Location