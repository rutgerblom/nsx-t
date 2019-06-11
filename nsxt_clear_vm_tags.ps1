# General variables
$vcenter = Read-Host -Prompt "Enter vCenter FQDN/IP"
$vccred = Get-Credential -Message "vCenter Credentials"
$vccluster = Read-Host -Prompt "Enter the vSphere cluster name to fetch virtual machines"
$nsxmanager = Read-Host -Prompt "Enter NSX Manager FQDN/IP"
$nsxcred = Get-Credential -Message "NSX Manager Credentials"
$posturl = "https://$nsxmanager/api/v1/fabric/virtual-machines?action=update_tags"

# Connect to vCenter and fetch virtual machines. Adjust this query to fetch a subset of virtual machines.
Connect-VIServer -Server $vcenter -Credential $vccred
$vms = Get-Cluster $vccluster | Get-VM | ForEach-Object { $_ | Get-View }

# Tag the fetched virtual machines
foreach ($vm in $vms) {
    $vmid = $vm.Config.InstanceUuid
    $vmname = $vm.Config.Name
    $JSON = @"
    {"external_id":"$vmid","tags":[{"scope":"","tag":""}]}
"@
  Invoke-RestMethod -Uri $posturl -Authentication Basic -Credential $nsxcred -Method Post -Body $JSON -ContentType "application/json" -SkipCertificateCheck
  Write-Host "$vmname tags removed"
}

Write-host "All tags have been removed"
