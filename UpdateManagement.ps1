#******************************************************************************************* 
# Sign in to your Azure account 
#******************************************************************************************* 
Connect-AzAccount 
#******************************************************************************************* 
# Get your AD subscription ID 
#******************************************************************************************* 
Get-AzSubscription | Sort-Object -Property Name,SubscriptionID | Select-Object -Property Name,SubscriptionID 
#******************************************************************************************* 
# Set your Azure subscription. Replace everything within the quotes, 
# including the < and > characters, with the correct SubscriptionID 
#******************************************************************************************* 
$subscrID="3e76b9d6-246c-4d68-b5e4-6dfd3b6e35b3" # Microsoft Azure Enterprise - Ministru of Education
Select-AzSubscription -SubscriptionID $subscrID 
#******************************************************************************************* 
# Set parameters 
#******************************************************************************************* 
$rgName="MOE-UpdateManager-RG" 
$locName="West Europe" 
$AutoAccName="MOE-UpdateManager-Automation" 
$WSName="MOE-UpdateManager1-WS" 
$solution="Updates" 
#******************************************************************************************* 
# Create new resource group. Adjust location if you want a different one 
#******************************************************************************************* 
New-AzResourceGroup -Name $rgName -Location $locName 
New-AzAutomationAccount -Name $AutoAccName -Location $locName -ResourceGroupName $rgName 
New-AzOperationalInsightsWorkspace -Location $locName -Name $WSName -Sku Standard -ResourceGroupName $rgName 
Set-AzOperationalInsightsIntelligencePack -ResourceGroupName $rgName -WorkspaceName $WSName -IntelligencePackName $solution -Enabled $true 

#install agent
MMASetup-AMD64.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID="<Workspace ID>" OPINSIGHTS_WORKSPACE_KEY="<Workspace key>" OPINSIGHTS_PROXY_URL=<FQDN:PORT> AcceptEndUserLicenseAgreement=1 

# Add a workspace in Azure commercial using PowerShell
# https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-manage#add-a-workspace-in-azure-commercial-using-powershell
$workspaceId = "19152477-bf9f-4bdf-a1e6-6ff8e124f0b8"
$workspaceKey = "R9VPx23yt7FExcpNTt10HlFFaxpTL0h2ZhQSD+02Wt2z7+bnEu1j+/oNZRRlQExM8V9G36DHB19OWuW5QNs/Yw=="
$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$mma.AddCloudWorkspace($workspaceId, $workspaceKey)
$mma.ReloadConfiguration()

# Remove a workspace using PowerShell
$workspaceId = "<Your workspace Id>"
$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$mma.RemoveCloudWorkspace($workspaceId)
$mma.ReloadConfiguration()