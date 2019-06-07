# General variables
$vcenter = Read-Host -Prompt "Enter vCenter FQDN/IP"
$vccred = Get-Credential -Message "vCenter Credentials"
$nsxmanager = Read-Host -Prompt "Enter NSX Manager FQDN/IP"
$nsxcred = Get-Credential -Message "NSX Manager Credentials"
$posturl = "https://$nsxmanager/api/v1/fabric/virtual-machines?action=update_tags"
$newtag = Read-Host -Prompt "Enter tag to add"
$newscope = Read-Host -Prompt "Enter the tag scope (optional)"

# Connect to vCenter and fetch virtual machines
Connect-VIServer -Server $vcenter -Credential $vccred
$vms = Get-Cluster Cluster | Get-VM | ForEach-Object { $_ | Get-View }

# Tag the fetched virtual machines
foreach ($vm in $vms) {
    $vmid = $vm.Config.InstanceUuid
    $vmname = $vm.Config.Name
    $geturl = "https://$nsxmanager/api/v1/fabric/virtual-machines?external_id=$vmid&included_fields=tags"
    $getrequest = Invoke-RestMethod -Uri $geturl -Authentication Basic -Credential $nsxcred -Method Get -ContentType "application/json" -SkipCertificateCheck
    $getresult = $getrequest.results | ConvertTo-Json -Compress
    $currenttags = [regex]::match($getresult,'\[([^\)]+)\]').Groups[1].Value

    $JSON = @"
    {"external_id":"$vmid","tags":[{"scope":"$newscope","tag":"$newtag"},$currenttags]}
"@
  Invoke-RestMethod -Uri $posturl -Authentication Basic -Credential $nsxcred -Method Post -Body $JSON -ContentType "application/json" -SkipCertificateCheck
    Write-Host "$vmname tagged"
}

Write-host "All VMs tagged!"
