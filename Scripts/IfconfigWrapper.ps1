# ============================================================
# ifconfig compatibility wrapper
# Target: net-tools
# ============================================================

function ifconfig {
    param(
        [Parameter(Position = 0)]
        [string]$Interface,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    # ifconfig / ifconfig -a
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