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
        "systemctl" {
        systemctl @Arguments
        }

        default {
            # Microsoft公式 sudo.exe へフォールバック
            & "$env:SystemRoot\System32\sudo.exe" $Manager @Arguments
        }
    }
}