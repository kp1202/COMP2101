function welcome {
  write-output "Welcome to planet $env:computername Overlord $env:username"
  $now = get-date -format 'HH:MM tt on dddd'
  write-output "It is $now."
}

function get-cpuinfo {
  get-ciminstance cim_processor | fl caption,manufacturer,numberofcores,maxclockspeed,currentclockspeed
}

function get-mydisks {
  wmic diskdrive get model,manufacturer,serialnumber,firmwarerevision,size
}


# This function list computer system details.

function ComputerSystem {
	Write-Output "********** Section-1 **********"
	Get-CimInstance Win32_ComputerSystem | Select Description | Format-List
}


# This function list operating system details.

function OperatingSystem {
	Write-Output "********** Section-2 **********"
	Get-CimInstance Win32_OperatingSystem | Select Name,Version | Format-List
}


# This function list processor details.

function ProcessorDetail {
	Write-Output "********** Section-3 **********"
	Get-CimInstance Win32_Processor | Select Description,MaxClockSpeed,NumberOfCores,L2CacheSize,L3CacheSize | Format-List
}


# This function list physical memory details.

function PhysicalMemmory {
	Write-Output "********** Section-4 **********"
	$phymem = Get-CimInstance Win32_PhysicalMemory | Select Description,Manufacturer,BankLabel,DeviceLocator,Capacity
	$phymem | Format-Table
	$total = 0

	foreach($pm in $phymem) {
		$total = $total + $pm.Capacity
	}

	$total = $total / 1gb
	Write-Output "Total RAM : $total GB"
}


# This function list disk details.

function SystemDisk {
	Write-Output "********** Section-5 **********"
	$diskdrives = Get-CimInstance CIM_DiskDrive
	foreach($disk in $diskdrives) {
		$partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_diskpartition
		foreach($partition in $partitions) {
			$logicaldisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_logicaldisk
			foreach($logicaldisk in $logicaldisks) {
				New-Object -TypeName psobject -Property @{Model=$disk.Model
									  Vendor=$disk.Manufacturer
									  "Logical Disk Size(GB)"=$logicaldisk.Size / 1gb -as [int]
									  "Free Space(GB)"=$logicaldisk.FreeSpace / 1gb -as [int]
									  "Percentage Free(GB)"=( $logicaldisk.FreeSpace / $logicaldisk.Size ) * 100 -as [float]
									}
			}
		}
	}
}


# This function list network adapter details.

function NetworkAdapter {
	Write-Output "********** Section-6 **********"
	Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq "True"} | Select Description,Index,IPAddress,IPSubnet,DNSDomain,DNSServerSearchOrder | Format-Table
}


# This function list video controller details.

function VideoController {
	Write-Output "********** Section-7 **********"
	$obj = Get-CimInstance Win32_VideoController | Select Description,Caption,CurrentHorizontalResolution,CurrentVerticalResolution
	$hr = $obj.CurrentHorizontalResolution
	$vr = $obj.CurrentVerticalResolution
	$res = "$hr x $vr"
	New-Object -Typename psobject -Property @{Vendor=$obj.Caption
						  Description=$obj.Description
						  "Current Screen Resolution"=$res
						}
}