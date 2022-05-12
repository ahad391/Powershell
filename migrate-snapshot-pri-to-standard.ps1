Connect-AzAccount
$sourceSubscriptionId='hgfghfhvhjvhj'
$sourceResourceGroupName='SIT-RG'
$snapshotName='ttlsitblockchainpeer-os-03-06-21'
Select-AzSubscription -SubscriptionId $sourceSubscriptionId
$snapshot= Get-AzSnapshot -ResourceGroupName $sourceResourceGroupName -Name $snapshotName
$targetResourceGroupName='MI-SNAP'
$snapshotConfig = New-AzSnapshotConfig -SourceResourceId $snapshot.Id -Location $snapshot.Location -CreateOption Copy -SkuName Standard_LRS
New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $targetResourceGroupName 