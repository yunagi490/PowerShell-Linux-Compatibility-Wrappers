# ============================================================
# brew compatibility wrapper
# Backend: Chocolatey
# ============================================================
#
# 変更履歴:
#   v0.1.0
#     - 初版
#     - install / uninstall / upgrade に対応
#
#   v0.1.1 現行
#     - Homebrew互換機能を拡張
#     - search / list / info / outdated を追加
#     - pin / unpin を追加
#     - --prefix / doctor を追加
#     - 🍫 / 🍺 を使用した出力表示を追加
#
# ============================================================
function brew {
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    switch ($Command) {
        "install" {
            Write-Host "🍫 Installing $($Arguments -join ' ')..."
            choco install @Arguments -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "🍺 Installation complete."
            }
        }

        { $_ -in "uninstall", "remove" } {
            Write-Host "🍫 Uninstalling $($Arguments -join ' ')..."
            choco uninstall @Arguments -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "🍺 Uninstall complete."
            }
        }

        "upgrade" {
            if ($Arguments.Count -eq 0) {
                Write-Host "🍫 Upgrading all installed packages..."
                choco upgrade all -y
            }
            else {
                Write-Host "🍫 Upgrading $($Arguments -join ' ')..."
                choco upgrade @Arguments -y
            }

            if ($LASTEXITCODE -eq 0) {
                Write-Host "🍺 Upgrade complete."
            }
        }

        "search" {
            choco search @Arguments
        }

        "list" {
            choco list @Arguments
        }

        "info" {
            choco info @Arguments
        }

        "outdated" {
            Write-Host "🍫 Checking outdated packages..."
            choco outdated
        }

        "pin" {
            choco pin add "-n=$($Arguments[0])"
        }

        "unpin" {
            choco pin remove "-n=$($Arguments[0])"
        }

        "--prefix" {
            Write-Output $env:ChocolateyInstall
        }

        "--version" {
            choco --version
        }


        "doctor" {
            Invoke-BrewDoctor
        }

        default {
            Write-Host "brew: Unknown command '$Command'"
        }
    }
}