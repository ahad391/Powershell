Connect-AzAccount
Set-AzContext -subscription "42213922-7b9b-4f69-bc29-5e01018a6f86"
Select-AzSubscription -Subscription "42213922-7b9b-4f69-bc29-5e01018a6f86"

$r2cresorces=Get-AzResource -ResourceGroupName "exxat-data"

$regioname="West US"

$outputr2c= "C:" + "\" +"temp"+"\" +"sandeep" + "\" + "prod-stage" +"$DateTime" + ".xlsx" 

foreach($r2cresorce in $r2cresorces){

    if($r2cresorce.type -eq "microsoft.sql/servers/databases"){
    $r2cresorce.name
        #$region= if($r2cresorce.name -match "regioname"){"West US"}else{"PROD"}
        $days = "-30"
        $startDate = [datetime]::Today.AddDays($days)
        $endDate = [datetime]::Today
        $sqldbname=($r2cresorce.name -split "/")[-1]
        $sqldbrg= $r2cresorce.ResourceGroupName
        $sqlservername=($r2cresorce.name -split "/")[-2]
        if($sqldbname -eq "master"){}
        else{
        $dtu_consumption_percent_Average = 0.0
        $dtu_consumption_percent = Get-AzMetric -ResourceId $r2cresorce.Id -MetricName "dtu_consumption_percent" -AggregationType Average -DetailedOutput -StartTime $startDate -EndTime $endDate -TimeGrain 12:00:00 -WarningAction SilentlyContinue
        $dtu_consumption_percent_Average = [System.Math]::Round($(($dtu_consumption_percent.Data.Average | Measure-Object -Average).Average),2.2)
        $dtu_consumption_percent_Average

        $connection_failed_Average = 0.0
        $connection_failed = Get-AzMetric -ResourceId $r2cresorce.Id -MetricName "connection_failed" -AggregationType Total -DetailedOutput -StartTime $startDate -EndTime $endDate -TimeGrain 12:00:00 -WarningAction SilentlyContinue
        $connection_failed_Average = [System.Math]::Round($(($connection_failed.Data.Total | Measure-Object -Sum).Sum),2.2)
        $connection_failed_Average

        $deadlock_Average = 0.0
        $deadlock = Get-AzMetric -ResourceId $r2cresorce.Id -MetricName "deadlock" -AggregationType Total -DetailedOutput -StartTime $startDate -EndTime $endDate -TimeGrain 12:00:00 -WarningAction SilentlyContinue
        $deadlock_Average = [System.Math]::Round($(($deadlock.Data.Total | Measure-Object -Sum).Sum),2.2)
        $deadlock_Average

        $storage_percent_Average = 0.0
        $storage_percent = Get-AzMetric -ResourceId $r2cresorce.Id -MetricName "storage_percent" -AggregationType Average -DetailedOutput -StartTime $startDate -EndTime $endDate -TimeGrain 12:00:00 -WarningAction SilentlyContinue
        $storage_percent_Average = [System.Math]::Round($(($storage_percent.Data.Average | Measure-Object -Average).Average),2.2)
        $storage_percent_Average

         $r2cresorce | Select ResourceGroupName,Name,@{n="AVG-DTU percentage";e={$dtu_consumption_percent_Average}},
           @{n="Total-Failed Connections";e={$connection_failed_Average}},@{n="Total-Deadlocks";e={$deadlock_Average}},@{n="AVG-storage percentage";e={$storage_percent_Average}}|
        Export-Excel -Path $outputr2c -WorksheetName "sqldb" -Append -Verbose
        }
    }
    }