<#
============================================================
Legacy implementation / Maintenance reference
============================================================

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第二版」。

※ このブロックは実行されません。
============================================================

function sudo {
    if ($args.Length -eq 0) {
        Write-Host "Usage: sudo yum <command> [package]"
        return
    }

    if ($args[0] -ne "yum") {
        & $args
        return
    }

    $yumArgs = @($args[1..($args.Length - 1)])

    if ($yumArgs.Length -eq 0) {
        Write-Host "Usage: sudo yum <command> [package]"
        return
    }

    switch ($yumArgs[0]) {
        "install" {
            winget install @($yumArgs[1..($yumArgs.Length - 1)]) `
                --accept-package-agreements `
                --accept-source-agreements
        }

        { $_ -in "remove", "uninstall" } {
            winget uninstall @($yumArgs[1..($yumArgs.Length - 1)])
        }

        "search" {
            winget search @($yumArgs[1..($yumArgs.Length - 1)])
        }

        "info" {
            winget show @($yumArgs[1..($yumArgs.Length - 1)])
        }

        "list" {
            winget list @($yumArgs[1..($yumArgs.Length - 1)])
        }

        { $_ -in "update", "upgrade" } {
            if ($yumArgs.Length -eq 1) {
                winget upgrade --all
            }
            else {
                winget upgrade @($yumArgs[1..($yumArgs.Length - 1)])
            }
        }

        default {
            winget @yumArgs
        }
    }
}
    #>
    <#

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第三版」。

※ このブロックは実行されません。
============================================================

## 第二版
function sudo {
    if ($args.Length -eq 0) {
        Write-Host "Usage: sudo yum [options] <command> [package]"
        return
    }

    if ($args[0] -ne "yum") {
        & $args[0] @($args[1..($args.Length - 1)])
        return
    }

    # "yum" より後ろを取得
    $yumArgs = @($args[1..($args.Length - 1)])

    if ($yumArgs.Length -eq 0) {
        Write-Host "Usage: sudo yum [options] <command> [package]"
        return
    }

    # yum の -y / --assumeyes をどこに書いても拾う
    $assumeYes = ($yumArgs -contains "-y") -or `
                 ($yumArgs -contains "--assumeyes")

    # winget に渡さないよう yum 専用オプションを除去
    $yumArgs = @(
        $yumArgs | Where-Object {
            $_ -ne "-y" -and $_ -ne "--assumeyes"
        }
    )

    if ($yumArgs.Length -eq 0) {
        Write-Host "Usage: sudo yum [options] <command> [package]"
        return
    }

    $command = $yumArgs[0]
    $commandArgs = @($yumArgs | Select-Object -Skip 1)

    switch ($command) {
        "install" {
            if ($assumeYes) {
                winget install @commandArgs `
                    --accept-package-agreements `
                    --accept-source-agreements `
                    --disable-interactivity
            }
            else {
                winget install @commandArgs
            }
        }

        { $_ -in "remove", "uninstall" } {
            if ($assumeYes) {
                winget uninstall @commandArgs `
                    --disable-interactivity
            }
            else {
                winget uninstall @commandArgs
            }
        }

        "search" {
            if ($assumeYes) {
                winget search @commandArgs `
                    --accept-source-agreements `
                    --disable-interactivity
            }
            else {
                winget search @commandArgs
            }
        }

        "info" {
            if ($assumeYes) {
                winget show @commandArgs `
                    --accept-source-agreements `
                    --disable-interactivity
            }
            else {
                winget show @commandArgs
            }
        }

        "list" {
            winget list @commandArgs
        }

        { $_ -in "update", "upgrade" } {
            if ($commandArgs.Length -eq 0) {
                if ($assumeYes) {
                    winget upgrade --all `
                        --accept-package-agreements `
                        --accept-source-agreements `
                        --disable-interactivity
                }
                else {
                    winget upgrade --all
                }
            }
            else {
                if ($assumeYes) {
                    winget upgrade @commandArgs `
                        --accept-package-agreements `
                        --accept-source-agreements `
                        --disable-interactivity
                }
                else {
                    winget upgrade @commandArgs
                }
            }
        }

        default {
            winget @yumArgs
        }
    }
}
#>

function Invoke-YumWrapper {
    param(
        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    if ($Arguments.Length -eq 0) {
        Write-Host "Usage: sudo yum [options] <command> [package]"
        return
    }

    # yum の -y / --assumeyes をどこに書いても拾う
    $assumeYes = ($Arguments -contains "-y") -or `
                 ($Arguments -contains "--assumeyes")

    # wingetには渡さない
    $yumArgs = @(
        $Arguments | Where-Object {
            $_ -ne "-y" -and $_ -ne "--assumeyes"
        }
    )

    if ($yumArgs.Length -eq 0) {
        Write-Host "Usage: sudo yum [options] <command> [package]"
        return
    }

    $command = $yumArgs[0]
    $commandArgs = @($yumArgs | Select-Object -Skip 1)

    switch ($command) {
        "install" {
            if ($assumeYes) {
                winget install @commandArgs `
                    --accept-package-agreements `
                    --accept-source-agreements `
                    --disable-interactivity
            }
            else {
                winget install @commandArgs
            }
        }

        { $_ -in "remove", "uninstall" } {
            if ($assumeYes) {
                winget uninstall @commandArgs `
                    --disable-interactivity
            }
            else {
                winget uninstall @commandArgs
            }
        }

        "search" {
            if ($assumeYes) {
                winget search @commandArgs `
                    --accept-source-agreements `
                    --disable-interactivity
            }
            else {
                winget search @commandArgs
            }
        }

        "info" {
            if ($assumeYes) {
                winget show @commandArgs `
                    --accept-source-agreements `
                    --disable-interactivity
            }
            else {
                winget show @commandArgs
            }
        }

        "list" {
            winget list @commandArgs
        }

        { $_ -in "update", "upgrade" } {
            if ($commandArgs.Length -eq 0) {
                if ($assumeYes) {
                    winget upgrade --all `
                        --accept-package-agreements `
                        --accept-source-agreements `
                        --disable-interactivity
                }
                else {
                    winget upgrade --all
                }
            }
            else {
                if ($assumeYes) {
                    winget upgrade @commandArgs `
                        --accept-package-agreements `
                        --accept-source-agreements `
                        --disable-interactivity
                }
                else {
                    winget upgrade @commandArgs
                }
            }
        }

        default {
            winget @yumArgs
        }
    }
}