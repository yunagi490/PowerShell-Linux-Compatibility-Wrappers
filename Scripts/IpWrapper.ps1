# ============================================================
# Current implementation
# ============================================================
## 初版

function ip {
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    if ([string]::IsNullOrWhiteSpace($Command)) {
        Write-Host "Usage: ip <command> [arguments]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  addr, address, a       Show IP addresses"
        Write-Host "  link                   Show network interfaces"
        Write-Host "  route, r               Show routing table"
        Write-Host "  neigh, neighbor, n      Show neighbor table"
        return
    }

    switch ($Command) {

        # ----------------------------------------------------
        # ip addr / ip a
        # ----------------------------------------------------
        { $_ -in "addr", "address", "a" } {

            if (
                $Arguments.Count -eq 0 -or
                $Arguments[0] -eq "show"
            ) {
                Get-NetIPAddress |
                    Sort-Object InterfaceIndex, AddressFamily |
                    Format-Table `
                        InterfaceIndex,
                        InterfaceAlias,
                        AddressFamily,
                        IPAddress,
                        PrefixLength `
                        -AutoSize
            }
            else {
                Write-Host "ip addr: Unsupported argument '$($Arguments[0])'"
            }
        }

        # ----------------------------------------------------
        # ip link
        # ----------------------------------------------------
        "link" {

            if (
                $Arguments.Count -eq 0 -or
                $Arguments[0] -eq "show"
            ) {
                Get-NetAdapter |
                    Sort-Object ifIndex |
                    Format-Table `
                        ifIndex,
                        Name,
                        InterfaceDescription,
                        Status,
                        MacAddress,
                        LinkSpeed `
                        -AutoSize
            }
            else {
                Write-Host "ip link: Unsupported argument '$($Arguments[0])'"
            }
        }

        # ----------------------------------------------------
        # ip route / ip r
        # ----------------------------------------------------
        { $_ -in "route", "r" } {

            if (
                $Arguments.Count -eq 0 -or
                $Arguments[0] -eq "show"
            ) {
                Get-NetRoute |
                    Sort-Object InterfaceIndex, DestinationPrefix |
                    Format-Table `
                        InterfaceIndex,
                        DestinationPrefix,
                        NextHop,
                        RouteMetric,
                        InterfaceMetric `
                        -AutoSize
            }
            else {
                Write-Host "ip route: Unsupported argument '$($Arguments[0])'"
            }
        }

        # ----------------------------------------------------
        # ip neigh
        # ----------------------------------------------------
        { $_ -in "neigh", "neighbor", "neighbour", "n" } {

            if (
                $Arguments.Count -eq 0 -or
                $Arguments[0] -eq "show"
            ) {
                Get-NetNeighbor |
                    Sort-Object InterfaceIndex, IPAddress |
                    Format-Table `
                        InterfaceIndex,
                        InterfaceAlias,
                        IPAddress,
                        LinkLayerAddress,
                        State `
                        -AutoSize
            }
            else {
                Write-Host "ip neigh: Unsupported argument '$($Arguments[0])'"
            }
        }

        default {
            Write-Host "ip: Unknown command '$Command'"
            Write-Host "Try: ip addr | ip link | ip route | ip neigh"
        }
    }
}