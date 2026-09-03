# PowerShell Linux Compatibility Wrappers

Windows 11 / PowerShell 上で、Linux / CentOS 7 ライクなコマンド操作を提供する互換レイヤーです。

> **LinuxをWindows上で動かすプロジェクトではありません。**  
> **WindowsをWindowsのままLinuxっぽく操作するプロジェクトです。**

WSLや仮想マシンによるLinux環境ではなく、Linux系コマンドをWindows標準機能やWindows向けパッケージマネージャーへ変換します。

## Features

現在、以下のコマンドに対応しています。

| Command     | Windows Backend                 | Description                     |
| ----------- | ------------------------------- | ------------------------------- |
| `yum`       | winget                          | パッケージ管理                  |
| `dnf`       | PowerShellGet                   | PowerShellモジュール管理        |
| `brew`      | Chocolatey                      | パッケージ管理                  |
| `sudo`      | Windows sudo / Dispatcher       | 各Wrapperへのコマンド振り分け   |
| `ip`        | NetTCPIP / NetAdapter           | ネットワーク情報表示            |
| `ifconfig`  | NetTCPIP / NetAdapter           | net-tools風ネットワーク情報表示 |
| `systemctl` | Windows Service Control Manager | Windowsサービス管理             |

## Requirements

- Windows 11
- PowerShell
- winget
- Chocolatey
- PowerShellGet

テストを実行する場合：

- Pester 6.0以上

## Usage

### yum

`yum` コマンドを `winget` に変換します。

```powershell
sudo yum install git
sudo yum -y install git
sudo yum install git -y

yum search git
yum remove git
yum upgrade
```

概念的には次のように変換されます。

```text
yum install <package>  -> winget install <package>
yum search <package>   -> winget search <package>
yum remove <package>   -> winget uninstall <package>
yum upgrade            -> winget upgrade --all
```

`-y` / `--assumeyes` にも対応しています。

### dnf

`dnf` をPowerShellGetの操作へ変換します。

```powershell
sudo dnf install Pester
sudo dnf install Pester -y
sudo dnf -y install Pester

dnf search Pester
dnf list
dnf update Pester
dnf remove Pester
```

主な対応関係：

```text
dnf install <module> -> Install-Module
dnf remove <module>  -> Uninstall-Module
dnf search <module>  -> Find-Module
dnf list             -> Get-InstalledModule
dnf update <module>  -> Update-Module
```

### brew

Homebrew風のコマンドをChocolateyへ変換します。

```powershell
brew install git
brew uninstall git
brew upgrade git
brew --version
```

```text
brew install <package>   -> choco install <package>
brew uninstall <package> -> choco uninstall <package>
brew upgrade <package>   -> choco upgrade <package>
```

### ip

WindowsのネットワークCmdletを使用して、`iproute2` 風の操作を提供します。

```powershell
ip addr
ip a
ip addr show

ip link

ip route
ip r

ip neigh
ip n
```

主に以下のWindows Cmdletを使用します。

```text
Get-NetIPAddress
Get-NetAdapter
Get-NetRoute
Get-NetNeighbor
```

### ifconfig

古典的な `net-tools` の `ifconfig` 風出力を提供します。

```powershell
ifconfig
ifconfig -a
ifconfig lo
ifconfig Ethernet
```

WindowsのNIC名をそのまま使用します。

### systemctl

Windows Service Control Managerを `systemctl` 風に操作します。

```powershell
systemctl status Spooler
systemctl is-active Spooler
systemctl is-enabled Spooler

systemctl start <service>
systemctl stop <service>
systemctl restart <service>

systemctl enable <service>
systemctl enable --now <service>

systemctl disable <service>
systemctl disable --now <service>

systemctl list-units
```

主な対応関係：

```text
systemctl start      -> Start-Service
systemctl stop       -> Stop-Service
systemctl restart    -> Restart-Service
systemctl enable     -> Set-Service -StartupType Automatic
systemctl disable    -> Set-Service -StartupType Disabled
systemctl is-active  -> Get-Service
systemctl is-enabled -> Win32_Service.StartMode
```

`enable --now` / `disable --now` にも対応しています。

> [!NOTE]
> systemdとWindows Service Control Managerは異なるサービス管理システムです。
> `enable` / `disable` などは完全な互換ではなく、Windows上で近い操作へ変換しています。

## Project Structure

```text
PowerShell/
├─ Scripts/
│  ├─ Network/
│  │  └─ NetworkCommon.ps1
│  ├─ BrewWrapper.ps1
│  ├─ DnfWrapper.ps1
│  ├─ IfconfigWrapper.ps1
│  ├─ IpWrapper.ps1
│  ├─ ModuleLoader.ps1
│  ├─ SudoWrapper.ps1
│  ├─ SystemctlWrapper.ps1
│  └─ YumWrapper.ps1
│
├─ Tests/
│  ├─ BrewWrapper.Tests.ps1
│  ├─ DnfWrapper.Tests.ps1
│  ├─ IfconfigWrapper.Tests.ps1
│  ├─ IpWrapper.Tests.ps1
│  ├─ RunTests.ps1
│  ├─ SystemctlWrapper.Tests.ps1
│  └─ YumWrapper.Tests.ps1
│
├─ .vscode/
├─ Microsoft.PowerShell_profile.ps1
└─ README.md
```

## Tests

テストにはPester 6を使用しています。

個別テスト：

```powershell
Invoke-Pester "$(Split-Path $PROFILE)\Tests\SystemctlWrapper.Tests.ps1"
```

全テスト：

```powershell
& "$(Split-Path $PROFILE)\Tests\RunTests.ps1"
```

Windowsサービスやパッケージを実際に変更しないよう、外部操作を伴うテストではPesterのMockを使用しています。

## Design

このプロジェクトはLinux APIやsystemdそのものをエミュレートするものではありません。

例えば、

```text
systemctl
    ↓
Windows Service Control Manager

yum
    ↓
winget

ifconfig
    ↓
Get-NetAdapter / Get-NetIPAddress
```

のように、Linuxライクなコマンドを受け取り、Windowsネイティブの機能へ翻訳します。

そのため、Linuxとの完全な互換性よりも、

**「Windows上でLinux系コマンドの操作感を提供すること」**

を目的としています。

## Limitations

- Linuxとの完全互換ではありません
- systemd固有の機能には対応していません
- WindowsとLinuxで概念が異なる機能は近似的に変換しています
- Windowsの管理者権限が必要になる操作があります
- `ifconfig` のインターフェース名にはWindows側のNIC名を使用します
- 対応していないLinuxコマンド・オプションがあります

## Development

PSScriptAnalyzerによる静的解析と、Pesterによるテストを使用しています。

新しいWrapperを追加する場合は、可能な限りWindowsネイティブのCmdlet/APIをバックエンドとして使用します。

---

Windowsなのに、

```powershell
sudo yum install
systemctl status
ifconfig
```

が通る環境を作りたかった。

それだけです。
