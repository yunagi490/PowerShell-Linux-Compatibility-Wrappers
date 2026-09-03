# ============================================================
# ip command compatibility wrapper
# Backend: Windows NetTCPIP / NetAdapter
# ============================================================
#
# 変更履歴:
#   v0.1.0
#     - 初版
#     - ip addr / address / a を実装
#     - ip link を実装
#     - ip route / r を実装
#     - ip neigh / neighbor / n を実装
#
#   v0.2.0
#     - ip addr を Linux iproute2 形式へ全面変更
#     - AlmaLinux 10 の出力形式を参考に表示を改善
#     - interface flags / state / MTU を追加
#     - MAC address / broadcast address を追加
#     - IPv4 CIDR / broadcast / scope を追加
#     - IPv6 prefix / scope を追加
#     - loopback interface の Linux 互換表示を追加
#     - ANSI color output に対応
#
# ============================================================

function ip {
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(Position = 1)]
        [string]$SubCommand
    )

    switch ($Command) {

        { $_ -in "addr", "address", "a" } {
            Show-IpAddress
            return
        }

        "link" {
            Get-NetAdapter
            return
        }

        { $_ -in "route", "r" } {
            Get-NetRoute
            return
        }

        { $_ -in "neigh", "neighbor", "n" } {
            Get-NetNeighbor
            return
        }

        default {
            Write-Host "Usage: ip [ addr | link | route | neigh ]"
        }
    }
}


function Show-IpAddress {

    # ========================================================
    # Loopback
    # ========================================================

    $loName = Format-LinuxColor "lo" "Cyan"

    $loopbackMac = Format-LinuxColor `
        "00:00:00:00:00:00" `
        "Yellow"

    $loopbackIPv4 = Format-LinuxColor `
        "127.0.0.1" `
        "Magenta"

    $loopbackIPv6 = Format-LinuxColor `
        "::1" `
        "Blue"

    Write-Output (
        "1: {0}: <LOOPBACK,UP,LOWER_UP> mtu 65536 state UNKNOWN" -f `
            $loName
    )

    Write-Output (
        "    link/loopback {0} brd {0}" -f `
            $loopbackMac
    )

    Write-Output (
        "    inet {0}/8 scope host lo" -f `
            $loopbackIPv4
    )

    Write-Output (
        "    inet6 {0}/128 scope host" -f `
            $loopbackIPv6
    )

    # ========================================================
    # Windows network adapters
    # ========================================================

    $adapters = Get-NetAdapter -ErrorAction SilentlyContinue

    $displayIndex = 2

    foreach ($adapter in $adapters) {

        $addresses = Get-NetIPAddress `
            -InterfaceIndex $adapter.ifIndex `
            -ErrorAction SilentlyContinue

        $ipInterface = Get-NetIPInterface `
            -InterfaceIndex $adapter.ifIndex `
            -AddressFamily IPv4 `
            -ErrorAction SilentlyContinue |
        Select-Object -First 1

        # ----------------------------------------------------
        # Interface state
        # ----------------------------------------------------

        $isUp = $adapter.Status -eq "Up"

        $flags = @(
            "BROADCAST"
            "MULTICAST"
        )

        if ($isUp) {
            $flags += "UP"
            $flags += "LOWER_UP"
        }

        if ($isUp) {
            $state = Format-LinuxColor "UP" "Green"
        }
        else {
            $state = Format-LinuxColor "DOWN" "Red"
        }

        $mtu = if ($ipInterface) {
            $ipInterface.NlMtu
        }
        else {
            1500
        }

        $interfaceName = Format-LinuxColor `
            $adapter.Name `
            "Cyan"

        Write-Output (
            "{0}: {1}: <{2}> mtu {3} state {4}" -f `
                $displayIndex,
            $interfaceName,
            ($flags -join ","),
            $mtu,
            $state
        )

        # ----------------------------------------------------
        # MAC address
        # ----------------------------------------------------

        if ($adapter.MacAddress) {

            $rawMac = $adapter.MacAddress.Replace("-", ":").ToLower()

            $mac = Format-LinuxColor `
                $rawMac `
                "Yellow"

            $broadcastMac = Format-LinuxColor `
                "ff:ff:ff:ff:ff:ff" `
                "Yellow"

            Write-Output (
                "    link/ether {0} brd {1}" -f `
                    $mac,
                $broadcastMac
            )
        }

        # ----------------------------------------------------
        # IP addresses
        # ----------------------------------------------------

        foreach ($address in $addresses) {

            if ($address.AddressFamily -eq "IPv4") {

                $broadcast = Get-IPv4BroadcastAddress `
                    $address.IPAddress `
                    $address.PrefixLength

                $ipv4 = Format-LinuxColor `
                    $address.IPAddress `
                    "Magenta"

                $broadcastColor = Format-LinuxColor `
                    $broadcast `
                    "Magenta"

                Write-Output (
                    "    inet {0}/{1} brd {2} scope global {3}" -f `
                        $ipv4,
                    $address.PrefixLength,
                    $broadcastColor,
                    $adapter.Name
                )
            }

            elseif ($address.AddressFamily -eq "IPv6") {

                $scope = if (
                    $address.IPAddress -like "fe80:*"
                ) {
                    "link"
                }
                elseif (
                    $address.IPAddress -eq "::1"
                ) {
                    "host"
                }
                else {
                    "global"
                }

                $ipv6 = Format-LinuxColor `
                    $address.IPAddress `
                    "Blue"

                Write-Output (
                    "    inet6 {0}/{1} scope {2}" -f `
                        $ipv6,
                    $address.PrefixLength,
                    $scope
                )
            }
        }

        $displayIndex++
    }
}