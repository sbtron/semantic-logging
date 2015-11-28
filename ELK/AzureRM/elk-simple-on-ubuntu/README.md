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

#Notes & Limitations
- Currently only supports Logstash version 1.4.2


