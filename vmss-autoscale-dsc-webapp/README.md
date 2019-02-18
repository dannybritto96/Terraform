# VM Scaleset with DSC and AutoScale extensions in an existing Application gateway using Terraform

The following template deploys a Windows VM Scale Set (VMSS) running an IIS .NET MVC application integrated with a pre-existing Azure Application Gateway and Azure autoscale into an existing resource group, vnet and application gateway. This template can be used to demonstrate initial rollout and configuration with the VMSS PowerShell DSC extension, as well as the process to upgrade an application already running on a VMSS.

Do not deploy this scale set into a new resource group - it will only work in an existing resource group which contains a VNet and Application Gateway.

Create a new subnet in the existing VNET which will have to be used with this deployment.

## VMSS Deployment
The template deploys a Windows VMSS with a desired count of VMs in the scale set. Once the VMSS is deployed, the VMSS PowerShell DSC extension installs IIS and a default web app from a WebDeploy package. The web app is nothing fancy, it's just the default MVC web app from Visual Studio, with a slight modification that shows the version (1.0 or 2.0) on the landing page.

The application URL is an output on ARM template. It's http://<vmsspublicipfqdn>/MyApp or http://<vmsspublicip>/MyApp.

Ref ARM template: <https://github.com/dannybritto96/Azure-Quickstart-Templates/blob/master/201-vmss-windows-existing-app-gateway-webapp-dsc-autoscale/azuredeploy.json>