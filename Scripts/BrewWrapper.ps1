function brew {
    if ($args.Length -eq 0) {
        Write-Host "Usage: brew install <package>"
    } elseif ($args[0] -eq "install") {
        choco install $args[1..$args.Length] -y
    } elseif ($args[0] -eq "uninstall") {
        choco uninstall $args[1..$args.Length] -y
    } elseif ($args[0] -eq "upgrade") {
        choco upgrade $args[1..$args.Length] -y
    } elseif ($args[0] -eq "-v"){
        choco --version $args[1..$args.Length] -y
    }else{
      choco $args
    }
}

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

# Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58
