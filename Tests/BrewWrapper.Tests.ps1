BeforeAll {
    . "$PSScriptRoot\..\Scripts\BrewWrapper.ps1"

    Mock choco {}
}

Describe "BrewWrapper" {

    It "brew install を choco install に変換する" {
        brew install git

        Should -Invoke choco -Times 1 -ParameterFilter {
            $args -contains "install" -and
            $args -contains "git"
        }
    }

    It "brew uninstall を choco uninstall に変換する" {
        brew uninstall git

        Should -Invoke choco -Times 1 -ParameterFilter {
            $args -contains "uninstall" -and
            $args -contains "git"
        }
    }

    It "brew upgrade を choco upgrade に変換する" {
        brew upgrade git

        Should -Invoke choco -Times 1 -ParameterFilter {
            $args -contains "upgrade" -and
            $args -contains "git"
        }
    }
}