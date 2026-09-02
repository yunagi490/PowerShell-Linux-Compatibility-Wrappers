# ============================================================
# ifconfig compatibility wrapper
# Target: net-tools
# ============================================================

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