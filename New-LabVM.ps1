function New-LabVM {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$VMName, 
        [int]$VMRAM = 1GB,
        [int]$VMPRocessorCount = 2,
        [ValidateSet("Windows Server 2019 - FULL GUI", "Windows Server 2019 - Server Core")]
        [string]$VMOS = "Windows Server 2019 - FULL GUI", 
        [string]$VMSwitch = 'LAB_LAN'


    )
    $ErrorActionPreference = 'Stop'
    try {
        switch ($VMOS) {
            "Windows Server 2019 - FULL GUI" {$GoldenVHDPath = 'D:\VMs\GOLDEN_WS2019_GUI\Virtual Hard Disks\GOLDEN_WS2019_GUI_OS.vhdx'}
            "Windows Server 2019 - Server Core" {$GoldenVHDPath = 'D:\VMs\GOLDEN_WS2019_SC\Virtual Hard Disks\GOLDEN_WS2019_SC_OS.vhdx'}
        }
        # Prepare and copy VHDx
        $VMVHDPath = 'D:\VMs\' + $VMName  + '\Virtual Hard Disks\' + $VMName + '_OS.vhdx'
        New-Item -ItemType Directory -Path (Split-Path -Path $VMVHDPath)
        Copy-Item -Path $GoldenVHDPath -Destination $VMVHDPath
    
        # Create and set VM
        New-VM -Name $VMName -MemoryStartupBytes $VMRAM -SwitchName $VMSwitch -Path D:\VMs -Generation 2 -VHDPath $VMVHDPath
        Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false
        Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MaximumBytes 4GB
        Set-VMProcessor -VMName $VMName -Count $VMPRocessorCount
    }
    catch {
        Write-Host ERROR: $_.exception.message -BackgroundColor DarkRed -ForegroundColor White
    }
}