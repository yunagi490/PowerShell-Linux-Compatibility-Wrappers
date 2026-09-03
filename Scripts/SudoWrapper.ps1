# ============================================================
# sudo command compatibility wrapper
# Backend: Windows sudo / PowerShell dispatcher
# ============================================================
#
# 変更履歴:
#   v0.1.0
#     - 初版
#     - sudo compatibility dispatcher を実装
#     - yum / dnf / systemctl wrapper への振り分けを実装
#     - 未対応コマンドは Windows sudo.exe へフォールバック
#
#   v0.2.0
#     - Linux sudo 互換の講習メッセージを追加
#     - sudo 実行時にパスワード入力風の対話処理を追加
#     - パスワード入力中の文字を画面へ表示しないよう対応
#     - 入力内容は資格情報として使用・保存せず、
#       sudo 互換インターフェースの再現のみに使用
#     - yum / dnf / systemctl 実行時の sudo UX を改善
#
# ============================================================
$script:SudoLectureShown = $false

function Show-SudoLecture {
    if ($script:SudoLectureShown) {
        return
    }

    Write-Host ""
    Write-Host "あなたはシステム管理者から通常の講習を受けたはずです。"
    Write-Host "これは通常、以下の3点に要約されます:"
    Write-Host ""
    Write-Host "    #1) 他人のプライバシーを尊重すること。"
    Write-Host "    #2) タイプする前に考えること。"
    Write-Host "    #3) 大いなる力には大いなる責任が伴うこと。"
    Write-Host ""

    Wait-SudoPasswordInput

    $script:SudoLectureShown = $true
}
function Wait-SudoPasswordInput {
    <#
    .SYNOPSIS
        Linux sudo のパスワード入力UIを再現します。

    .DESCRIPTION
        入力された文字は画面に表示されません。
        また、入力内容そのものは保存・検証・認証には使用しません。
        sudo compatibility UX の再現のみを目的としています。
    #>
    param(
        [string]$UserName = $env:USERNAME
    )

    Write-Host -NoNewline "[sudo] $UserName のパスワード: "

    $inputLength = 0

    while ($true) {
        $key = [Console]::ReadKey($true)

        switch ($key.Key) {

            "Enter" {
                if ($inputLength -gt 0) {
                    Write-Host ""
                    return
                }
            }

            "Backspace" {
                if ($inputLength -gt 0) {
                    $inputLength--
                }
            }

            default {
                if (-not [char]::IsControl($key.KeyChar)) {
                    $inputLength++
                }
            }
        }
    }
}
function sudo {
    param(
        [Parameter(Position = 0)]
        [string]$Manager,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]$Arguments
    )

    switch ($Manager) {

        "yum" {
            Show-SudoLecture
            Invoke-YumWrapper @Arguments
        }

        "dnf" {
            Show-SudoLecture
            Invoke-DnfWrapper @Arguments
        }

        "systemctl" {
            Show-SudoLecture
            systemctl @Arguments
        }

        default {
            & "$env:SystemRoot\System32\sudo.exe" $Manager @Arguments
        }
    }
}