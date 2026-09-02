# ============================================================
# IfconfigWrapper Tests
# ============================================================

BeforeAll {
    . "$PSScriptRoot\..\Scripts\Network\NetworkCommon.ps1"
    . "$PSScriptRoot\..\Scripts\IfconfigWrapper.ps1"
}

Describe "ifconfig compatibility wrapper" {

    Context "ifconfig" {

        BeforeEach {
            Mock Get-NetAdapter {
                @(
                    [PSCustomObject]@{
                        Name       = "Ethernet"
                        ifIndex    = 10
                        Status     = "Up"
                        MacAddress = "00-11-22-33-44-55"
                        MtuSize    = 1500
                    }
                )
            }

            Mock Show-IfconfigInterface {}
            Mock Show-IfconfigLoopback {}
        }

        It "全インターフェースとloopbackを表示する" {
            ifconfig

            Should -Invoke Get-NetAdapter -Times 1
            Should -Invoke Show-IfconfigInterface -Times 1
            Should -Invoke Show-IfconfigLoopback -Times 1
        }
    }

    Context "ifconfig -a" {

        BeforeEach {
            Mock Get-NetAdapter {
                @(
                    [PSCustomObject]@{
                        Name       = "Ethernet"
                        ifIndex    = 10
                        Status     = "Up"
                        MacAddress = "00-11-22-33-44-55"
                        MtuSize    = 1500
                    }
                )
            }

            Mock Show-IfconfigInterface {}
            Mock Show-IfconfigLoopback {}
        }

        It "全インターフェースとloopbackを表示する" {
            ifconfig -a

            Should -Invoke Get-NetAdapter -Times 1
            Should -Invoke Show-IfconfigInterface -Times 1
            Should -Invoke Show-IfconfigLoopback -Times 1
        }
    }

    Context "ifconfig lo" {

        BeforeEach {
            Mock Show-IfconfigLoopback {}
        }

        It "loopbackだけを表示する" {
            ifconfig lo

            Should -Invoke Show-IfconfigLoopback -Times 1
        }
    }

    Context "ifconfig <interface>" {

        BeforeEach {
            Mock Get-NetAdapter {
                [PSCustomObject]@{
                    Name       = "Ethernet"
                    ifIndex    = 10
                    Status     = "Up"
                    MacAddress = "00-11-22-33-44-55"
                    MtuSize    = 1500
                }
            }

            Mock Show-IfconfigInterface {}
        }

        It "指定されたインターフェースを表示する" {
            ifconfig Ethernet

            Should -Invoke Get-NetAdapter `
                -Times 1 `
                -ParameterFilter {
                $Name -eq "Ethernet"
            }

            Should -Invoke Show-IfconfigInterface -Times 1
        }
    }

    Context "存在しないインターフェース" {

        BeforeEach {
            Mock Get-NetAdapter {
                return $null
            }

            Mock Show-IfconfigInterface {}
        }

        It "インターフェース表示処理を呼ばない" {
            ifconfig nyan0

            Should -Invoke Show-IfconfigInterface -Times 0
        }
    }
}

Describe "NetworkCommon" {

    Context "Convert-PrefixLengthToNetmask" {

        It "/8を255.0.0.0へ変換する" {
            Convert-PrefixLengthToNetmask 8 |
            Should -Be "255.0.0.0"
        }

        It "/16を255.255.0.0へ変換する" {
            Convert-PrefixLengthToNetmask 16 |
            Should -Be "255.255.0.0"
        }

        It "/24を255.255.255.0へ変換する" {
            Convert-PrefixLengthToNetmask 24 |
            Should -Be "255.255.255.0"
        }

        It "/32を255.255.255.255へ変換する" {
            Convert-PrefixLengthToNetmask 32 |
            Should -Be "255.255.255.255"
        }
    }
}