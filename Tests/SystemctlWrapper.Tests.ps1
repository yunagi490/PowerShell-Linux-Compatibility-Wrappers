# ============================================================
# Current implementation
# ============================================================
## 初版

# ============================================================
# SystemctlWrapper Tests
# ============================================================

BeforeAll {
    . "$PSScriptRoot\..\Scripts\SystemctlWrapper.ps1"
}

Describe "systemctl compatibility wrapper" {

    Context "status" {

        BeforeEach {
            Mock Get-Service {
                [PSCustomObject]@{
                    Name        = "TestService"
                    DisplayName = "Test Service"
                    Status      = "Running"
                }
            }

            Mock Get-CimInstance {
                [PSCustomObject]@{
                    Name      = "TestService"
                    StartMode = "Auto"
                }
            }
        }

        It "サービス情報を取得する" {
            systemctl status TestService

            Should -Invoke Get-Service -Times 1
            Should -Invoke Get-CimInstance -Times 1
        }
    }

    Context "is-active" {

        It "Runningならactiveを返す" {
            Mock Get-Service {
                [PSCustomObject]@{
                    Name   = "TestService"
                    Status = "Running"
                }
            }

            $result = systemctl is-active TestService

            $result | Should -Be "active"
        }

        It "Stoppedならinactiveを返す" {
            Mock Get-Service {
                [PSCustomObject]@{
                    Name   = "TestService"
                    Status = "Stopped"
                }
            }

            $result = systemctl is-active TestService

            $result | Should -Be "inactive"
        }
    }

    Context "is-enabled" {

        It "Autoならenabledを返す" {
            Mock Get-CimInstance {
                [PSCustomObject]@{
                    StartMode = "Auto"
                }
            }

            systemctl is-enabled TestService |
                Should -Be "enabled"
        }

        It "Disabledならdisabledを返す" {
            Mock Get-CimInstance {
                [PSCustomObject]@{
                    StartMode = "Disabled"
                }
            }

            systemctl is-enabled TestService |
                Should -Be "disabled"
        }

        It "Manualならstaticを返す" {
            Mock Get-CimInstance {
                [PSCustomObject]@{
                    StartMode = "Manual"
                }
            }

            systemctl is-enabled TestService |
                Should -Be "static"
        }
    }

    Context "service control" {

        BeforeEach {
            Mock Start-Service {}
            Mock Stop-Service {}
            Mock Restart-Service {}
            Mock Set-Service {}
        }

        It "startはStart-Serviceを呼ぶ" {
            systemctl start TestService

            Should -Invoke Start-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "TestService"
                }
        }

        It "stopはStop-Serviceを呼ぶ" {
            systemctl stop TestService

            Should -Invoke Stop-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "TestService"
                }
        }

        It "restartはRestart-Serviceを呼ぶ" {
            systemctl restart TestService

            Should -Invoke Restart-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "TestService"
                }
        }
    }

    Context "enable --now" {

        BeforeEach {
            Mock Set-Service {}
            Mock Start-Service {}
        }

        It "Automaticに設定してサービスを開始する" {
            systemctl enable --now TestService

            Should -Invoke Set-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "TestService" -and
                    $StartupType -eq "Automatic"
                }

            Should -Invoke Start-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "TestService"
                }
        }
    }

    Context "disable --now" {

        BeforeEach {
            Mock Set-Service {}
            Mock Stop-Service {}
        }

        It "サービスを停止してDisabledに設定する" {
            systemctl disable --now TestService

            Should -Invoke Stop-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "TestService"
                }

            Should -Invoke Set-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "TestService" -and
                    $StartupType -eq "Disabled"
                }
        }
    }
}