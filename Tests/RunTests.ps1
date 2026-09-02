<#
============================================================
Legacy implementation / Maintenance reference
============================================================

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第二版」。

※ このブロックは実行されません。
============================================================
$Config = New-PesterConfiguration

$Config.Run.Path = $PSScriptRoot
$Config.Output.Verbosity = "Detailed"
$TestRoot = $PSScriptRoot

Invoke-Pester -Path $TestRoot

Invoke-Pester -Configuration $Config
#>
# ============================================================
# Current implementation
# ============================================================
## 第二版
# ============================================================
# PowerShell Compatibility Wrappers
# Test Runner
# ============================================================

$testsPath = $PSScriptRoot

Write-Host ""
Write-Host "========================================"
Write-Host " PowerShell Compatibility Wrapper Tests"
Write-Host "========================================"
Write-Host ""

Invoke-Pester `
    -Path $testsPath `
    -Output Detailed
