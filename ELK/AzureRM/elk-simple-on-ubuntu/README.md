# Install ELK on a Ubuntu machine and import Azure Diagnostics data 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsbtron%2Fsemantic-logging%2Felk%2FELK%2FAzureRM%2Felk-simple-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys and installs elastic search, logstash, and kibana on a single Ubuntu virtual machine and configures logstash to pull Azure diagnostics data from the diagnostics storage account. 
This is meant as a sample and isn't recommended for production loads. 
Uses elastic search install script from: https://github.com/Azure/azure-quickstart-templates/tree/master/elasticsearch.

Below are the parameters that the template expects:

|Name   |Description    |
|:---   |:---|
|adminUsername  |Name of the admin user of the machine. |
|adminPassword  |Admin password of the machine. |
|dnsNameForPublicIP |Public dns name for the virtual machine.   |
|existingDiagnosticsStorageAccountName  |Name of the diagnostics storage account.    |
|existingDiagnosticsStorageAccountKey  | The diagnostics storage account key is needed to enable logstash plugin to read data from the storage account. 
|diagnosticsTableNames    |The tables containing diagnostics data that you would like to import to ELK  |

## Updating logstash config on a running instance
Use the Set-AzureWADTableConfig.ps1 powershell script to update the logstash configuration on a running instance of Logstash.

	.\Set-AzureWADTableConfig.ps1 -VMName <VMNAme> -VMResourceGroup <VMResourceGroup> -DiagnosticsStorageAccount <DiagnosticsStorageAccountName> -DiagnosticsStorageAccountKey <DiagnosticsStorageAccountName> -DiagnosticsTables <TableNames>

The -DiagnosticsTables parameter is optional and accepts a ';' separated list of table names. If the parameter is not specified the script will default to using standard WAD table names - *WADPerformanceCountersTable;WADWindowsEventLogsTable;WADDiagnosticsInfrastructureLogsTable;WADLogsTable;*

## Linking to this template
You can link to this the ELK template by adding the following to the resources section. Through this approach you can easily setup the VMs where you application runs and also the ELK VM as part of one template deployment.

	{ 
     "apiVersion": "2015-01-01", 
     "name": "nestedTemplate", 
     "type": "Microsoft.Resources/deployments", 
     "properties": { 
       "mode": "incremental", 
       "templateLink": {
          "uri":"https://raw.githubusercontent.com/sbtron/semantic-logging/elk/ELK/AzureRM/elk-simple-on-ubuntu/azuredeploy.json",
          "contentVersion":"1.0.0.0"
       }, 
       "parameters": {
        "adminUsername": { "value": "[parameters('adminUsername')]" },
        "adminPassword": { "value": "[parameters('adminPassword')]" },
        "existingDiagnosticsStorageAccountName": { "value": "[variables('diagnosticsStorageName')]" },
        "existingDiagnosticsStorageAccountKey": { "value": "[listkeys(concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', variables('diagnosticsStorageResourceGroup'), '/providers/','Microsoft.Storage/storageAccounts/', variables('diagnosticsStorageName')), '2015-06-15').key1]" }
       }  
     } 
    } 

Make sure the base template includes the appropriate parameters for *adminUsername* and *adminPassword* and also defines the *diagnosticsStorageAccountName* and *diagnosticsStorageResourceGroup*. 

For example here is a simple windows VM with diagnostics turned on which is linked to the ELK template setup to collect diagnostics data from the Windows VM.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsbtron%2Fsemantic-logging%2Felk%2FELK%2FAzureRM%2Felk-simple-on-ubuntu%2Fvm-win-diagnostics-elk.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

##Notes & Limitations
- Currently only supports Logstash version 1.4.2


