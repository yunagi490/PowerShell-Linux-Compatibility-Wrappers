<#
============================================================
 PowerShell Compatibility Wrapper Tests - HTML Report Runner
============================================================
 Invoke-Pester の結果をブラウザで見やすいHTMLレポートとして出力します。
 ターミナルの流れる文字を追わなくても、結果が一覧で確認できます。

 使い方:
   .\RunTests_HTML.ps1
   .\RunTests_HTML.ps1 -NoOpen        # レポート生成だけしてブラウザは開かない
   .\RunTests_HTML.ps1 -TestsPath C:\path\to\tests
============================================================
#>

param(
    [string]$TestsPath = $PSScriptRoot,
    [switch]$NoOpen
)

# ---- 出力先の準備 ----
$OutputDir = Join-Path $TestsPath "TestResults"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}
$ReportPath = Join-Path $OutputDir "TestReport.html"

# ---- Pester実行(コンソール出力は最小限、結果はオブジェクトで受け取る) ----
$Config = New-PesterConfiguration
$Config.Run.Path = $TestsPath
$Config.Run.PassThru = $true
$Config.Output.Verbosity = "Minimal"

$Result = Invoke-Pester -Configuration $Config

# ---- HTMLエスケープ用ヘルパー ----
function ConvertTo-HtmlEncoded {
    param([string]$Text)    if ([string]::IsNullOrEmpty($Text)) { return "" }
    return $Text -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
}

function Get-StatusColor {
    param([string]$Status)
    switch ($Status) {
        "Passed" { return "#2ecc71" }
        "Failed" { return "#e74c3c" }
        "Skipped" { return "#f39c12" }
        default { return "#95a5a6" }
    }
}

# ---- テスト結果の行を生成(失敗を上に集める) ----
$sortedTests = $Result.Tests | Sort-Object -Property @{Expression = { $_.Result -ne "Failed" } }, @{Expression = { ($_.Path -join " > ") } }

$rows = foreach ($test in $sortedTests) {
    $color = Get-StatusColor $test.Result
    $errMsg = ""
    if ($test.ErrorRecord) {
        $errMsg = Encode-Html $test.ErrorRecord.Exception.Message
    }
    $path = Encode-Html ($test.Path -join " > ")
    $name = Encode-Html $test.Name
    $duration = [math]::Round($test.Duration.TotalMilliseconds, 1)

    @"
    <tr>
        <td>$path</td>
        <td>$name</td>
        <td style="color:$color; font-weight:bold;">$($test.Result)</td>
        <td>${duration} ms</td>
        <td class="err">$errMsg</td>
    </tr>
"@
}

$passRate = if ($Result.TotalCount -gt 0) {
    [math]::Round(($Result.PassedCount / $Result.TotalCount) * 100, 1)
}
else { 0 }

$overallColor = if ($Result.FailedCount -gt 0) { "#e74c3c" } else { "#2ecc71" }

# ---- HTML組み立て ----
$html = @"
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>PowerShell Wrapper テスト結果</title>
<style>
    body { font-family: 'Segoe UI', Meiryo, sans-serif; background:#f5f6fa; margin:0; padding:24px; color:#2c3e50; }
    h1 { font-size:20px; margin-bottom:4px; }
    .timestamp { color:#7f8c8d; font-size:12px; margin-bottom:20px; }
    .summary { display:flex; gap:16px; margin-bottom:24px; flex-wrap:wrap; }
    .card { background:white; border-radius:8px; padding:12px 20px; box-shadow:0 1px 3px rgba(0,0,0,0.12); min-width:90px; }
    .card .label { font-size:12px; color:#7f8c8d; }
    .card .num { font-size:26px; font-weight:bold; }
    .pass { color:#2ecc71; } .fail { color:#e74c3c; } .skip { color:#f39c12; }
    .banner { padding:10px 16px; border-radius:6px; color:white; font-weight:bold; margin-bottom:20px; background:$overallColor; display:inline-block; }
    table { width:100%; border-collapse:collapse; background:white; box-shadow:0 1px 3px rgba(0,0,0,0.12); }
    th, td { padding:8px 12px; border-bottom:1px solid #eee; text-align:left; font-size:13px; vertical-align:top; }
    th { background:#2c3e50; color:white; position:sticky; top:0; }
    tr:hover { background:#f9f9f9; }
    td.err { color:#c0392b; font-family:Consolas, monospace; font-size:12px; white-space:pre-wrap; }
</style>
</head>
<body>
    <h1>PowerShell Compatibility Wrapper - テスト結果</h1>
    <div class="timestamp">実行日時: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</div>

    <div class="banner">$(if ($Result.FailedCount -gt 0) { "FAILED" } else { "ALL PASSED" })</div>

    <div class="summary">
        <div class="card"><div class="label">合計</div><div class="num">$($Result.TotalCount)</div></div>
        <div class="card"><div class="label">成功</div><div class="num pass">$($Result.PassedCount)</div></div>
        <div class="card"><div class="label">失敗</div><div class="num fail">$($Result.FailedCount)</div></div>
        <div class="card"><div class="label">スキップ</div><div class="num skip">$($Result.SkippedCount)</div></div>
        <div class="card"><div class="label">成功率</div><div class="num">${passRate}%</div></div>
        <div class="card"><div class="label">実行時間</div><div class="num">$([math]::Round($Result.Duration.TotalSeconds, 2))s</div></div>
    </div>

    <table>
        <tr><th>Describe / Context</th><th>Test</th><th>Result</th><th>Duration</th><th>Error</th></tr>
        $rows
    </table>
</body>
</html>
"@

$html | Out-File -FilePath $ReportPath -Encoding UTF8

Write-Host ""
Write-Host "レポートを出力しました: $ReportPath"

if (-not $NoOpen) {
    Invoke-Item $ReportPath
}

# 呼び出し元(CIなど)で失敗を検知できるよう、失敗があれば非ゼロで終了
if ($Result.FailedCount -gt 0) {
    exit 1
}
