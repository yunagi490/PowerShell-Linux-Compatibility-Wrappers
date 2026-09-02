<#
============================================================
Legacy implementation / Maintenance reference
============================================================

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第二版」。

※ このブロックは実行されません。
============================================================
function brew {
    if ($args.Length -eq 0) {
        Write-Host "Usage: brew install <package>"
    } elseif ($args[0] -eq "install") {
        choco install $args[1..$args.Length] -y
    } elseif ($args[0] -eq "uninstall") {
        choco uninstall $args[1..$args.Length] -y
    } elseif ($args[0] -eq "upgrade") {
        choco upgrade $args[1..$args.Length] -y
    } elseif ($args[0] -eq "-v"){
        choco --version $args[1..$args.Length] -y
    }else{
      choco $args
    }
}

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

# Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58
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