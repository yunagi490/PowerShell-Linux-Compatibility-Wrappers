# ============================================================
# Network compatibility common functions
# ============================================================
#
# 変更履歴:
#   v0.1.0
#     - 初版
#     - Network compatibility functions を実装
#
#   v0.1.2
#     - ifconfig の Linux / net-tools 互換表示を改善
#     - IPv4 broadcast address 計算を追加
#     - MTU / network statistics の取得を改善
#
#   v0.2.0
#     - Linux iproute2 互換表示用の共通機能を追加
#     - ANSI color output に対応
#     - IPv4 / IPv6 / MAC / interface state の色分けを追加
#
# ============================================================


$script:LinuxColors = @{
    Reset   = "`e[0m"
    Cyan    = "`e[36m"
    Blue    = "`e[94m"
    Green   = "`e[32m"
    Red     = "`e[31m"
    Yellow  = "`e[33m"
    Magenta = "`e[35m"
}


function Format-LinuxColor {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter(Mandatory)]
        [ValidateSet(
            "Cyan",
            "Blue",
            "Green",
            "Red",
            "Yellow",
            "Magenta"
        )]
        [string]$Color
    )

    return (
        $script:LinuxColors[$Color] +
        $Text +
        $script:LinuxColors.Reset
    )
}
function Convert-PrefixLengthToNetmask {
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 32)]
        [int]$PrefixLength
    )

    $mask = [uint32]0

    if ($PrefixLength -gt 0) {
        $mask = [uint32]::MaxValue -shl (32 - $PrefixLength)
    }

    $bytes = [BitConverter]::GetBytes($mask)

    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($bytes)
    }

    return ($bytes -join ".")
}


function Get-IPv4BroadcastAddress {
    param(
        [Parameter(Mandatory)]
        [string]$IPAddress,

        [Parameter(Mandatory)]
        [ValidateRange(0, 32)]
        [int]$PrefixLength
    )

    $ipBytes = [System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()

    $mask = Convert-PrefixLengthToNetmask $PrefixLength
    $maskBytes = [System.Net.IPAddress]::Parse($mask).GetAddressBytes()

    $broadcastBytes = for ($i = 0; $i -lt 4; $i++) {
        $ipBytes[$i] -bor (-bnot $maskBytes[$i] -band 0xFF)
    }

    return ([System.Net.IPAddress]::new([byte[]]$broadcastBytes)).ToString()
}


function Get-IfconfigFlags {
    param(
        [Parameter(Mandatory)]
        $Adapter
    )

    $flags = @("BROADCAST", "MULTICAST")

    if ($Adapter.Status -eq "Up") {
        $flags = @("UP") + $flags
        $flags += "RUNNING"
    }

    return $flags
}


function Show-IfconfigInterface {
    param(
        [Parameter(Mandatory)]
        $Adapter
    )

    $addresses = Get-NetIPAddress `
        -InterfaceIndex $Adapter.ifIndex `
        -ErrorAction SilentlyContinue

    $ipInterface = Get-NetIPInterface `
        -InterfaceIndex $Adapter.ifIndex `
        -AddressFamily IPv4 `
        -ErrorAction SilentlyContinue |
    Select-Object -First 1

    $statistics = Get-NetAdapterStatistics `
        -Name $Adapter.Name `
        -ErrorAction SilentlyContinue

    $flags = Get-IfconfigFlags $Adapter
    $flagsText = $flags -join ","

    # Linux の数値 flags は Windows と完全対応しないため、
    # compatibility display として代表値を使用。
    $flagValue = if ($Adapter.Status -eq "Up") { 4163 } else { 4098 }

    $mtu = if ($ipInterface) {
        $ipInterface.NlMtu
    }
    else {
        1500
    }

    Write-Output (
        "{0}: flags={1}<{2}>  mtu {3}" -f `
            $Adapter.Name,
        $flagValue,
        $flagsText,
        $mtu
    )

    foreach ($address in $addresses) {

        if ($address.AddressFamily -eq "IPv4") {

            $netmask = Convert-PrefixLengthToNetmask `
                $address.PrefixLength

            $broadcast = Get-IPv4BroadcastAddress `
                $address.IPAddress `
                $address.PrefixLength

            Write-Output (
                "        inet {0}  netmask {1}  broadcast {2}" -f `
                    $address.IPAddress,
                $netmask,
                $broadcast
            )
        }

        elseif ($address.AddressFamily -eq "IPv6") {

            $scope = if ($address.IPAddress -like "fe80:*") {
                "0x20<link>"
            }
            elseif ($address.IPAddress -eq "::1") {
                "0x10<host>"
            }
            else {
                "0x00<global>"
            }

            Write-Output (
                "        inet6 {0}  prefixlen {1}  scopeid {2}" -f `
                    $address.IPAddress,
                $address.PrefixLength,
                $scope
            )
        }
    }

    if ($Adapter.MacAddress) {
        $mac = $Adapter.MacAddress.Replace("-", ":").ToLower()

        Write-Output (
            "        ether {0}  ({1})" -f `
                $mac,
            $Adapter.InterfaceDescription
        )
    }

    if ($statistics) {

        Write-Output (
            "        RX packets {0}  bytes {1}" -f `
                $statistics.ReceivedUnicastPackets,
            $statistics.ReceivedBytes
        )

        Write-Output (
            "        TX packets {0}  bytes {1}" -f `
                $statistics.SentUnicastPackets,
            $statistics.SentBytes
        )
    }

    Write-Output ""
}