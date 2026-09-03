# ============================================================
# BrewWrapper Tests
# ============================================================
#
# 変更履歴:
#   v0.1.0
#     - 初版
#     - install / uninstall / upgrade の基本動作をテスト
#
#   v0.1.1
#     - Homebrew互換機能の拡張に対応
#     - remove / search / list / info / outdated を追加
#     - pin / unpin を追加
#     - --prefix / --version を追加
#     - 引数なし upgrade の全パッケージ更新を追加
#
# ============================================================
Describe "brew wrapper" {

    BeforeAll {
        . "$PSScriptRoot\..\Scripts\BrewWrapper.ps1"

        Mock choco {}
    }

    Context "install" {

        It "installs a package using Chocolatey" {
            brew install git

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "install" -and
                $args -contains "git" -and
                $args -contains "-y"
            }
        }
    }

    Context "uninstall" {

        It "uninstalls a package using Chocolatey" {
            brew uninstall git

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "uninstall" -and
                $args -contains "git" -and
                $args -contains "-y"
            }
        }

        It "supports remove as an alias for uninstall" {
            brew remove git

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "uninstall" -and
                $args -contains "git" -and
                $args -contains "-y"
            }
        }
    }

    Context "upgrade" {

        It "upgrades a specified package" {
            brew upgrade git

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "upgrade" -and
                $args -contains "git" -and
                $args -contains "-y"
            }
        }

        It "upgrades all packages when no package is specified" {
            brew upgrade

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "upgrade" -and
                $args -contains "all" -and
                $args -contains "-y"
            }
        }
    }

    Context "package information" {

        It "searches for packages" {
            brew search git

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "search" -and
                $args -contains "git"
            }
        }

        It "lists installed packages" {
            brew list

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "list"
            }
        }

        It "shows package information" {
            brew info git

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "info" -and
                $args -contains "git"
            }
        }

        It "checks outdated packages" {
            brew outdated

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "outdated"
            }
        }
    }

    Context "pin" {

        It "pins a package" {
            brew pin git

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "pin" -and
                $args -contains "add" -and
                $args -contains "-n=git"
            }
        }

        It "unpins a package" {
            brew unpin git

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "pin" -and
                $args -contains "remove" -and
                $args -contains "-n=git"
            }
        }
    }

    Context "brew compatibility options" {

        It "returns the Chocolatey installation prefix" {
            $originalChocolateyInstall = $env:ChocolateyInstall

            try {
                $env:ChocolateyInstall = "C:\ProgramData\chocolatey"

                brew --prefix |
                Should -Be "C:\ProgramData\chocolatey"
            }
            finally {
                $env:ChocolateyInstall = $originalChocolateyInstall
            }
        }

        It "returns the Chocolatey version" {
            brew --version

            Should -Invoke choco -Times 1 -ParameterFilter {
                $args -contains "--version"
            }
        }
    }
}