#      __ _/| _/. _  ._/__ /
#   _\/_// /_///_// / /_|/
#             _/
#   sof digital 2021
#   written by michael rinderle <michael@sofdigital.net>
#
#   mit license
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#   SOFTWARE.

. "$PSScriptRoot\common.ps1"

$global:registry_color = "Blue"

Function Save-RegistryKey{
    [OutputType([void])]
    Param(
        [Parameter(Mandatory = $false)][string] $path,
        [Parameter(Mandatory = $false)][string] $name,
        [Parameter(Mandatory = $false)][string] $type,
        [Parameter(Mandatory = $false)][string] $value
    )

    Show-Command "[*] Save-RegistryKey : Started" $install_color

    try{
        if(![string]::IsNullOrEmpty($path)){
            $path = Read-Host "path"
            $name = Read-Host "name"
            $type = Read-Host "type"
            $value = Read-Host "value"
        }

        If([string]::IsNullOrEmpty($path) -or
           [string]::IsNullOrEmpty($name) -or
           [string]::IsNullOrEmpty($type) -or
           [string]::IsNullOrEmpty($value)){
            Write-Host "[*] Save-RegistryKey : Invalid input, aborting."
            Return
        }

        If(-Not(Test-Path "Registry::$path")){
            New-Item -Path "Registry::$Key" -ItemType RegistryKey -Force
        }

        Set-ItemProperty -path "Registry::$path" -Name $name -Type $type -Value $value
        Exit-Command "[*] Save-RegistryKey : Completed" $install_color

    } Catch{
        Write-Host $_
        Exit-Command "[*] Save-RegistryKey : Error, aborting" $install_color
    }    
}

Function Confirm-RegistryKey{
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $false)][string] $regKeyPath,
        [Parameter(Mandatory = $false)][string] $regValueName
    )
  
    Show-Command "[*] Confirm-RegistryKey : Started" $registry_color

    Try{
        If([string]::IsNullOrEmpty($regKeyPath)){
            $regKeyPath = Read-Host "regKeyPath"
            $regValueName = Read-Host "regValueName"
        }
        
        If([string]::IsNullOrEmpty($regKeyPath) -or
           [string]::IsNullOrEmpty($regValueName)){
            Write-Host "[*] Confirm-RegistryKey : Invalid input, aborting."
            Return
        }
        
        Exit-Command "[*] Confirm-RegistryKey : Completed" $registry_color
        Return (Get-Item $regKeyPath -EA Ignore).Property -contains $regValueName

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Confirm-RegistryKey : Error accessing registry" $registry_color
    Return $false
}

Function Get-RegistryKey{
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $false)][string] $path
    )

    Show-Command "[*] Get-RegistryKey : Started" $registry_color

    Try{
        If([string]::IsNullOrEmpty($path)){
            $path = Read-Host "path"
        }
            
        If([string]::IsNullOrEmpty($path) -or
           [string]::IsNullOrEmpty($regValueName)){
            Write-Host "[*] Get-RegistryKey : Invalid input, aborting."
            Return
        }
        
        Exit-Command "[*] Get-RegistryKey : Completed" $registry_color
        Return Get-Item -path $path

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Get-RegistryKey : Error accessing registry" $registry_color
    Return $null
}

Function Set-RegistryKey{
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $false)][string] $path,
        [Parameter(Mandatory = $false)][string] $name,
        [Parameter(Mandatory = $false)] $value
    )

    Show-Command "[*] Set-RegistryKey : Started" $registry_color

    Try{
        if([string]::IsNullOrEmpty($path)){
            $path = Read-Host "path"
            $name = Read-Host "name"
            $value = Read-Host "value"
        }
        Set-Itemproperty -path $path -Name $name -value $value
            
        If([string]::IsNullOrEmpty($path) -or
           [string]::IsNullOrEmpty($name) -or
           [string]::IsNullOrEmpty($value)){
            Write-Host "[*] Set-RegistryKey : Invalid input, aborting."
            Return
        }
        
        Set-Itemproperty -path $path -Name $name -value $value
        Exit-Command "[*] Set-RegistryKey : Completed" $registry_color
        Return $true

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Set-RegistryKey : Error accessing registry" $registry_color
    Return $false
}

Function Search-RegistryKey{
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $false)][string] $name
    )

    Show-Command "[*] Search-RegistryKey : Started" $registry_color

    Try{
        If([string]::IsNullOrEmpty($name)){
            $name = Read-Host "name"
        }
            
        If([string]::IsNullOrEmpty($name)){
            Write-Host "[*] Search-RegistryKey : Invalid input, aborting."
            Return
        }
        
        Exit-Command "[*] Search-RegistryKey : Completed" $registry_color
        Return get-childitem -path hkcu:\ -recurse -ErrorAction SilentlyContinue | Where-Object {$_.Name -like "*$name*"}

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Search-RegistryKey : Error accessing registry" $registry_color
    Return $null    
}

Function Switch-DesktopTaskbarSize{
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $false)][string] $size
    )

    Show-Command "[*] Switch-DesktopTaskbarSize : Started" $registry_color

    Try{
        If([string]::IsNullOrEmpty($size)){
            $size = Read-Host "size (0,1,2)"
        }
            
        If([string]::IsNullOrEmpty($size)){
            Write-Host "[*] Switch-DesktopTaskbarSize : Invalid input, aborting."
            Return
        }
        
        # dword 32 (TaskbarSi) 0,1,2
        $path = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        $key = "TaskbarSi"
        if(Confirm-Registy-Key($path, $key)){
            Set-Registry-Key($path, $key, $size)
        }

        Restart-Service -Name Explorer
        Exit-Command "[*] Switch-DesktopTaskbarSize : Completed" $registry_color
        Return $true

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Switch-DesktopTaskbarSize : Error accessing registry" $registry_color
    Return $false  
}

Function Switch-DesktopTaskbarLocation{
    [OutputType([void])]
    Param()
    Show-Command "[*] Switch-DesktopTaskbarLocation : Started" $registry_color
    # todo : win 11 is buggy. check back later
    # change second row, fifth column from 03 to 01
    # HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3
    # HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MMStuckRects3
    Exit-Command "[*] Switch-DesktopTaskbarLocation : Not implemented" $registry_color
}