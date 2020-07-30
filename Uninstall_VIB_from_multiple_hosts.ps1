 <#
.SYNOPSIS
    Uninstall_VIB_from_multiple_hosts.ps1 - PowerShell Script to remove (multiple) VIBs from one or more ESXi hosts.
.DESCRIPTION
    This script is used to delete one or multiple VIB files from one or more ESXi hosts (depending on how you change line 15).
    By default the script will run against all ESXi hosts which are placed in maintenance mode.
    At this moment rebooting a host is a manual action, the requirement of a reboot will be printed to the console
.OUTPUTS
    Results are printed to the console.
.NOTES
    Author        Jesper Alberts, Twitter: @jesperalberts

    Change Log    V1.00, 22/07/2019 - Initial version
#>

$vCenterServer = Read-Host "Enter the vCenter Server hostname"
$AdminUsername = Read-Host ("Enter the username for the administrative account")
$AdminPassword = Read-Host ("Password for " + $AdminUsername) -AsSecureString:$true
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $AdminUsername, $AdminPassword

Connect-VIServer -Server $vCenterServer -Credential $Credentials

$ESXiHosts = Get-VMHost | Where { $_.ConnectionState -eq "Maintenance" }
$VIBs = @("NVIDIA-VMware_ESXi_6.7_Host_Driver")

Foreach ($ESXiHost in $ESXiHosts) {
    Write-host "Working on $ESXiHost."
    $ESXCLI = get-esxcli -vmhost $ESXiHost
    foreach ($VIB in ($VIBs)) {
        write-host "Searching for VIB $VIB." -ForegroundColor Cyan
        if ($ESXCLI.software.vib.get.invoke() | where { $_.name -eq "$VIB" } -erroraction silentlycontinue ) {
            write-host "Found vib $VIB on $ESXiHost, deleting." -ForegroundColor Green
            $ESXCLI.software.vib.remove.invoke($null, $true, $false, $true, "$VIB")
        }
        else {
            write-host "VIB $VIB not found on $ESXiHost." -ForegroundColor Yellow
        }
    }

}