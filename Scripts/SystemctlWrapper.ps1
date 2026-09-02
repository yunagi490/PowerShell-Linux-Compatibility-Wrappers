<#
============================================================
Legacy implementation / Maintenance reference
============================================================

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第二版」。

※ このブロックは実行されません。
============================================================


# ============================================================
# systemctl compatibility wrapper
# Target: Windows Service Control Manager
# ============================================================

function systemctl {
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    if ([string]::IsNullOrWhiteSpace($Command)) {
        Write-Host "Usage: systemctl <command> [service]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  status <service>      Show service status"
        Write-Host "  start <service>       Start service"
        Write-Host "  stop <service>        Stop service"
        Write-Host "  restart <service>     Restart service"
        Write-Host "  enable <service>      Enable service at startup"
        Write-Host "  disable <service>     Disable service at startup"
        Write-Host "  is-active <service>   Check whether service is active"
        Write-Host "  list-units            List services"
        return
    }

    switch ($Command) {

        # --------------------------------------------------------
        # systemctl status
        # --------------------------------------------------------
        "status" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl status <service>"
                return
            }

            $service = Get-Service -Name $Arguments[0] -ErrorAction SilentlyContinue

            if (-not $service) {
                Write-Host "Unit $($Arguments[0]).service could not be found."
                return
            }

            $startupType = (Get-CimInstance Win32_Service `
                -Filter "Name='$($service.Name)'" `
                -ErrorAction SilentlyContinue
            ).StartMode

            $activeState = if ($service.Status -eq "Running") {
                "active (running)"
            }
            else {
                "inactive ($($service.Status.ToString().ToLower()))"
            }

            Write-Host "● $($service.Name).service - $($service.DisplayName)"
            Write-Host "     Loaded: loaded; $startupType"
            Write-Host "     Active: $activeState"
            Write-Host "     Status: $($service.Status)"
        }

        # --------------------------------------------------------
        # systemctl start
        # --------------------------------------------------------
        "start" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl start <service>"
                return
            }

            Start-Service -Name $Arguments[0]
        }

        # --------------------------------------------------------
        # systemctl stop
        # --------------------------------------------------------
        "stop" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl stop <service>"
                return
            }

            Stop-Service -Name $Arguments[0]
        }

        # --------------------------------------------------------
        # systemctl restart
        # --------------------------------------------------------
        "restart" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl restart <service>"
                return
            }

            Restart-Service -Name $Arguments[0]
        }

        # --------------------------------------------------------
        # systemctl enable
        # --------------------------------------------------------
        "enable" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl enable <service>"
                return
            }

            Set-Service `
                -Name $Arguments[0] `
                -StartupType Automatic
        }

        # --------------------------------------------------------
        # systemctl disable
        # --------------------------------------------------------
        "disable" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl disable <service>"
                return
            }

            Set-Service `
                -Name $Arguments[0] `
                -StartupType Disabled
        }

        # --------------------------------------------------------
        # systemctl is-active
        # --------------------------------------------------------
        "is-active" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl is-active <service>"
                return
            }

            $service = Get-Service `
                -Name $Arguments[0] `
                -ErrorAction SilentlyContinue

            if (-not $service) {
                Write-Host "unknown"
                return
            }

            if ($service.Status -eq "Running") {
                Write-Host "active"
            }
            else {
                Write-Host "inactive"
            }
        }

        # --------------------------------------------------------
        # systemctl list-units
        # --------------------------------------------------------
        "list-units" {
            Get-Service |
                Sort-Object Name |
                Format-Table `
                    Name,
                    Status,
                    DisplayName `
                    -AutoSize
        }

        default {
            Write-Host "systemctl: Unknown command '$Command'"
        }
    }
}
    #>
# ============================================================
# Current implementation
# ============================================================
## 第二版
function systemctl {
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    if ([string]::IsNullOrWhiteSpace($Command)) {
        Write-Host "Usage: systemctl <command> [service]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  status <service>      Show service status"
        Write-Host "  start <service>       Start service"
        Write-Host "  stop <service>        Stop service"
        Write-Host "  restart <service>     Restart service"
        Write-Host "  enable <service>      Enable service at startup"
        Write-Host "  disable <service>     Disable service at startup"
        Write-Host "  is-active <service>   Check whether service is active"
        Write-Host "  list-units            List services"
        return
    }

    switch ($Command) {

        # --------------------------------------------------------
        # systemctl status
        # --------------------------------------------------------
        "status" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl status <service>"
                return
            }

            $service = Get-Service -Name $Arguments[0] -ErrorAction SilentlyContinue

            if (-not $service) {
                Write-Host "Unit $($Arguments[0]).service could not be found."
                return
            }

            $startupType = (Get-CimInstance Win32_Service `
                -Filter "Name='$($service.Name)'" `
                -ErrorAction SilentlyContinue
            ).StartMode

            $activeState = if ($service.Status -eq "Running") {
                "active (running)"
            }
            else {
                "inactive ($($service.Status.ToString().ToLower()))"
            }

            Write-Host "● $($service.Name).service - $($service.DisplayName)"
            Write-Host "     Loaded: loaded; $startupType"
            Write-Host "     Active: $activeState"
            Write-Host "     Status: $($service.Status)"
        }

        # --------------------------------------------------------
        # systemctl start
        # --------------------------------------------------------
        "start" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl start <service>"
                return
            }

            Start-Service -Name $Arguments[0]
        }

        # --------------------------------------------------------
        # systemctl stop
        # --------------------------------------------------------
        "stop" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl stop <service>"
                return
            }

            Stop-Service -Name $Arguments[0]
        }

        # --------------------------------------------------------
        # systemctl restart
        # --------------------------------------------------------
        "restart" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl restart <service>"
                return
            }

            Restart-Service -Name $Arguments[0]
        }

# --------------------------------------------------------
# systemctl enable [--now] <service>
# --------------------------------------------------------
"enable" {
    if ($Arguments.Count -eq 0) {
        Write-Host "Usage: systemctl enable [--now] <service>"
        return
    }

    $now = $Arguments -contains "--now"

    $serviceArgs = @(
        $Arguments | Where-Object {
            $_ -ne "--now"
        }
    )

    if ($serviceArgs.Count -eq 0) {
        Write-Host "Usage: systemctl enable [--now] <service>"
        return
    }

    $serviceName = $serviceArgs[0]

    try {
        Set-Service `
            -Name $serviceName `
            -StartupType Automatic `
            -ErrorAction Stop

        Write-Host "Created symlink /etc/systemd/system/multi-user.target.wants/$serviceName.service"

        if ($now) {
            Start-Service `
                -Name $serviceName `
                -ErrorAction Stop
        }
    }
    catch {
        Write-Host "Failed to enable unit: $($_.Exception.Message)"
    }
}

# --------------------------------------------------------
# systemctl disable [--now] <service>
# --------------------------------------------------------
"disable" {
    if ($Arguments.Count -eq 0) {
        Write-Host "Usage: systemctl disable [--now] <service>"
        return
    }

    $now = $Arguments -contains "--now"

    $serviceArgs = @(
        $Arguments | Where-Object {
            $_ -ne "--now"
        }
    )

    if ($serviceArgs.Count -eq 0) {
        Write-Host "Usage: systemctl disable [--now] <service>"
        return
    }

    $serviceName = $serviceArgs[0]

    try {
        if ($now) {
            Stop-Service `
                -Name $serviceName `
                -ErrorAction Stop
        }

        Set-Service `
            -Name $serviceName `
            -StartupType Disabled `
            -ErrorAction Stop

        Write-Host "Removed /etc/systemd/system/multi-user.target.wants/$serviceName.service"
    }
    catch {
        Write-Host "Failed to disable unit: $($_.Exception.Message)"
    }
}
        # --------------------------------------------------------
        # systemctl is-active
        # --------------------------------------------------------
        "is-active" {
            if ($Arguments.Count -eq 0) {
                Write-Host "Usage: systemctl is-active <service>"
                return
            }

            $service = Get-Service `
                -Name $Arguments[0] `
                -ErrorAction SilentlyContinue

            if (-not $service) {
                Write-Host "unknown"
                return
            }

            if ($service.Status -eq "Running") {
                Write-Host "active"
            }
            else {
                Write-Host "inactive"
            }
        }

        # --------------------------------------------------------
        # systemctl list-units
        # --------------------------------------------------------
        "list-units" {
            Get-Service |
                Sort-Object Name |
                Format-Table `
                    Name,
                    Status,
                    DisplayName `
                    -AutoSize
        }

        default {
            Write-Host "systemctl: Unknown command '$Command'"
        }
    }
}