# ============================================================
# Current implementation
# ============================================================
## 初版

BeforeAll {
    . "$PSScriptRoot\..\Scripts\IpWrapper.ps1"
}

Describe "IpWrapper" {

    Context "Command aliases" {

        BeforeEach {
            Mock Get-NetIPAddress { @() }
            Mock Get-NetAdapter   { @() }
            Mock Get-NetRoute     { @() }
            Mock Get-NetNeighbor  { @() }
        }

        It "'ip a' calls Get-NetIPAddress" {
            ip a
            Should -Invoke Get-NetIPAddress -Times 1
        }

        It "'ip addr' calls Get-NetIPAddress" {
            ip addr
            Should -Invoke Get-NetIPAddress -Times 1
        }

        It "'ip addr show' calls Get-NetIPAddress" {
            ip addr show
            Should -Invoke Get-NetIPAddress -Times 1
        }

        It "'ip link' calls Get-NetAdapter" {
            ip link
            Should -Invoke Get-NetAdapter -Times 1
        }

        It "'ip route' calls Get-NetRoute" {
            ip route
            Should -Invoke Get-NetRoute -Times 1
        }

        It "'ip r' calls Get-NetRoute" {
            ip r
            Should -Invoke Get-NetRoute -Times 1
        }

        It "'ip neigh' calls Get-NetNeighbor" {
            ip neigh
            Should -Invoke Get-NetNeighbor -Times 1
        }

        It "'ip n' calls Get-NetNeighbor" {
            ip n
            Should -Invoke Get-NetNeighbor -Times 1
        }
    }

    Context "Invalid commands" {

        It "Unknown command does not throw" {
            { ip nyan } | Should -Not -Throw
        }

        It "Unsupported addr argument does not throw" {
            { ip addr nyan } | Should -Not -Throw
        }
    }
}