# ============================================================
# ifconfig compatibility wrapper
# Target: net-tools
# ============================================================
function Show-IfconfigLoopback {

    Write-Output "lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536"
    Write-Output "        inet 127.0.0.1  netmask 255.0.0.0"
    Write-Output "        inet6 ::1  prefixlen 128  scopeid 0x10<host>"
    Write-Output "        loop  txqueuelen 1000  (Local Loopback)"
    Write-Output ""
}
function ifconfig {
    $Interface = $args[0]

    if (
        [string]::IsNullOrWhiteSpace($Interface) -or
        $Interface -eq "-a"
    ) {
        Get-NetAdapter | ForEach-Object {
            Show-IfconfigInterface $_
        }

        Show-IfconfigLoopback
        return
    }

    if ($Interface -eq "lo") {
        Show-IfconfigLoopback
        return
    }

    $adapter = Get-NetAdapter `
        -Name $Interface `
        -ErrorAction SilentlyContinue

    if (-not $adapter) {
        Write-Host "ifconfig: $Interface`: error fetching interface information: Device not found"
        return
    }

    Show-IfconfigInterface $adapter

    # lo
    if ($Interface -eq "lo") {
        Show-IfconfigLoopback
        return
    }

    # Windows NIC名で検索
    $adapter = Get-NetAdapter `
        -Name $Interface `
        -ErrorAction SilentlyContinue

    if (-not $adapter) {
        Write-Host "$Interface`: error fetching interface information: Device not found"
        return
    }

    Show-IfconfigInterface $adapter
}
