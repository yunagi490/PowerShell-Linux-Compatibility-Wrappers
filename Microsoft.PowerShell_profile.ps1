<#
============================================================
Legacy implementation / Maintenance reference
============================================================

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第二版」。

※ このブロックは実行されません。
============================================================

# Microsoft.PowerShell_profile.ps1

. "$PSScriptRoot\Scripts\YumWrapper.ps1"
. "$PSScriptRoot\Scripts\BrewWrapper.ps1"

# PowerToys CommandNotFound
# Import-Module -Name Microsoft.WinGet.CommandNotFound
#>
# ============================================================
# Current implementation
# ============================================================
<#
============================================================
Legacy implementation / Maintenance reference
============================================================

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第三版」。

※ このブロックは実行されません。
============================================================
## 第二版
# Package Manager Wrappers
. "$PSScriptRoot\Scripts\BrewWrapper.ps1"
. "$PSScriptRoot\Scripts\YumWrapper.ps1"
. "$PSScriptRoot\Scripts\DnfWrapper.ps1"

# sudo dispatcher
. "$PSScriptRoot\Scripts\SudoWrapper.ps1"


#>
<#
============================================================
Legacy implementation / Maintenance reference
============================================================

旧実装。
動作比較・デバッグ・保守時の参照用として保持。
現在使用している実装は下部の「第四版」。

※ このブロックは実行されません。
============================================================
# ============================================================
# Current implementation
# ============================================================
## 第三版
# Package Manager Wrappers
. "$PSScriptRoot\Scripts\YumWrapper.ps1"
. "$PSScriptRoot\Scripts\DnfWrapper.ps1"
. "$PSScriptRoot\Scripts\BrewWrapper.ps1"
. "$PSScriptRoot\Scripts\IpWrapper.ps1"
#. "$PSScriptRoot\Scripts\SystemctlWrapper.ps1"
# sudo dispatcher
. "$PSScriptRoot\Scripts\SudoWrapper.ps1"
#>
# ============================================================
# Current implementation
# ============================================================
## 第四版
# Module loader
. "$PSScriptRoot\Scripts\ModuleLoader.ps1"

# Package Manager Wrappers
. "$PSScriptRoot\Scripts\YumWrapper.ps1"
. "$PSScriptRoot\Scripts\DnfWrapper.ps1"
. "$PSScriptRoot\Scripts\BrewWrapper.ps1"

# System command wrappers
. "$PSScriptRoot\Scripts\IpWrapper.ps1"
. "$PSScriptRoot\Scripts\SystemctlWrapper.ps1"

# sudo dispatcher
. "$PSScriptRoot\Scripts\SudoWrapper.ps1"