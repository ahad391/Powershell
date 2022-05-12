#<CONNECT TO AZURE ACCOUNT USING Connect-AzAccount>
$subsid = Get-Content "D:\sub.txt"
foreach($subid in $subsid){
$sub = Select-AzSubscription -SubscriptionId $subid -TenantId "f750db26-d9ce-4a1a-8ee9-fa349759aa9c"
$subname = $sub.Subscription.Name
$subname
$VMS = Get-AzVM
foreach($vm in $VMS){
$vmname = $vm.Name
$vmrid = $vm.Id

$FILE = "D:\mvav"
$i = 0;

$stist =  Get-Date -Date "2021-10-01 00:00:00" 
$st = $stist.ToUniversalTime()
$etist =  Get-Date -Date "2021-10-30 00:00:00"
$et = $etist.ToUniversalTime()

$c =  Get-AzMetric -ResourceId $vmrid -MetricName "Percentage CPU" -DetailedOutput -StartTime $st -EndTime $et -TimeGrain 00.00:01:00 -AggregationType Average -WarningAction SilentlyContinue
foreach($n in $c.Data){
$average = $n.Average
if($average -eq $null){
$i = $i+1
}
}
Write-Host $vmname -ForegroundColor Yellow
Write-Host "$($i) minutes" -ForegroundColor Green
$hours = $i / 60;
$per = 100-(($hours/730)*100)
Write-Host "Percent available - $($per)" -ForegroundColor Cyan
$n |  Select-Object @{Name=’VM Name’;Expression={$vmname}},@{Name=’Avg Unavailability(min)’;Expression={$i}},@{Name=’Percentage’;Expression={$per}},@{Name=’Subscription’;Expression={$subname}} `
| Export-Csv $FILE -NoTypeInformation -Encoding ASCII -Append


}
}
