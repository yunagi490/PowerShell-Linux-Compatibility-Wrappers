$Config = New-PesterConfiguration

$Config.Run.Path = $PSScriptRoot
$Config.Output.Verbosity = "Detailed"
$TestRoot = $PSScriptRoot

Invoke-Pester -Path $TestRoot

Invoke-Pester -Configuration $Config