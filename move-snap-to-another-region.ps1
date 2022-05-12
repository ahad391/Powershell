Connect-AzAccount
Set-AzContext -Subscription "njkndskjds ckjds c"

# SOURCE
$SnapshotResourceGroup = "MOVE-SNAP"
$SnapshotName = "DCAF-WEB_APP-SOUTH"



# DESTINATION
$StorageAccount = "southwebappimage"
$StorageAccountBlob = "image"
$storageaccountResourceGroup = "central"
$vhdname = "image-webapp"


#SA_KEY
$StorageAccountKey = (Get-AzStorageAccountKey -Name $StorageAccount -ResourceGroupName $StorageAccountResourceGroup).value[0]
$snapshot = Get-AzSnapshot -ResourceGroupName $SnapshotResourceGroup -SnapshotName $SnapshotName



#GRANTING ACCESS
$snapshotaccess = Grant-AzSnapshotAccess -ResourceGroupName $SnapshotResourceGroup -SnapshotName $SnapshotName -DurationInSecond 3600 -Access Read -ErrorAction stop

$DestStorageContext = New-AzStorageContext –StorageAccountName $storageaccount -StorageAccountKey $StorageAccountKey -ErrorAction stop



Write-Output "START COPY"
Start-AzStorageBlobCopy -AbsoluteUri $snapshotaccess.AccessSAS -DestContainer $StorageAccountBlob -DestContext $DestStorageContext -DestBlob "$($vhdname).vhd" -Force -ErrorAction stop
Write-Output "END COPY"


#Percentage-progress#

Get-AzureStorageBlobCopyState -Container $StorageAccountBlob -Blob “$($vhdname).vhd” -Context $DestStorageContext -WaitForComplete