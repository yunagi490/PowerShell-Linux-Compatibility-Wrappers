# ============================================================
# ifconfig compatibility wrapper
# Target: net-tools style output
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

        # loopback
        Show-IfconfigLoopback
        return
    }

    # 指定インターフェース
    $adapter = Get-NetAdapter -Name $Interface -ErrorAction SilentlyContinue

    if (-not $adapter) {
        Write-Host "ifconfig: $Interface`: error fetching interface information: Device not found"
        return
    }

    Show-IfconfigInterface $adapter
}


function Show-IfconfigInterface {
    param(
        [Parameter(Mandatory)]
        $Adapter
    )

    $addresses = Get-NetIPAddress `
        -InterfaceIndex $Adapter.ifIndex `
        -ErrorAction SilentlyContinue

    $ipv4 = $addresses |
        Where-Object AddressFamily -eq IPv4 |
        Select-Object -First 1

    $ipv6 = $addresses |
        Where-Object AddressFamily -eq IPv6 |
        Select-Object -First 1

    $flags = @("UP")

    if ($Adapter.Status -eq "Up") {
        $flags += "RUNNING"
    }

    if ($Adapter.MediaType -ne "Loopback") {
        $flags += "BROADCAST"
        $flags += "MULTICAST"
    }

    Write-Host "$($Adapter.Name): flags=$($flags -join ',')  mtu $($Adapter.MtuSize)"

    if ($ipv4) {
        $netmask = Convert-PrefixLengthToNetmask $ipv4.PrefixLength

        Write-Host "        inet $($ipv4.IPAddress)  netmask $netmask"
    }

    if ($ipv6) {
        Write-Host "        inet6 $($ipv6.IPAddress)  prefixlen $($ipv6.PrefixLength)"
    }

    if ($Adapter.MacAddress) {
        $mac = $Adapter.MacAddress.Replace("-", ":").ToLower()

        Write-Host "        ether $mac"
    }

    Write-Host "        RX packets $($Adapter.ReceivedUnicastPackets)"
    Write-Host "        TX packets $($Adapter.SentUnicastPackets)"
    Write-Host ""
}


function Show-IfconfigLoopback {

    Write-Host "lo: flags=UP,LOOPBACK,RUNNING  mtu 65536"
    Write-Host "        inet 127.0.0.1  netmask 255.0.0.0"
    Write-Host "        inet6 ::1  prefixlen 128"
    Write-Host ""
}


function Convert-PrefixLengthToNetmask {
    param(
        [int]$PrefixLength
    )

    $mask = [uint32]0

    if ($PrefixLength -gt 0) {
        $mask = [uint32]::MaxValue -shl (32 - $PrefixLength)
    }

    $bytes = [BitConverter]::GetBytes($mask)
    [Array]::Reverse($bytes)

    return ($bytes -join ".")
}