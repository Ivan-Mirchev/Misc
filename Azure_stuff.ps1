break

# Login to Azure
Login-AzureRmAccount 

# Create Resource Group

$RGName = 'ITGM-AzurePowerShell'
$Location = 'North Europe'

New-AzureRmResourceGroup -Name $RGName -Location $Location -Verbose

# Create Storage Account using splatting 
# Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.

$StorageAccountName = 'itglazurepowershell'
$StorageAccountType = 'Standard_LRS' # Validate Set

$storageAccountProps = @{
    Name = $StorageAccountName
    ResourceGroupName = $RGName
    Type = 'Standard_LRS'
    Location = $Location
}

New-AzureRmStorageAccount @storageAccountProps -Verbose





#remove all

# Remove Resource Group
Get-AzureRmResourceGroup -Name $RGName
Remove-AzureRmResourceGroup -Name $RGName -Verbose

# Remove Storage Account
Get-AzureRmStorageAccount -Name $StorageAccountName -ResourceGroupName $RGName 
Remove-AzureRmStorageAccount -Name $StorageAccountName -ResourceGroupName $RGName



