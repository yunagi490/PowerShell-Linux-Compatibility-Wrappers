# ============================================================
# DnfWrapper Tests
# ============================================================

BeforeAll {
    . "$PSScriptRoot\..\Scripts\DnfWrapper.ps1"
}

Describe "dnf compatibility wrapper" {

    Context "install" {

        BeforeEach {
            Mock Install-Module {}
        }

        It "installでInstall-Moduleを呼ぶ" {
            Invoke-DnfWrapper install TestModule

            Should -Invoke Install-Module `
                -Times 1 `
                -ParameterFilter {
                $Name -eq "TestModule"
            }
        }

        It "install -yでForceを指定する" {
            Invoke-DnfWrapper install TestModule -y

            Should -Invoke Install-Module `
                -Times 1 `
                -ParameterFilter {
                $Name -eq "TestModule" -and
                $Force -eq $true
            }
        }

        It "-y install形式でもForceを指定する" {
            Invoke-DnfWrapper -y install TestModule

            Should -Invoke Install-Module `
                -Times 1 `
                -ParameterFilter {
                $Name -eq "TestModule" -and
                $Force -eq $true
            }
        }
    }

    Context "remove" {

        BeforeEach {
            Mock Uninstall-Module {}
        }

        It "removeでUninstall-Moduleを呼ぶ" {
            Invoke-DnfWrapper remove TestModule

            Should -Invoke Uninstall-Module `
                -Times 1 `
                -ParameterFilter {
                $Name -eq "TestModule"
            }
        }

        It "remove -yでForceを指定する" {
            Invoke-DnfWrapper remove TestModule -y

            Should -Invoke Uninstall-Module `
                -Times 1 `
                -ParameterFilter {
                $Name -eq "TestModule" -and
                $Force -eq $true
            }
        }
    }

    Context "list" {

        BeforeEach {
            Mock Get-InstalledModule {
                [PSCustomObject]@{
                    Name    = "TestModule"
                    Version = "1.0.0"
                }
            }
        }

        It "listでGet-InstalledModuleを呼ぶ" {
            Invoke-DnfWrapper list

            Should -Invoke Get-InstalledModule -Times 1
        }
    }

    Context "search" {

        BeforeEach {
            Mock Find-Module {
                [PSCustomObject]@{
                    Name    = "TestModule"
                    Version = "1.0.0"
                }
            }
        }

        It "searchでFind-Moduleを呼ぶ" {
            Invoke-DnfWrapper search TestModule

            Should -Invoke Find-Module `
                -Times 1 `
                -ParameterFilter {
                $Name -eq "TestModule"
            }
        }
    }

    Context "update" {

        BeforeEach {
            Mock Update-Module {}
        }

        It "updateでUpdate-Moduleを呼ぶ" {
            Invoke-DnfWrapper update TestModule

            Should -Invoke Update-Module `
                -Times 1 `
                -ParameterFilter {
                $Name -eq "TestModule"
            }
        }
    }

    Context "unknown command" {

        BeforeEach {
            Mock Install-Module {}
            Mock Uninstall-Module {}
            Mock Update-Module {}
        }

        It "不明なコマンドではパッケージ操作を行わない" {
            Invoke-DnfWrapper nyan TestModule

            Should -Invoke Install-Module -Times 0
            Should -Invoke Uninstall-Module -Times 0
            Should -Invoke Update-Module -Times 0
        }
    }
}