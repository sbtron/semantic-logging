[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $VMName,

    [String] [Parameter(Mandatory = $true)]
    $VMResourceGroup,
    
    [String] [Parameter(Mandatory = $true)]  
    $DiagnosticsStorageAccount,

    [String] [Parameter(Mandatory = $true)]  
    $DiagnosticsStorageAccountKey,
    
    [String] [Parameter(Mandatory = $false)]  
    $DiagnosticsTables,

    [String] [Parameter(Mandatory = $false)]  
    $LogStashUpdateBashScript
)


Write-Host "VMName= $VMName"
Write-Host "VMResourceGroup= $VMResourceGroup"
Write-Host "DiagnosticsStorageAccount= $DiagnosticsStorageAccount"
Write-Host "DiagnosticsTables= $DiagnosticsTables"
if(!$DiagnosticsTables)
{
$DiagnosticsTables="WADPerformanceCountersTable;WADWindowsEventLogsTable;WADDiagnosticsInfrastructureLogsTable;WADLogsTable;"
Write-Host "Using default values for DiagnosticsTables= $DiagnosticsTables"
}
Write-Host "LogStashUpdateBashScript= $LogStashUpdateBashScript"
if(!$LogStashUpdateBashScript)
{
$LogStashUpdateBashScript = "https://raw.githubusercontent.com/sbtron/semantic-logging/elk/ELK/AzureRM/elk-simple-on-ubuntu/logstash-update-azurewadtable.sh"
Write-Host "Using default value for LogStashUpdateBashScript= $LogStashUpdateBashScript"
}

$VM = Get-AzureRMVM -ResourceGroupName $VMResourceGroup -Name $VMName
$ext_name = "CustomScriptForLinux"
$ext_publisher = "Microsoft.OSTCExtensions"
$ext_version = "1.4"
$timestamp=(Get-Date).Ticks



$Settings = '{
"fileUris" : ["'+ $LogStashUpdateBashScript+ '"],
"timestamp" : "'+ $timestamp+ '"
}'
$ProtectedSettings = '{
"commandToExecute" : "bash ./logstash-update-azurewadtable.sh -a '+$DiagnosticsStorageAccount+' -k '+$DiagnosticsStorageAccountKey+' -t '+$DiagnosticsTables+'"
}'

Write-Host "Removing any existing CustomScript extension"
For ($i=0;$i -lt $VM.Extensions.Count; $i++) 
{
    if ($VM.Extensions[$i].ExtensionType.ToString() -eq "CustomScriptForLinux")
    {
        Remove-AzureRmVMCustomScriptExtension -ResourceGroupName $VM.ResourceGroupName -VMName $VM.Name -Name $VM.Extensions[$i].Name -Force
    } 
}

Write-Host "Applying updated configuration"
Set-AzureRmVMExtension -ResourceGroupName $VM.ResourceGroupName -Location $VM.Location -VMName $VM.Name -Name $ext_name -Publisher $ext_publisher -ExtensionType $ext_name -TypeHandlerVersion $ext_version -SettingString $Settings -ProtectedSettingstring $ProtectedSettings