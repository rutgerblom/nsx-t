# ChangePortGroups
# Script to migrate all VM vNICs from one portgroup to another
#
# Script takes input (VLAN ID) on the command line and imports a CSV file with candidate VLAN/portgroup information
#
# CSV file: "VLAN","portgroup","segment"
# where "segment" is the name of the NSX segment
#
# Script is intended to faclitate migrating to/from NSX segments
#
#

$vcenter = "dclund-vcenter.sddc.lab"

$vlan = $args[0]
cls
If (!$vlan) {
	"Please enter a VLAN ID"
} Else { 

	$importportgroups = import-csv ImportPortGroups.csv
	$portgroup = ($importportgroups | where {$_.VLAN -eq $vlan}).portgroup
	$segment = ($importportgroups | where {$_.VLAN -eq $vlan}).segment

	if (!$defaultviserver) {connect-viserver $vcenter}

	$segmentname = get-virtualportgroup |where {$_.name -like "*$($segment)"}

	$pg = 	get-virtualportgroup -name $portgroup	

	"`nYou have selected VLAN $($vlan) which maps port group $($pg.name) to NSX segment $($segment.name)`n" 

	$conf = Read-Host "Is this correct? (Y/N)"
	if ($conf -eq "y") {
		cls	
		"Counting vNICs`n"	
		$vms = get-vm
		$segmentvms = $vms| get-networkadapter |where {$_.networkname -eq $segmentname.name}
		$pgvms = $vms| get-networkadapter |where {$_.networkname -eq $pg.name}
		"`nThere are $($pgvms.count) VM vNICs on the portgroup and $($segmentvms.count) VM vNICs on the NSX segment.`n"
		"Press 1 to move all VMs on the portgroup to the NSX segment.  Press 2 to move all VMs connected to the NSX segment to the portgroup.`n"
		
		do {	
			$key = Read-Host "Or press C to cancel. [1/2/C]"
		}until ("12C" -match $key)

		if ($key -eq "1") {
			$out = $pgvms | set-networkadapter -networkname $segmentname.name -Confirm:$false
		} elseif ($key -eq "2") {
			$out = $segmentvms | set-networkadapter -networkname $pg.name -Confirm:$false
		} else {exit }
		"`nMigration completed, recounting vNICs.`n"
		$segmentvms = $vms| get-networkadapter |where {$_.networkname -eq $segmentname.name}
		$pgvms = $vms| get-networkadapter |where {$_.networkname -eq $pg.name}
		"`nThere are now $($pgvms.count) VM vNICs on the portgroup and $($segmentvms.count) VM vNICs on the NSX segment.`n"
}
}