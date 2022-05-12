### VM Details ##
$sourceVM = -Name csclogin-GVM-14-02-2022  -ResourceGroupName csclogin-Disk-14-02-2022-Test

##Gallery Details ##
$resourceGroup = -Name 'csclogin-Disk-14-02-2022-Test' -Location 'Central India'
$gallery = -GalleryName 'csclogintest' -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location


$galleryImage = -GalleryName $gallery.Name `
-ResourceGroupName $resourceGroup.ResourceGroupName `
-Location $gallery.Location `
-Name 'csclogintest' `
-OsState Generalized `
-OsType Linux `
-Publisher 'csclogintest' `
-Offer 'NA' `
-Sku 'NA'

##Replication##
$region1 = @{Name='Central India';ReplicaCount=1}
   $region2 = @{Name='South India';ReplicaCount=2}
   $targetRegions = @($region1,$region2)

##Capture Image ##
New-AzGalleryImageVersion `
   -GalleryImageDefinitionName $galleryImage.Name`
   -GalleryImageVersionName '1.0.0' `
   -GalleryName $gallery.Name `
   -ResourceGroupName $resourceGroup.ResourceGroupName `
   -Location $resourceGroup.Location `
   -TargetRegion $targetRegions  `
   -Source $sourceVM.Id.ToString() `
   -PublishingProfileEndOfLifeDate '2030-12-01'