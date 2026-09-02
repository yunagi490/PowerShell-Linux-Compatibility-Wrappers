# ============================================================
# PowerShell Module Loader
# ============================================================

$requiredPesterVersion = [version]"6.0.0"

$pester = Get-Module Pester -ListAvailable |
    Where-Object Version -ge $requiredPesterVersion |
    Sort-Object Version -Descending |
    Select-Object -First 1

if ($pester) {
    Remove-Module Pester -Force -ErrorAction SilentlyContinue
    Import-Module Pester -RequiredVersion $pester.Version -Force
}