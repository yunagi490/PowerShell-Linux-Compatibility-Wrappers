<#
============================================================
Legacy implementation / Maintenance reference
============================================================

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第二版」。

※ このブロックは実行されません。
============================================================
Legacy implementation / Maintenance reference
============================================================
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
#>
## 第二版
# ============================================================
# brew compatibility wrapper
# Backend: Chocolatey
# ============================================================

function Invoke-BrewWrapper {
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    if ([string]::IsNullOrWhiteSpace($Command)) {
        Write-Host "Usage: brew <command> [package]"
        return
    }

    switch ($Command) {

        "install" {
            choco install @Arguments -y
        }

        "uninstall" {
            choco uninstall @Arguments -y
        }

        "remove" {
            choco uninstall @Arguments -y
        }

        "upgrade" {
            choco upgrade @Arguments -y
        }

        "--version" {
            choco --version
        }

        default {
            choco $Command @Arguments
        }
    }
}

function brew {
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    Invoke-BrewWrapper `
        -Command $Command `
        -Arguments $Arguments
}