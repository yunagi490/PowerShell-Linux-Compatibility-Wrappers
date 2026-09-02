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
    param(
        [Parameter(Position = 0)]
        [string]$Manager,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    switch ($Manager) {
        "yum" {
            Invoke-YumWrapper @Arguments
        }

        "dnf" {
            Invoke-DnfWrapper @Arguments
        }

        default {
            # 必要なら本物のWindows sudo.exeへ
            & "$env:SystemRoot\System32\sudo.exe" $Manager @Arguments
        }
    }
}

function Invoke-DnfWrapper {
    param(
        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    if ($Arguments.Length -eq 0) {
        Write-Host "Usage: sudo dnf <command> [module]"
        return
    }

    # -y / --assumeyes をどこに書いても拾う
    $assumeYes = ($Arguments -contains "-y") -or `
                 ($Arguments -contains "--assumeyes")

    # dnf固有オプションなのでPowerShellGetには渡さない
    $dnfArgs = @(
        $Arguments | Where-Object {
            $_ -ne "-y" -and $_ -ne "--assumeyes"
        }
    )

    if ($dnfArgs.Length -eq 0) {
        Write-Host "Usage: sudo dnf <command> [module]"
        return
    }

    $command = $dnfArgs[0]
    $moduleArgs = @($dnfArgs | Select-Object -Skip 1)

    switch ($command) {
        "install" {
            if ($assumeYes) {
                Install-Module @moduleArgs -Force -Confirm:$false
            }
            else {
                Install-Module @moduleArgs
            }
        }

        { $_ -in "remove", "uninstall" } {
            if ($assumeYes) {
                Uninstall-Module @moduleArgs -Force -Confirm:$false
            }
            else {
                Uninstall-Module @moduleArgs
            }
        }

        { $_ -in "update", "upgrade" } {
            if ($assumeYes) {
                Update-Module @moduleArgs -Force -Confirm:$false
            }
            else {
                Update-Module @moduleArgs
            }
        }

        "search" {
            Find-Module @moduleArgs
        }

        "info" {
            Find-Module @moduleArgs
        }

        "list" {
            Get-InstalledModule @moduleArgs
        }

        default {
            Write-Host "dnf: Unknown command '$command'"
        }
    }
}
#>
# ============================================================
# Current implementation
# ============================================================
## 第二版
function Invoke-DnfWrapper {
    param(
        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    if ($Arguments.Length -eq 0) {
        Write-Host "Usage: sudo dnf [options] <command> [module]"
        return
    }

    # dnf の -y / --assumeyes をどこに書いても拾う
    $assumeYes = ($Arguments -contains "-y") -or `
                 ($Arguments -contains "--assumeyes")

    # PowerShellGetには渡さない
    $dnfArgs = @(
        $Arguments | Where-Object {
            $_ -ne "-y" -and $_ -ne "--assumeyes"
        }
    )

    if ($dnfArgs.Length -eq 0) {
        Write-Host "Usage: sudo dnf [options] <command> [module]"
        return
    }

    $command = $dnfArgs[0]
    $moduleArgs = @($dnfArgs | Select-Object -Skip 1)

    switch ($command) {
        "install" {
            if ($assumeYes) {
                Install-Module @moduleArgs -Force -Confirm:$false
            }
            else {
                Install-Module @moduleArgs
            }
        }

        { $_ -in "remove", "uninstall" } {
            if ($assumeYes) {
                Uninstall-Module @moduleArgs -Force -Confirm:$false
            }
            else {
                Uninstall-Module @moduleArgs
            }
        }

        { $_ -in "update", "upgrade" } {
            if ($assumeYes) {
                Update-Module @moduleArgs -Force -Confirm:$false
            }
            else {
                Update-Module @moduleArgs
            }
        }

        "search" {
            Find-Module @moduleArgs
        }

        "info" {
            Find-Module @moduleArgs
        }

        "list" {
            Get-InstalledModule @moduleArgs
        }

        default {
            Write-Host "dnf: Unknown command '$command'"
        }
    }
}
    