Login-AzAccount

Get-AzSubscription

$SubscriptionId = 'ab7fdd3c-82ff-4de2-aa6f-081cce568bb7'
$SubscriptionName = 'Henson Production'
Select-AzSubscription $SubscriptionId
 
#region Setting up required Variables
#Install Az Module and Excel Module  "Install-Module -Name ImportExcel " to run this code

#Infra Dev/Test              f0cae3c8-510f-4e85-be66-8308307e3142 
 
$location = "C:\"
Set-Location $location
$files = @()
$VMSize = @()
#All VM size based on ascedning order of there cores
$VMABSize =@{Standard_F1s = "Standard_B1ms";Standard_D2s_v3 = "Standard_B2ms";Standard_F2s = "Standard_B2s";Standard_E2_v3 = "Standard_A2m_v2";Standard_D11 = "Standard_A5";Standard_D4_v3 = "Standard_B4ms";Standard_E4_v3 = "Standard_A4m_v2";Standard_F4 = "Standard_A4_v2";Standard_D12_v2 = "Standard_A6";Standard_D8_v3 = "Standard_B8ms";Standard_E8_v3 = "Standard_A8m_v2";Standard_F8 = "Standard_A8_v2";Standard_D16_v3 = "Standard_B16ms"} #This recommendation is going to be hard-coded since we dont want anyone else to change these values, as these values are outcomes of deep analysis
$VMSize = @("Standard_A0”,"Basic_A0”,"Standard_A1”,"Basic_A1”,"Standard_A1_v2”,"Standard_F1”,"Standard_A2”,"Basic_A2”,"Standard_A2_v2","Standard_F2”,"Standard_D2_v2”,"Standard_DS2_v2”,"Standard_DS2_v2_Promo”,"Standard_D2”,"Standard_DS2”,"Standard_D2_v3”,"Standard_D2a_v4”,"Standard_A5”,"Standard_D11_v2”,"Standard_D11_v2_Promo”,"Standard_DS11-1_v2”,"Standard_DS11_v2”,"Standard_DS11_v2_Promo”,"Standard_D11”,"Standard_DS11”,"Standard_A2m_v2”,"Standard_E2_v3”,"Standard_E2a_v4”,"Standard_A3”,"Basic_A3”,"Standard_A4_v2”,"Standard_F4”,"Standard_F4s”,"Standard_D3_v2”,"Standard_D3_v2_Promo”,"Standard_DS3_v2”,"Standard_DS3_v2_Promo”,"Standard_D3”,"Standard_DS3”,"Standard_D4_v3”,"Standard_D4a_v4”,"Standard_A6”,"Standard_D12_v2”,"Standard_D12_v2_Promo”,"Standard_DS12-1_v2”,"Standard_DS12-2_v2”,"Standard_DS12_v2”,"Standard_DS12_v2_Promo”,"Standard_D12”,"Standard_DS12”,"Standard_A4m_v2”,"Standard_E4_v3”,"Standard_E4a_v4”,"Standard_A4”,"Basic_A4”,"Standard_F8”,"Standard_F8”,"Standard_D4_v2”,"Standard_D4_v2_Promo”,"Standard_DS4_v2”,"Standard_DS4_v2_Promo”,"Standard_D4”,"Standard_DS4”,"Standard_D8_v3”,"Standard_D8a_v4”,"Standard_D8_v3”,"Standard_D8a_v4”,"Standard_A7”,"Standard_D13_v2”,"Standard_D13_v2_Promo”,"Standard_DS13-2_v2”,"Standard_DS13-4_v2”,"Standard_DS13_v2”,"Standard_DS13_v2_Promo”,"Standard_D13”,"Standard_DS13”,"Standard_A8m_v2”,"Standard_E8_v3”,"Standard_E8a_v4”,"Standard_F16”,"Standard_D5_v2”,"Standard_D5_v2_Promo”,"Standard_DS5_v2”,"Standard_DS5_v2_Promo”,"Standard_D16_v3”,"Standard_D16a_v4”,”Standard_E16_v3”) #This recommendation is going to be hard-coded since we dont want anyone else to change these values, as these values are outcomes of deep analysis
$VMSizePremium = @("Standard_B1ls”,"Standard_B1s”,"Standard_B1ms”,"Standard_F1s”,"Standard_B2s”,"Standard_F2s”,"Standard_F2s_v2”,"Standard_B2ms”,"Standard_D2s_v3”,"Standard_D2as_v4”,"Standard_E2s_v3”,"Standard_E2as_v4”,"Standard_F4s”,"Standard_F4s_v2”,"Standard_B4ms”,"Standard_D4s_v3”,"Standard_D4as_v4”,"Standard_E4-2s_v3”,"Standard_E4s_v3”,"Standard_L4s”,"Standard_E4as_v4”,"Standard_F8s”,"Standard_F8s_v2”,"Standard_F8s”,"Standard_F8s_v2”,"Standard_B8ms”,"Standard_D8s_v3”,"Standard_D8as_v4”,"Standard_E8-2s_v3”,"Standard_E8-4s_v3”,"Standard_E8s_v3”,"Standard_L8s_v2”,"Standard_L8s”,"Standard_E8as_v4”,”Standard_E16-8s_v3”,"Standard_B12ms”,"Standard_F16s”,"Standard_F16s_v2”,"Standard_B16ms”,"Standard_D16s_v3”,"Standard_D16as_v4”,”Standard_E16s_v3”,”Standard_E32-16s_v3”,"Standard_B20ms”)
$AppServiceTier = @("B1","S1","B2","S2","P1v2","B3","S3","P2v2","P3v2") # It has to be in ascending order 
$AppServiceTierName = @("Basic","Standard","Basic","Standard","Premium V2","Basic","Standard","Premium V2",,"Premium V2") # It has to be in ascending order and in sequence with AppService Tier 
$AppServiceSize = @{S1 = "B1";S2 = "B2";S3 = "B3";P1v2 = "B1"; P2v2 = "B2";P3v2 = "B3"} #This recommendation is going to be hard-coded since we dont want anyone else to change these values, as these values are outcomes of deep analysis
$AppServiceSizeName = @{Standard = "Basic";Premium = "Basic"} #This recommendation is going to be hard-coded since we dont want anyone else to change these values, as these values are outcomes of deep analysis
$startdate = (Get-Date).AddDays(-90)
$enddate = (Get-Date)
$StorageAccountLastModifiedDateCool = (Get-Date).adddays(-30)
$StorageAccountLastModifiedDateArchive = (Get-Date).adddays(-180)
#endregion


#region Scale down the machines that require high compute for a period of time in month ,  Use A & B series SKUs for Dev and test environments,  Leverage Azure Spot VM instances for cron(daemon) jobs
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "ExtractionVMListutilization" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName1   = ".\Extraction\ExtractionVMListutilization\VMList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$VMs = Get-AzVM 


$vmOutput = @() 
$VMs | ForEach-Object {  
    $tmpObj = New-Object -TypeName PSObject 
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Name" -Value $_.Name
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Size" -Value $_.HardwareProfile.VmSize 
    $size = $_.HardwareProfile.VmSize
    $cores = (get-azvmsize -Location $_.Location | ?{ $_.Name -eq $size }).NumberOfCores
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Cores" -Value $cores  
    $memory = (get-azvmsize -Location $_.Location | ?{ $_.Name -eq $size }).MemoryInMB
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Memory(MB)" -Value $memory 
    $tmpObj | Add-Member -MemberType Noteproperty -Name "ResourceGroup" -Value $_.ResourceGroupName
    $metric = Get-AzMetric -ResourceId $_.Id  -MetricName "Percentage CPU" -StartTime $startdate -EndTime $enddate -WarningAction SilentlyContinue
    $average = ($metric.Data.Average | Measure-Object -Average).Average
    if ($average -ne $null)
    {
        $tmpObj | Add-Member -MemberType Noteproperty -Name "UtilizationOfVM" -Value $average
        if($average -lt 50)
        {   
            if(($tmpObj.'VM Name').ToLower() -match "test" -and $average -lt 1)     #Lowering down utilization just to find out best fit scenario for recommendation
            {
                $tmpObj | Add-Member -MemberType Noteproperty -Name "New VM Size" -Value "Recommended for Spot VM Instance" -Force
            }
            else
            { 
                if((($tmpObj.'VM Name').ToLower() -match "test") -or (($tmpObj.'VM Name').ToLower() -match "dev"))
                {
                    if($VMABSize[$tmpObj.'VM Size'] -ne $null )
                    {
                        $tmpObj | Add-Member -MemberType Noteproperty -Name "New VM Size" -Value $VMABSize[$tmpObj.'VM Size']  -Force
                    }
                    else
                    {
                        $tmpObj | Add-Member -MemberType Noteproperty -Name "New VM Size" -Value "Fill the new VM Size" -Force
                    }
                }
                else
                { 
                    $string = (($tmpObj.'VM Size').Split('_')[1])
                    $lastcharacter = $string.Substring($string.Length-1)
                    if($lastcharacter -ne 's')
                    {
                        for ($i=0; $i -lt $VMSize.length; $i++) 
                        { 
	                        if($VMSize[$i] -match $tmpObj.'VM Size')
                            {
                                $tmpObj | Add-Member -MemberType Noteproperty -Name "New VM Size" -Value $VMSize[$i-1] -Force
                                
                            }

                        }
                    }
                    else
                    {
                        for ($i=0; $i -lt $VMSizePremium.length; $i++) 
                        { 
	                        if($VMSizePremium[$i] -match $tmpObj.'VM Size')
                            {
                                $tmpObj | Add-Member -MemberType Noteproperty -Name "New VM Size" -Value $VMSizePremium[$i-1] -Force
                               
                            }

                        }
                    
                    
                    }
                }
            }
         }
        else
        {
        $tmpObj | Add-Member -MemberType Noteproperty -Name "New VM Size" -Value "Not Recommended for new VM Size" -Force
        }
    }
    else
    {
    $tmpObj | Add-Member -MemberType Noteproperty -Name "UtilizationOfVM" -Value "Unable to Fetch Utilization (VM might be in stopped State)"
    $tmpObj | Add-Member -MemberType Noteproperty -Name "New VM Size" -Value "Fill the new VM Size Manually" -Force
    }
    
    $vmOutput += $tmpObj 
} 
$vmOutput | Export-Excel $OutputFileName1 -AutoSize -AutoFilter -Append
$OutputFileName1 = $location + $OutputFileName1.Substring(2)
$files +=$OutputFileName1
#endregion


#region Use HDD instead of SSD in Dev & Test enviroments and non critical applications
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "AllDiskSKU" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName2   = ".\Extraction\AllDiskSKU\DiskList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion




$report = @()
$managedDisks = Get-AzDisk
foreach ($md in $managedDisks) {
    $info = "" | select-object DiskName,DiskResourceGroup,DiskState,DiskSizeGB,OwnerVM,SKU,DiskReadOperations_per_sec,DiskWriteOperations_per_sec,NewSKU,DiskRecommendation #Values can be Standard_LRS, StandardSSD_LRS, Premium_LRS
    $info.DiskName = $md.Name
    $info.DiskResourceGroup = (($md.id).Split('/')[4].Split('.')[0])
    $info.DiskState = $md.DiskState
    $info.SKU = $md.Sku.name
    $info.DiskSizeGB = $md.DiskSizeGB
    
 
    $metricread = Get-AzMetric -ResourceId (Get-AzVM -ResourceGroupName $info.DiskResourceGroup -Name $md.ManagedBy.Split('/')[-1]).Id  -MetricName "Disk Read Operations/Sec" -StartTime $startdate -EndTime $enddate -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    $averageread = ($metricread.Data.Average | Measure-Object -Average).Average
    $metricwrite = Get-AzMetric -ResourceId (Get-AzVM -ResourceGroupName $info.DiskResourceGroup -Name $md.ManagedBy.Split('/')[-1]).Id  -MetricName "Disk Write Operations/Sec" -StartTime $startdate -EndTime $enddate -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    $averagewrite = ($metricwrite.Data.Average | Measure-Object -Average).Average
    Write-Host "-------------------------------------------"
    if($averageread -ne $null -and $averagewrite -ne $null){
    $info.DiskReadOperations_per_sec = $averageread
    $info.DiskWriteOperations_per_sec = $averagewrite
    }
    else{
    $info.DiskReadOperations_per_sec = "Either the VM is stopped or monitoring agent is not installed in the VM"
    $info.DiskWriteOperations_per_sec = "Either the VM is stopped or monitoring agent is not installed in the VM"
    }
    
    if($md.ManagedBy -eq $null){
        $info.OwnerVM = ""
        $info.DiskRecommendation = "There is no Owner VM attached. This Disk can be deleted if it doesnot contain any sensitive data"
        $info.NewSKU = "Fill New SKU of Disk"
        }
    else{
        $info.OwnerVM = $md.ManagedBy.Split('/')[-1]
        if ((($info.OwnerVM).ToLower() -match "test") -and (($info.SKU -eq "Premium_LRS") -or ($info.SKU -eq "StandardSSD_LRS")) -and ($info.DiskReadOperations_per_sec -lt 400) -and ($info.DiskWriteOperations_per_sec -lt 400))  
            {
            $info.DiskRecommendation = "Use Standard HDD for the disk"   
            $info.NewSKU = "Standard_LRS"
            }
        elseif ((($info.OwnerVM).ToLower() -match "dev") -and (($info.SKU -eq "Premium_LRS") -or ($info.SKU -eq "StandardSSD_LRS")) -and ($info.DiskReadOperations_per_sec -lt 400) -and ($info.DiskWriteOperations_per_sec -lt 400))  
            {
            $info.DiskRecommendation = "Use Standard HDD for the disk"   
            $info.NewSKU = "Standard_LRS"  
            }
       elseif(($info.DiskReadOperations_per_sec -ge 400) -or ($info.DiskWriteOperations_per_sec -ge 400)){
            $info.DiskRecommendation = "Not Recommended"
            $info.NewSKU = "NA"
            }
        else{
            $info.DiskRecommendation = "Use the Standard HDD or Standard SSD for the disk for non critical workload"
            $info.NewSKU = "Fill New SKU of Disk" 
        }

        }

    
    $report += $info

        }
    
 $report | Export-Excel $OutputFileName2 -AutoSize -AutoFilter
 $OutputFileName2 = $location + $OutputFileName2.Substring(2)
 $files +=$OutputFileName2
#endregion


#region Backup the VMs rather than keeping these snapshots
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "BackupVM&Snapshot" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName3   = ".\Extraction\BackupVM&Snapshot\VMwithBackupandSnapshot-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$azure_recovery_services_vault_list = Get-AzRecoveryServicesVault 

$backup_details = $null 
$backup_details = @() 

foreach($azure_recovery_services_vault_list_iterator in $azure_recovery_services_vault_list){ 
 
    Set-AzRecoveryServicesVaultContext -Vault $azure_recovery_services_vault_list_iterator -WarningAction SilentlyContinue
 
    $container_list = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM 
 
    foreach($container_list_iterator in $container_list){ 
 
         
        $backup_item = Get-AzRecoveryServicesBackupItem -Container $container_list_iterator -WorkloadType AzureVM 
        $backup_item_array = ($backup_item.ContainerName).split(';') 
        $backup_item_resource_name = $backup_item_array[1] 
        $backup_item_vm_name = $backup_item_array[2] 
        $backup_item_last_backup_status = $backup_item.LastBackupStatus 
        $backup_item_latest_recovery_point = $backup_item.LatestRecoveryPoint 
 
        $backup_details_temp = New-Object psobject 
 
        $backup_details_temp | Add-Member -MemberType NoteProperty -Name "ResourceGroupName" -Value $backup_item_resource_name 
        $backup_details_temp | Add-Member -MemberType NoteProperty -Name "VMName" -Value $backup_item_vm_name 
        $backup_details_temp | Add-Member -MemberType NoteProperty -Name "VaultName" -Value $azure_recovery_services_vault_list_iterator.Name 
        $backup_details_temp | Add-Member -MemberType NoteProperty -Name "BackupStatus" -Value $backup_item_last_backup_status 
        $backup_details_temp | Add-Member -MemberType NoteProperty -Name "LatestRecoveryPoint" -Value $backup_item_latest_recovery_point 
 
        $backup_details = $backup_details + $backup_details_temp 
 
    } 
 
} 
 
$vms = Get-AzVM


$VMnotbackedup = $vms | Where {$backup_details.VMName -NotContains $_.Name}
$VMbackedup = $vms | Where {$backup_details.VMName -Contains $_.Name}
#$VMnotbackedup#| Select-Object ResourceGroupName,Name,Location  | Export-Excel -Path $OutputFileName -AutoSize -AutoFilter -Append
#$VMbackedup

$Disklist = $null
$Disklist = @()
$VMlist = $null
$VMlist = @()
$snapshot_details = $null
$snapshot_details = @()
$Snapshot = Get-AzSnapshot
foreach ($snap in $Snapshot){
#$Disklist = $Disklist + $snap.CreationData.SourceResourceId.Split('/')[8].Split('.')[0]
#$VMlist = $VMlist + (Get-AzDisk -DiskName ($snap.CreationData.SourceResourceId.Split('/')[8].Split('.')[0])| Where{$_.DiskState -contains 'Attached'}).ManagedBy.Split('/')[8].Split('.')[0]
$VMNameID = (Get-AzDisk -DiskName ($snap.CreationData.SourceResourceId.Split('/')[8].Split('.')[0])| Where{$_.DiskState -contains 'Attached'}).ManagedBy#.Split('/')[8].Split('.')[0]) 
if($VMNameID -ne $null){
#Write-Host "Checking"
$VMlist = $VMlist + $VMNameID.Split('/')[8].Split('.')[0]
$snapshot_details_temp = New-Object psobject 
 
        $snapshot_details_temp | Add-Member -MemberType NoteProperty -Name "ResourceGroupName" -Value $backup_item_resource_name 
        $snapshot_details_temp | Add-Member -MemberType NoteProperty -Name "VMName" -Value $VMNameID.Split('/')[8].Split('.')[0]
        $snapshot_details_temp | Add-Member -MemberType NoteProperty -Name "DiskName" -Value ($snap.CreationData.SourceResourceId.Split('/')[8].Split('.')[0])
        $snapshot_details_temp | Add-Member -MemberType NoteProperty -Name "DiskSnapshotName" -Value $snap.Name
        $snapshot_details_temp | Add-Member -MemberType NoteProperty -Name "DiskSnapshotResourceGroupName" -Value $snap.ResourceGroupName
        $snapshot_details_temp | Add-Member -MemberType NoteProperty -Name "Recommendation" -Value "Delete the Snapshot"
        $snapshot_details = $snapshot_details + $snapshot_details_temp 
}
}


$VMbackupsnap = $snapshot_details | Where {$VMbackedup.Name -Contains $_.VMName}
$VMbackupsnap |Export-Excel -Path $OutputFileName3 -AutoSize -AutoFilter 
$OutputFileName3 = $location + $OutputFileName3.Substring(2)
$files +=$OutputFileName3

#endregion


#region Remove unallocated Disks
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "UnallocatedManagedDisk" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName4   = ".\Extraction\UnallocatedManagedDisk\DiskList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion
$deleteUnattachedDisks=0

$managedDisks = Get-AzDisk
foreach ($md in $managedDisks) {
    # ManagedBy property stores the Id of the VM to which Managed Disk is attached to
    # If ManagedBy property is $null then it means that the Managed Disk is not attached to a VM
    if($md.ManagedBy -eq $null){
        if($deleteUnattachedDisks -eq 1){
            Write-Host "Deleting unattached Managed Disk with Id: $($md.Id)"
            #$md | Remove-AzDisk -Force
            Write-Host "Deleted unattached Managed Disk with Id: $($md.Id) "
        }else{
            Write-Host "Name - " $md.name
            Write-Host "ID - "$md.id
            $Disklists = [PSCustomObject]@{
            DiskName = $md.name
            ResourceGroupName = (($md.id).Split('/')[4].Split('.')[0])
            ResourceID = $md.id
            Recommendations = "Delete the Disk"

            }
            $Disklists|Export-Excel -Path $OutputFileName4 -AutoSize -AutoFilter -Append
           

        }
    }
 }
 $OutputFileName4 = $location + $OutputFileName4.Substring(2)
$files +=$OutputFileName4
#endregion


#region Remove unallocated Public IPs
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "UnallocatedPublicIps" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName5   = ".\Extraction\UnallocatedPublicIps\PublicIp-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$deletePublicIp=0
$publicip = Get-AzPublicIpAddress

foreach ($pip in $publicip) {

    # If IpConfiguration property is $null then it means that the Public Ip is not associated to any resource
    if($pip.IpConfiguration  -eq $null){
        if($deletePublicIp -eq 1){
            Write-Host "Deleting unattached Public Ip with Id: $($pip.Id)"
            #$pip | Remove-AzPublicIpAddress -Force
            Write-Host "Deleted unattached Public Ip with Id: $($pip.Id) "
        }else{
            Write-Host "Name - " $pip.name
            Write-Host "ID - "$pip.id
            [PSCustomObject]@{
            PublicipName = $pip.name
            ResourceGroupName = (($pip.id).Split('/')[4].Split('.')[0])
            PublicIpAddress = $pip.IpAddress
            PublicIpAddressVersion = $pip.PublicIpAddressVersion
            PublicIpAddressAllocation = $pip.PublicIpAllocationMethod
            ResourceID = $pip.id
            Recommendation = "Delete the Unassigned Public Ip"
            } | Export-Excel -Path $OutputFileName5 -AutoSize -AutoFilter -Append

        }
    }
 }
 $OutputFileName5 = $location + $OutputFileName5.Substring(2)
 $files +=$OutputFileName5
#endregion


#region Use standard snapshots for managed disks
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "standardsnapshots" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName6   = ".\Extraction\standardsnapshots\snapshotslists-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

Get-AzSnapshot | Select-Object ResourceGroupName, Name, Location, @{l='SKUName';e={$_.sku.Name}},@{l='AttachedDisk';e={$_.CreationData.SourceResourceId.Split('/')[8].Split('.')[0]}},@{l='RecommendedSKU';e={if($_.sku.name -eq "Premium_LRS"){"Standard_LRS"}else{"No Recommendation"}}}| Export-Excel -Path $OutputFileName6 -AutoSize -AutoFilter 
$OutputFileName6 = $location + $OutputFileName6.Substring(2)
$files +=$OutputFileName6
#endregion


#region  Auto-Shutdown and Start during off work hours

#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "Autoshutdownstart" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName7   = ".\Extraction\Autoshutdownstart\VMList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$VMs = Get-AzVM 


$vmOutput = @() 
$VMs | ForEach-Object {  
    $tmpObj = New-Object -TypeName PSObject 
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Name" -Value $_.Name
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Size" -Value $_.HardwareProfile.VmSize 
    $size = $_.HardwareProfile.VmSize
    $cores = (get-azvmsize -Location $_.Location | ?{ $_.Name -eq $size }).NumberOfCores
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Cores" -Value $cores  
    $memory = (get-azvmsize -Location $_.Location | ?{ $_.Name -eq $size }).MemoryInMB
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Memory(MB)" -Value $memory 
    $tmpObj | Add-Member -MemberType Noteproperty -Name "ResourceGroup" -Value $_.ResourceGroupName
    $tmpObj | Add-Member -MemberType Noteproperty -Name "Autoshutdown Start Timing" -Value "Autoshutdown Start Timing"
    $tmpObj | Add-Member -MemberType Noteproperty -Name "Autoshutdown Stop Timing" -Value "Autoshutdown Stop Timing"
    if ((($tmpObj.'VM Name').ToLower() -match "test") -or(($tmpObj.'VM Name').ToLower() -match "dev")){
    $tmpObj | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Recommended For Autoshutdown"
    
    }
    else{
    $tmpObj | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Discuss with Customer"
    }
    $vmOutput += $tmpObj 
} 
$vmOutput | Export-Excel $OutputFileName7 -AutoSize -AutoFilter -Append
$OutputFileName7 = $location + $OutputFileName7.Substring(2)
$files +=$OutputFileName7

#endregion


#region Check VPN SKU based on available bandwidth 
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "VirtualNetworkGateway" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName8   = ".\Extraction\VirtualNetworkGateway\VnetGateway-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion


$gateways=@()
$rgs = Get-AzResourceGroup

#Connect-AzAccount 
foreach($rg in $rgs)
{
$gateways += Get-AzVirtualNetworkGateway -ResourceGroupName $rg.ResourceGroupName
}


 
$vmobjs = @()
foreach($gateway in $gateways)
{
$ResourceId = $null
$ResourceId = $gateway.Id
$metric = $null
$metric = Get-AzMetric -ResourceId $ResourceId  -MetricName "TunnelAverageBandwidth" -StartTime $startdate -EndTime $enddate -DetailedOutput 
$utilization = $null
$utilization = ($metric.Data.Average | Measure-Object -Average).Average
$util_mbps = $utilization/1000000
$Info = [pscustomobject]@{
                'VPNGatewayName'= $gateway.Name
                'ResourceGroupName' = $gateway.ResourceGroupName
                'VPNGatewaySKU' = $gateway.Sku.Name
                'AverageBandwidth' = $util_mbps
                 }
                  


if($util_mbps -le 100){
if($Info.VPNGatewaySKU -ne 'Basic'){$Info | Add-Member -MemberType Noteproperty -Name "RecommendedSKU" -Value 'Basic'  }
}
elseif($util_mbps -gt 100 -and $util_mbps -le 650){
if($Info.VPNGatewaySKU -ne 'VpnGw1'){$Info | Add-Member -MemberType Noteproperty -Name "RecommendedSKU" -Value 'VpnGw1'  }

}
elseif($util_mbps -gt 650 -and $util_mbps -le 1000){
if($Info.VPNGatewaySKU -ne 'VpnGw2'){$Info | Add-Member -MemberType Noteproperty -Name "RecommendedSKU" -Value 'VpnGw2'  }
}
elseif($util_mbps -gt 1000 -and $util_mbps -le 1250){
if($Info.VPNGatewaySKU -ne 'VpnGw3'){$Info | Add-Member -MemberType Noteproperty -Name "RecommendedSKU" -Value 'VpnGw3'  }
}
elseif($util_mbps -gt 1250 -and $util_mbps -le 5000){
if($Info.VPNGatewaySKU -ne 'VpnGw4'){$Info | Add-Member -MemberType Noteproperty -Name "RecommendedSKU" -Value 'VpnGw4'  }
}
elseif($util_mbps -gt 5000 -and $util_mbps -le 10000){
if($Info.VPNGatewaySKU -ne 'VpnGw5'){$Info | Add-Member -MemberType Noteproperty -Name "RecommendedSKU" -Value 'VpnGw5'  }
}
else{
$Info | Add-Member -MemberType Noteproperty -Name "RecommendedSKU" -Value 'Bandwidth is much higher. Suggested to go with Expressroute'  
}
$vmobjs += $Info 
}
$vmobjs | Export-Excel $OutputFileName8 -AutoSize -AutoFilter -Append
$OutputFileName8 = $location + $OutputFileName8.Substring(2)
$files +=$OutputFileName8
#endregion


#region Use Storage Account
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "StorageAccount" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName9   = ".\Extraction\StorageAccount\storageaccountlist-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$stgaccounts = Get-azstorageaccount

 
 $stgobjs = @()
foreach ($stgacc in $stgaccounts)  
{

            $Info = [pscustomobject]@{
                'StorageAccountName'= $stgacc.StorageAccountName
                'ResourceGroupName' = $stgacc.ResourceGroupName
                'Kind' = $stgacc.Kind
                'AccessTier' = $stgacc.AccessTier
                'Location' = $stgacc.Location
                 }
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $Info.ResourceGroupName -AccountName $Info.StorageAccountName).Value[0]
$context = New-AzStorageContext -StorageAccountName $Info.StorageAccountName -StorageAccountKey $StorageAccountKey
$cool = Get-AzStorageContainer -Context $context | Where-Object{$_.LastModified.DateTime -lt $StorageAccountLastModifiedDateCool}
$archive = Get-AzStorageContainer -Context $context | Where-Object{$_.LastModified.DateTime -lt $StorageAccountLastModifiedDateArchive}
if($cool -ne $null -and $Info.Kind -eq "StorageV2"){
$Info | Add-Member -MemberType Noteproperty -Name "RecommendedAccessTier" -Value "Cool" -Force
   }
elseif($archive -ne $null -and $Info.Kind -eq "StorageV2"){
$Info | Add-Member -MemberType Noteproperty -Name "RecommendedAccessTier" -Value "Archive" -Force
}
else{
$Info | Add-Member -MemberType Noteproperty -Name "RecommendedAccessTier" -Value "No Recommendation" -Force

}
            $stgobjs += $Info   

 

        }  

 

# same variable is printed to a variable having the full info after the loop has ended
$stgobjs |  Export-Excel -Path $OutputFileName9 -AutoSize -AutoFilter 
$OutputFileName9 = $location + $OutputFileName9.Substring(2)
$files +=$OutputFileName9
#endregion


#region  Identify the suitable VMs for Reserved Instances

#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "VMwithReservedInstances" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName10   = ".\Extraction\VMwithReservedInstances\VMList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$VMs = Get-AzVM 


$vmOutput = @() 
$VMs | ForEach-Object {  
    $tmpObj = New-Object -TypeName PSObject 
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Name" -Value $_.Name
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Size" -Value $_.HardwareProfile.VmSize 
    $size = $_.HardwareProfile.VmSize
    $cores = (get-azvmsize -Location $_.Location | ?{ $_.Name -eq $size }).NumberOfCores
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Cores" -Value $cores  
    $memory = (get-azvmsize -Location $_.Location | ?{ $_.Name -eq $size }).MemoryInMB
    $tmpObj | Add-Member -MemberType Noteproperty -Name "VM Memory(MB)" -Value $memory 
    $tmpObj | Add-Member -MemberType Noteproperty -Name "ResourceGroup" -Value $_.ResourceGroupName
    $checkautoshutdown = (Get-AzResource -ResourceId ("/subscriptions/{0}/resourceGroups/{1}/providers/microsoft.devtestlab/schedules/shutdown-computevm-{2}" -f $SubscriptionId,$tmpObj.ResourceGroup,$tmpObj.'VM Name') -ErrorAction SilentlyContinue)
    if ((($tmpObj.'VM Name').ToLower() -match "test") -or (($tmpObj.'VM Name').ToLower() -match "dev")){
    Write-Host "I am in if"
    $tmpObj | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "No Recommendation " -Force
    }
    elseif($checkautoshutdown -ne $null){
    $tmpObj | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "No Recommendation" -Force
    }
    else{
    Write-Host "I am in else"
    $tmpObj | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Go for Reserved Instance to save cost. Check PaasReservation.doc for reference " -Force
    }
    $vmOutput += $tmpObj 
} 
$vmOutput | Export-Excel $OutputFileName10 -AutoSize -AutoFilter -Append
$OutputFileName10 = $location + $OutputFileName10.Substring(2)
$files +=$OutputFileName10
#endregion


#region  Identify the suitable RI for Reserved Instances on Disks/Storage


#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "Disk&StoragewithReservedInstances" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName11   = ".\Extraction\Disk&StoragewithReservedInstances\DiskList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
$OutputFileName12   = ".\Extraction\Disk&StoragewithReservedInstances\StorageList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"

#endregion
$list=@()
$disks = Get-AzDisk
$info = $disks | Select-Object Name, ResourceGroupName, @{l='ManagedBy';e={$_.ManagedBy.Split('/')[-1]}}, OsType, Location 
foreach($inf in $info){
if ((($inf.Name).ToLower() -match "test") -or (($inf.Name).ToLower() -match "dev")){
#Write-Host "I am in if"
$inf | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "No Recommendation " -Force
}
else{
#Write-Host "I am in else"
$inf | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Go for Reserved Instance to save cost. Check Storage/DiskReservation.doc for reference " -Force
}
$list += $Inf   

}
 
$list | Export-Excel $OutputFileName11 -AutoSize -AutoFilter



$stgaccounts = Get-azstorageaccount

 
 $stgobjs = @()
foreach ($stgacc in $stgaccounts)  
{
            $Info = [pscustomobject]@{
                'StorageAccountName'= $stgacc.StorageAccountName
                'ResourceGroupName' = $stgacc.ResourceGroupName
                'Kind' = $stgacc.Kind
                'AccessTier' = $stgacc.AccessTier
                'Location' = $stgacc.Location
                 'SKUName' = $stgacc.Sku.Name
                 }

 
if ((($info.StorageAccountName).ToLower() -match "test") -or (($info.StorageAccountName).ToLower() -match "dev")){
#Write-Host "I am in if"
$info | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "No Recommendation " -Force
}
else{
#Write-Host "I am in else"
$info | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Go for Reserved Instance to save cost. Check Storage/DiskReservation.doc for reference " -Force
}
            $stgobjs += $Info   

 

        }  

 

# same variable is printed to a variable having the full info after the loop has ended
$stgobjs |  Export-Excel -Path $OutputFileName12 -AutoSize -AutoFilter 
$OutputFileName11 = $location + $OutputFileName11.Substring(2)
$OutputFileName12 = $location + $OutputFileName12.Substring(2)
$files +=$OutputFileName11
$files +=$OutputFileName12


#endregion


#region Remove unallocated unmanaged VHDs
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "UnallocatedUnManagedVHDs" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName13   = ".\Extraction\UnallocatedUnManagedVHDs\VHDList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$deleteUnattachedVHDs=0


$storageAccounts = Get-AzStorageAccount
foreach($storageAccount in $storageAccounts){
    $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName)[0].Value
    $context = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey $storageKey
    $containers = Get-AzStorageContainer -Context $context
    foreach($container in $containers){
        $blobs = Get-AzStorageBlob -Container $container.Name -Context $context
        #Fetch all the Page blobs with extension .vhd as only Page blobs can be attached as disk to Azure VMs
        $blobs | Where-Object {$_.BlobType -eq 'PageBlob' -and $_.Name.EndsWith('.vhd')} | ForEach-Object { 
            #If a Page blob is not attached as disk then LeaseStatus will be unlocked
            if($_.ICloudBlob.Properties.LeaseStatus -eq 'Unlocked'){
                    if($deleteUnattachedVHDs -eq 1){
                        Write-Host "Deleting unattached VHD with Uri: $($_.ICloudBlob.Uri.AbsoluteUri)"
                       # $_ | Remove-AzStorageBlob -Force
                        Write-Host "Deleted unattached VHD with Uri: $($_.ICloudBlob.Uri.AbsoluteUri)"
                    }
                    else{
                        #Write-Host "Name - " $_.ICloudBlob.Name
                        #Write-Host "URI - " $_.ICloudBlob.Uri.AbsoluteUri
                        [PSCustomObject]@{
                            VHDName = $_.ICloudBlob.Name
                            StorageAccountName = (($_.ICloudBlob.Uri.AbsoluteUri).Split('/')[2].Split('.')[0])
                            ContainerName = (($_.ICloudBlob.Uri.AbsoluteUri).Split('/')[3].Split('.')[0])
                            VHDURI = $_.ICloudBlob.Uri.AbsoluteUri
                            Recommendations = "Delete the vhd"

                            } | Export-Excel -Path $OutputFileName13 -AutoSize -AutoFilter -Append
                    }
            }
        }
    }
}
$OutputFileName13 = $location + $OutputFileName13.Substring(2)
$files +=$OutputFileName13
#endregion


#region Leverage Hybrid benefits on license cost
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "VMHybridBenefit" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName14   = ".\Extraction\VMHybridBenefit\VMHybridBenefit-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion


Get-AzVM|Select-Object ResourceGroupName, Name, Location, @{l='osType';e={$_.StorageProfile.osDisk.osType}}, LicenseType, @{l='RecommendedLicenseType';e={if(($_.LicenseType -eq $null) -and ($_.StorageProfile.osDisk.osType -eq "Windows")){"Windows_Server"}else{"Either OS is other than Windows or License Already Exist"}}} | Export-Excel -Path $OutputFileName14 -AutoSize -AutoFilter 
$OutputFileName14 = $location + $OutputFileName14.Substring(2)
$files +=$OutputFileName14

#endregion


#region Use Deployment Slots for Prod/QA/Test of the web apps rather than using different App service Plans
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "DeploymentSlotsAppservice" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName15   = ".\Extraction\DeploymentSlotsAppservice\AppService-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$appserviceplan = Get-AzAppServicePlan
$report = @()
foreach($a_plan in $appserviceplan)
{
$webapps1 = Get-AzWebApp -AppServicePlan $a_plan

foreach($wa in $webapps1){
$info = "" | select-object AppServiceName,AppServiceResourceGroup,AppServicePlanName,AppServicePlanResourceGroup, Location,Kind,AppServicePlanSkuName,AppServicePlanSkuTier
$info.AppServiceName = $wa.Name
$info.AppServiceResourceGroup = $wa.ResourceGroup
$info.AppServicePlanName = $a_plan.Name
$info.AppServicePlanResourceGroup = $a_plan.ResourceGroup
$info.Location = $a_plan.Location
$info.Kind = $a_plan.Kind
$info.AppServicePlanSkuName = $a_plan.Sku.Name
$info.AppServicePlanSkuTier = $a_plan.Sku.Tier

if ((($info.AppServiceName).ToLower() -match "test") -or (($info.AppServiceName).ToLower() -match "uat")){
#Write-Host "I am in if"
$info | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Recommended to use deployment slot when moving for other environemnts " -Force
$info | Add-Member -MemberType Noteproperty -Name "DeploymentSlotName" -Value "EnterValue " -Force

}
elseif(($info.AppServiceName).ToLower() -match "dev"){
$info | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Recommended to not to use deployment slots " -Force
$info | Add-Member -MemberType Noteproperty -Name "DeploymentSlotName" -Value "NA" -Force

}
else{
#Write-Host "I am in else"
$info | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "No Recommendation " -Force
$info | Add-Member -MemberType Noteproperty -Name "DeploymentSlotName" -Value "NA" -Force

}

$report += $info

}

} 
$report |  Export-Excel -Path $OutputFileName15 -AutoSize -AutoFilter
$OutputFileName15 = $location + $OutputFileName15.Substring(2)
$files +=$OutputFileName15
#endregion


#region  Prefer LRS (locally redundant storage) to other replication options


#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "RecoveryServiceVaultRedundancy" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName16   = ".\Extraction\RecoveryServiceVaultRedundancy\Vault-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion
$vaults = Get-azrecoveryservicesvault 
$vaultlist = @()
foreach($vault in $vaults){
$redundancy = $null
$redundancy = (Get-AzRecoveryServicesBackupProperties -Vault $vault).BackupStorageRedundancy

 

$Info = [pscustomobject]@{
                'VaultName'= $vault.Name
                'ResourceGroupName' = $vault.ResourceGroupName
                'Location' = $vault.Location
                'Redundancy' = $redundancy
                
                 }

            if($Info.Redundancy -eq "GeoRedundant"){
            $Info | Add-Member -MemberType Noteproperty -Name "RecommendedRedundancy" -Value "LocallyRedundant"
            
            
            } 
            else{
            $Info | Add-Member -MemberType Noteproperty -Name "RecommendedRedundancy" -Value "No Recommendation"
         
            }

            $vaultlist += $Info   
        }  

 

# same variable is printed to a variable having the full info after the loop has ended
$vaultlist| Export-Excel $OutputFileName16 -AutoSize -AutoFilter 
$OutputFileName16 = $location + $OutputFileName16.Substring(2)
$files +=$OutputFileName16
#endregion


#region Leverage Reservation on Azure SQL Databases (vCores based), Azure Cosmos DB, Azure SQL Datawarehouse and Azure Databricks 


#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "ReservationOnPaaSResources" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName17   = ".\Extraction\ReservationOnPaaSResources\PaaSResources-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$resourcetypes = @("Microsoft.DocumentDB/databaseAccounts","Microsoft.Databricks/workspaces","Microsoft.DataFactory/factories","Microsoft.Sql/managedInstances","Microsoft.Sql/servers","Microsoft.Sql/servers/databases","Microsoft.Sql/instancePools")
$resourceobjs = @()
foreach($resourcetype in $resourcetypes){
#$resourcetype = "Microsoft.DocumentDB/databaseAccounts" 
$database = Get-AzResource -ResourceType $resourcetype
if($database -ne $null){
$Info = [pscustomobject]@{
                'Name'= $database.Name
                'ResourceGroupName' = $database.ResourceGroupName
                'Location' = $database.Location
                'ResourceID' = $database.Id
               
                 }
if ((($info.Name).ToLower() -match "test") -or (($info.Name).ToLower() -match "dev")){
#Write-Host "I am in if"
$info | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "No Recommendation " -Force
}
else{
#Write-Host "I am in else"
$info | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Go for Reserved Instance to save cost. Check PaasReservation.doc for reference " -Force
}
            $resourceobjs += $Info   
        }  
        }
$resourceobjs| Select-Object Name,ResourceGroupName,Location,ResourceID,Recommendation | Export-Excel $OutputFileName17 -AutoSize -AutoFilter
$OutputFileName17 = $location + $OutputFileName17.Substring(2)
$files +=$OutputFileName17
#endregion


#region Consider joining multiple databases that have varying and unpredictable usage demands to an Azure SQL Database elastic pool.


#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "MultipleDatabases" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName18   = ".\Extraction\MultipleDatabases\PaaSResources-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion
$servers = Get-AzSqlServer
$resourceobjs = @()
foreach($server in $servers)
    {

    $databases = Get-AzSqlDatabase -ServerName $server.ServerName -ResourceGroupName $server.ResourceGroupName
    
    if($databases.Count -gt 1)
        {
        foreach($database in $databases)
            {
                 $Info = [pscustomobject]@{
                'Name'= ($database.DatabaseName)
                'SQLServerName' = ($server.ServerName)
                'ResourceGroupName' = ($server.ResourceGroupName)
                'Location' = ($database.Location)}
            $metric = Get-AzMetric -ResourceId $database.ResourceId  -MetricName "cpu_percent" -StartTime $startdate -EndTime $enddate -WarningAction SilentlyContinue
            $average = ($metric.Data.Average | Measure-Object -Average).Average
            $Info  | Add-Member -MemberType Noteproperty -Name "Average" -Value $average
            if ($average -lt 50)
            {
                $Info  | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Recommended for elastic pool"
            
            
            }
            else
            {
            
                $Info  | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Not Recommended for elastic pool" 
                #If all the databases are coming up as recommended for elastic pool, highly likely to go with elastic pool
            
            }
            $resourceobjs += $Info  
            }
     
     
     
     
     
     
     }
     else{
     $Infodb = [pscustomobject]@{
                'Name'= ($databases.Name).Split('/')[1]
                'SQLServerName' = $server.ServerName
                'ResourceGroupName' = $server.ResourceGroupName
                'Location' = $databases.Location
                
     
     }
     $metric = Get-AzMetric -ResourceId $databases.ResourceId  -MetricName "cpu_percent" -StartTime $startdate -EndTime $enddate -WarningAction SilentlyContinue
    $average = ($metric.Data.Average | Measure-Object -Average).Average
    $Info  | Add-Member -MemberType Noteproperty -Name "Average" -Value $average
     $Info  | Add-Member -MemberType Noteproperty -Name "Recommendation" -Value "Not Recommended for elastic pool"

     $resourceobjs += $Info 
}



}
$resourceobjs | Export-Excel $OutputFileName18 -AutoSize -AutoFilter
$OutputFileName18 = $location + $OutputFileName18.Substring(2)
$files +=$OutputFileName18
#endregion


#region Consider downscaling any App Service Plan that stays lower than 50% utilization, Change the app service plans to Dev/Test Plan like (F/B/D series) for the apps that particularly are used for testing,Save on App Services Isolated stamp fees by buying a 3-year reserved instance for isolated App Service Plans 
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "DownscalingAppService" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName19   = ".\Extraction\DownscalingAppService\AppService-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$appserviceplan = Get-AzAppServicePlan
$report = @()
foreach($a_plan in $appserviceplan)
{
$webapps1 = Get-AzWebApp -AppServicePlan $a_plan

foreach($wa in $webapps1){
$info = "" | select-object AppServiceName,AppServiceResourceGroup,AppServicePlanName,AppServicePlanResourceGroup, AppServicePlanSkuName,AppServicePlanSkuTier, Location,Kind,Utilization
$info.AppServiceName = $wa.Name
$info.AppServiceResourceGroup = $wa.ResourceGroup
$info.AppServicePlanName = $a_plan.Name
$info.AppServicePlanResourceGroup = $a_plan.ResourceGroup
$info.AppServicePlanSkuName = $a_plan.Sku.Name
$info.AppServicePlanSkuTier = $a_plan.Sku.Tier
$info.Location = $a_plan.Location
$info.Kind = $a_plan.Kind
$metric = Get-AzMetric -ResourceId $a_plan.Id  -MetricName "CpuPercentage" -StartTime $startdate -EndTime $enddate -WarningAction SilentlyContinue
$average = ($metric.Data.Average | Measure-Object -Average).Average
$info.Utilization = $average
$IsolatedTier = @("I1","I2","I3")
if($average -ne $null -and $info.AppServicePlanSkuName -ne $IsolatedTier){
        if($average -lt 50){
                for ($i=0; $i -lt $AppServiceTier.length; $i++) { #$AppServiceTier = @("S1","Y1","F1") $AppServiceTierName = @("Standard","Dynamic","Free")
                    #$AppServiceSize = @{S1 = "B1";S2 = "B2";S3 = "B3";P1v2 = "B1"; P2v2 = "B2";P3v2 = "B3"} #This recommendation is going to be hard-coded since we dont want anyone else to change these values, as these values are outcomes of deep analysis
	               #$AppServiceSizeName = @{Standard = "Basic";Premium = "Basic"} #This recommendation is going to be hard-coded since we dont want anyone else to change these values, as these values are outcomes of deep analysis

                     if($AppServiceTier[$i] -match $info.AppServicePlanSkuName){
                            if($i -eq "0"){
                                            if ((($info.AppServiceName).ToLower() -match "test") -or (($info.AppServiceName).ToLower() -match "dev") -and $AppServiceSize[$Info.AppServicePlanSkuName] -ne $null ){
                                            $info.AppServiceName
                                            $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUTier" -Value $AppServiceSize[$Info.AppServicePlanSkuName] -Force
                                            $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUName" -Value $AppServiceSizeName[$Info.AppServicePlanSkuTier] -Force
                                            $info | Add-Member -MemberType Noteproperty -Name "Reserved Instance" -Value "NA" -Force

                                            } 

                                            else{ 
                                            $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUTier" -Value "No Recommendation" -Force
                                            $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUName" -Value "No Recommendation" -Force
                                            $info | Add-Member -MemberType Noteproperty -Name "Reserved Instance" -Value "NA" -Force
                                            }
                            }
                            else{
                                $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUTier" -Value $AppServiceTier[$i-1] -Force
                                $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUName" -Value $AppServiceTierName[$i-1] -Force }
                                $info | Add-Member -MemberType Noteproperty -Name "Reserved Instance" -Value "NA" -Force
                                }
                        }
                    }
        else{
         $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUTier" -Value "No Recommendation" -Force
         $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUName" -Value "No Recommendation" -Force
         $info | Add-Member -MemberType Noteproperty -Name "Reserved Instance" -Value "NA" -Force
            }
}
elseif($info.AppServicePlanSkuName -eq $IsolatedTier){
        $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUTier" -Value "Go For 3 years Reserved Instance, Refer to the IsolatedReservedAppservice.doc" -Force
        $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUName" -Value "Go For 3 years Reserved Instance, Refer to the IsolatedReservedAppservice.doc" -Force
        $info | Add-Member -MemberType Noteproperty -Name "Reserved Instance" -Value "Yes" -Force
}
else{
        $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUTier" -Value "Utilization Not Captured, Recommend Manually" -Force
        $info | Add-Member -MemberType Noteproperty -Name "RecommendedSKUName" -Value "Utilization Not Captured, Recommend Manually" -Force
         $info | Add-Member -MemberType Noteproperty -Name "Reserved Instance" -Value "NA" -Force

}
$report += $info

}
}


$report |  Export-Excel -Path $OutputFileName19 -AutoSize -AutoFilter 
$OutputFileName19 = $location + $OutputFileName19.Substring(2)
$files +=$OutputFileName19
#endregion


#region Set a daily cap for your Application Insights
#region To create Folder
$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
New-Item -Path "C:\Extraction\" -Name "ApplicationInsight" -ItemType "directory" -Force
#endregion

 

#region Input
$OutputFileName20  = ".\Extraction\ApplicationInsight\ApplicationInsight-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

 

$appinsights = Get-AzApplicationInsights  
$applicationinsightobjs = @()

 

foreach($appinsight in $appinsights){
$properties = $null
$properties = Set-AzApplicationInsightsDailyCap -ResourceGroupName $appinsight.ResourceGroupName -Name $appinsight.Name
if($properties.Cap -gt 50)
{
$newcap = 50
}
$Info = [pscustomobject]@{
                'AppInsightsName'= $appinsight.Name
                'ResourceGroupName' = $appinsight.ResourceGroupName
                'DailyCap(in GB)' = $properties.Cap
                'Recommendation' = "Daily recommended Cap(in GB) is $($newcap)GB . It is suggested to Set Alerts if data exceeds daily cap and then the Value can be changed"
                 }
            $applicationinsightobjs += $Info   
}

 

$applicationinsightobjs |  Export-Excel -Path $OutputFileName20 -AutoSize -AutoFilter 
$OutputFileName20 = $location + $OutputFileName20.Substring(2)
$files +=$OutputFileName20
#endregion


#region Empty App Service Plan
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "EmptyAppServicePlan" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName21   = ".\Extraction\EmptyAppServicePlan\AppService-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion

$appserviceplan = Get-AzAppServicePlan
$report = @()
foreach($a_plan in $appserviceplan)
{
if($a_plan.NumberOfSites -eq '0')
{
$info = "" | select-object AppServicePlanName,AppServicePlanResourceGroup, NoofAppspresent, Location, Recommendation
$info.AppServicePlanName = $a_plan.Name
$info.AppServicePlanResourceGroup = $a_plan.ResourceGroup
$info.NoofAppspresent = $a_plan.NumberOfSites
$info.Location = $a_plan.Location
$info.Recommendation = 'Recommended for Deletion'
$report += $info
} 
}
$report |  Export-Excel -Path $OutputFileName21 -AutoSize -AutoFilter
$OutputFileName21 = $location + $OutputFileName21.Substring(2)
$files +=$OutputFileName21

#endregion


#region Master Sheet Creation
#region To create Folder

$path = "C:\Extraction"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

New-Item -Path "C:\Extraction\" -Name "MasterSheet" -ItemType "directory" -Force
#endregion


#region Input
$OutputFileName22   = ".\Extraction\MasterSheet\ResourceList-$($SubscriptionName.Replace('/','_'))-$(Get-Date -Format 'ddMMMMyyyy_hh-mm-ss_tt').xlsx"
#endregion





$resources = Get-AzResource 
$report = @()
foreach ($resource in $resources) {
    $info = "" | select-object "Name","SubscriptionName","ResourceID","ResourceType", "SOP No.", "Category", "CurrentCost($)", "Optimized Cost", "Current Config", "Suggested Config", "Comments"
    $info.Name = $resource.Name
    $info.SubscriptionName = $SubscriptionName
    $info.ResourceID = $resource.ResourceId
    $info.ResourceType = $resource.ResourceType
    $sum = 0
    $array = (Get-AzConsumptionUsageDetail -InstanceName $Info.Name -StartDate ((Get-Date).adddays(-30)) -EndDate  (Get-Date)).PretaxCost
    $array |  Foreach { $sum += $_}
    $info.'CurrentCost($)' = $sum

    $report += $info

        }

$report | Export-Excel $OutputFileName22 -AutoSize -AutoFilter -WorksheetName "MasterSheet" -BoldTopRow -FreezeTopRow 
$OutputFileName22 = $location + $OutputFileName22.Substring(2)
$files +=$OutputFileName22


#endregion


#region
$OutputFileName24 = ".\Extraction\ExtractionPath.txt"
$files | Out-File $OutputFileName24
#endregion




