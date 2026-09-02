BeforeAll {
    . "$PSScriptRoot\..\Scripts\YumWrapper.ps1"

    Mock winget {}
}

Describe "YumWrapper" {

    Context "install" {

        It "sudo yum install git を winget install git に変換する" {
            sudo yum install git

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "install" -and
                $args -contains "git"
            }
        }

        It "末尾の -y を処理できる" {
            sudo yum install git -y

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "install" -and
                $args -contains "git" -and
                $args -contains "--accept-package-agreements" -and
                $args -contains "--accept-source-agreements" -and
                $args -contains "--disable-interactivity"
            }
        }

        It "前置きの -y を処理できる" {
            sudo yum -y install git

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "install" -and
                $args -contains "git" -and
                $args -contains "--disable-interactivity"
            }
        }

        It "--assumeyes を処理できる" {
            sudo yum --assumeyes install git

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "install" -and
                $args -contains "git" -and
                $args -contains "--disable-interactivity"
            }
        }
    }

    Context "search" {

        It "yum search を winget search に変換する" {
            sudo yum search git

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "search" -and
                $args -contains "git"
            }
        }
    }

    Context "remove" {

        It "yum remove を winget uninstall に変換する" {
            sudo yum remove git

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "uninstall" -and
                $args -contains "git"
            }
        }

        It "yum uninstall も処理できる" {
            sudo yum uninstall git

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "uninstall" -and
                $args -contains "git"
            }
        }
    }

    Context "upgrade" {

        It "引数なし upgrade は winget upgrade --all に変換する" {
            sudo yum upgrade

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "upgrade" -and
                $args -contains "--all"
            }
        }

        It "パッケージ指定 upgrade を処理できる" {
            sudo yum upgrade git

            Should -Invoke winget -Times 1 -ParameterFilter {
                $args -contains "upgrade" -and
                $args -contains "git"
            }
        }
    }
}