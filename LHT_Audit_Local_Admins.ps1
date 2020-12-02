$BackupCred = Get-Credential 'ads.dlh.de\SVC_LHTW_Srv-Backup' 

$serverlist = Import-Csv -Path D:\SCRIPTS\SERVERLIST_BQN.csv, D:\SCRIPTS\SERVERLIST_BUD.csv, D:\SCRIPTS\SERVERLIST_MLA.csv, D:\SCRIPTS\SERVERLIST_SNN.csv, D:\SCRIPTS\SERVERLIST_SOF.csv | Where-Object -FilterScript {$_.os -notlike '*2008*'}  | Sort-Object -Property ComputerName 

$result = Invoke-Command -Credential $BackupCred -ComputerName  $serverlist.computername -ScriptBlock {
    $admins = net localgroup administrators | Where-Object -FilterScript {$_ -AND $_ -notmatch "command completed successfully" -and $_ -ne 'Administrator' -and $_ -ne 'ADS\Domain Admins' } | Select-Object -skip 4
    foreach ($user in $admins) {$adminList += "$user`n"}
    [PSCustomObject]@{
        # AdminList = $admins -join '; '
        AdminList = $adminList.Trim()
        'ADM_LHTW-ServiceAdmin-Server-all'  = $admins -contains 'ADS\ADM_LHTW-ServiceAdmin-Server-All'
        'SVC_LHTW-Srv-Patching' = $admins -contains 'ADS\SVC_LHTW-Srv-Patchin'
        'SVC_LHTW_Srv-Backup' = $admins -contains 'ADS\SVC_LHTW_Srv-Backup'
    }
}

# $result  | Select-Object -Property @{Name = 'Computername'; Expression = {$_.PSComputerName}}, 'ADM_LHTW-ServiceAdmin-Server-all', 'ads\SVC_LHTW-Srv-Patching', 'ads.dlh.de\SVC_LHTW_Srv-Backup', AdminList | Sort-Object -Property Computername | ft -AutoSize

$result  | Select-Object -Property @{Name = 'Computername'; Expression = {$_.PSComputerName}}, 'ADM_LHTW-ServiceAdmin-Server-all', 'SVC_LHTW-Srv-Patching', 'SVC_LHTW_Srv-Backup', AdminList | Sort-Object -Property Computername | Out-GridView


$result  | Select-Object -Property @{Name = 'Computername'; Expression = {$_.PSComputerName}}, 'ADM_LHTW-ServiceAdmin-Server-all', 'SVC_LHTW-Srv-Patching', 'SVC_LHTW_Srv-Backup', AdminList | Sort-Object -Property Computername | Export-Csv -Path C:\TEMP\LocalAdminsAudit.csv -NoTypeInformation