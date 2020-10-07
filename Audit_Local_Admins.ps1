$timeStamp = Get-Date -Format yyyyMMdd-HHmm
$Computers = Get-ADComputer -filter "OperatingSystem -like '*10*' -or OperatingSystem -like '*8*' -or OperatingSystem -like '*7*' -and Enabled -eq 'True'" -Properties Enabled, OperatingSystem, LastLogonDate, CanonicalName | Where-Object -Property LastLogonDate -gt (Get-Date).AddMonths(-6)

$PingResult = foreach ($PC in $Computers) {
    $TestResult = Test-NetConnection -ComputerName $PC.DNSHostName -CommonTCPPort WINRM
    [PSCustomObject]@{
        ComputerName = $PC.Name
        OperatingSystem = $PC.OperatingSystem
        CanonicalName = $PC.CanonicalName
        TcpTestSucceeded = $TestResult.TcpTestSucceeded
        PingSucceeded = $TestResult.PingSucceeded
    }
}

$PingResult | Export-Csv -Path C:\TEMP\PingResult-$timeStamp.csv -NoTypeInformation

$onlineComputers = $PingResult | Where-Object -Property TcpTestSucceeded -eq $true

Invoke-Command -ComputerName $onlineComputers  -ScriptBlock {
    $admins = net localgroup administrators | Where-Object -FilterScript {$_ -AND $_ -notmatch "command completed successfully" -and $_ -notlike 'MINEDU\Domain Admins' -and $_ -notlike 'MINEDU\MOE_ADMINS_WORKSTATION' -and $_ -notlike 'Administrator' -and $_ -notlike 'monadmin'} | Select-Object -skip 4
    foreach ($member in $admins) {
        New-Object PSObject -Property @{
            Computername = $env:COMPUTERNAME
            OS = (Get-WmiObject -Class win32_operatingsystem).caption
            LocalAdminsAdmins = $member
        }
    }
}  | Select ComputerName, OS, LocalAdmins | Export-CSV C:\TEMP\LocalAdminsReport-$timeStamp.csv -NoTypeInformation
