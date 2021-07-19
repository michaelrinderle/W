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
. "$PSScriptRoot\install.ps1"

$global:system_color = "red"


Function Update-System{
    [OutputType([void])]
    Param()
    
    Show-Command "[*] Update-System : Started" $install_color

    Try{
        $global:Host.UI.RawUI.ForegroundColor = "white"

        # todo : check if bins exist
        choco update all -y 2>&1 | Out-Host      
        winget upgrade -all 2>&1 | Out-Host

        Set-Location "c:\vcpkg\"
        ./vcpkg upgrade --no-dry-run 2>&1 | Out-Host
        
        Exit-Command "[*] Update-System : Completed" $install_color

    } Catch{
        Write-Host $_
        Exit-Command "[*] Update-System : Error, aborting" $install_color
    }   
}

Function Clear-System{
    [OutputType([void])]
    Param()

    Show-Command "[*] Clear-System : Started" $system_color

    Try{
        Write-Host '[*] Clearing CleanMgr.exe automation settings & enable temp files cleanup.'
        Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name StateFlags0001 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Name StateFlags0001 -Value 2 -PropertyType DWord

        Write-Host 'Starting CleanMgr.exe runs'
        Start-Process -FilePath CleanMgr.exe -ArgumentList '/SAGERUN:1' -WindowStyle hidden -Wait
        #Start-Process -FilePath CleanMgr.exe -ArgumentList '/VERYLOWDISK' -WindowStyle Hidden -Wait
        #Start-Process -FilePath CleanMgr.exe -ArgumentList '/AUTOCLEAN' -WindowStyle Hidden -Wait

        Write-Host "[*] Starting cipher.exe"
        cipher.exe /w:C
        Start-Bleachbit -wipeFreeSpace $true

        Exit-Command "[*] Clear-System : Completed" $system_color 
        Return

    } Catch{
        Write-Host $_
        Exit-Command "[*] Clear-System : Error, aborted" $system_color 
    } 
}

Function Add-Path{
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $false)][string] $path
    )

    Show-Command "[*] Add-Path : Started" $system_color

    Try{
        If($null -eq $path){
            Write-Host "[*] Add-Path : Add path to add to system path enviroment variable."
            :loop While(1){
                Write-Host "> " -NoNewLine
                $in = $Host.UI.ReadLine()
                If([string]::IsNullOrEmpty($in)){
                        Write-Host "Try again"
                        Continue
                }
                Else{                   
                    Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path
                    $old = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
                    $path  =  "$old;$in"               
                }
            }
        }

        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path -Value $new
        Exit-Command "[*] Add-Path : Completed" $system_color
        Return $true;

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Add-Path : Error, aborted" $system_color
    Return $false
}

Function Set-EnvironmentVar{
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $false)][string] $var,
        [Parameter(Mandatory = $false)][string] $path
    )

    Show-Command "[*] Set-EnvironmentVar : Started" $system_color

    Try{

        If($null -eq $var -or
           $null -eq $path){
            Write-Host "[*] Add variable name and path <variable> (path)"
            :loop While(1){
                Write-Host "> " -NoNewLine
                $in = $Host.UI.ReadLine()
                If([string]::IsNullOrEmpty($in)){
                        Write-Host "Try again"
                        Continue
                }
                Else{     
                    $tokens = $in.split(" ")
                    if($tokens.Length -lt 1){
                        Write-Host "Try Again."
                        Continue;
                    }
                    $var = $tokens[0]
                    $path = $tokens[1]
                    break;
                }
            }
        }

        [System.Environment]::SetEnvironmentVariable($var,$path[1], [System.EnvironmentVariableTarget]::Machine)

        Exit-Command "[*] Set-EnvironmentVar : Completed" $system_color
        Return $true;
    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Set-EnvironmentVar : Error, aborted" $system_color
    Return $false
}

Function Start-Bleachbit{
    [OutputType([void])]
    Param($wipeFreeSpace)

    Show-Command "[*] Start-Bleachbit : Started" $system_color

    Try{
        $cleaners = bleachbit_console.exe --list
        IF($null -eq $cleaners){
            Exit-Command "[*] Start-Bleachbit : Not installed or bleachbit_console.exe not in path, aborting." $install_color
            Return
        }

        If($null -eq $wipeFreeSpace){
            $in = Read-Host "wipe free space? [y/n]"
            If($in.ToLower() -eq "y"){
                $wipeFreeSpace = $true
            }
        }

        # todo : move bleachbit cleaners to config
        $skip = @(
            "brave.passwords",
            "system.free_disk_space",
            "system.recycle_bin"
        )

        Foreach($cleaner in $cleaners){
            If($skip.Contains($cleaner)) { Continue } 
                bleachbit_console.exe --overwrite --clean $cleaner
        }

        If($wipeFreeSpace){
            bleachbit_console.exe --wipe-free-space ~/.cache/
        }

    } Catch{
        Write-Host $_
        Exit-Command "[*] Start-Bleachbit : Error, aborted" $system_color 
    }   
}

Function Stop-Services{
    [OutputType([void])]
    Param()

    Show-Command "[*] Stop-Services : Started" $system_color

    Try{
        $services = @(
        "Connected User Experiences and Telemetry Service",
        "IP Helper",
        "Portable Device Enumerator Service",
        "Remote Registry",
        "Secondary Logon",
        "Software Protection",
        "SSDP Discovery",
        "TCP/IP NetBIOS Helper",
        "Touch Keyboard and Handwriting Panel Service",
        "Windows Media Player Network Sharing Service",
        "Windows Time")
        
        Foreach($service in $services){
            Try{
                Set-Service -Name $service -StartupType disabled
                Stop-Service -Name $service
            } Catch{ Write-Host $_ }   
        }  

        Exit-Command "[*] Stop-Services : Completed" $system_color  
        Return

    } Catch{
        Write-Host $_
        Exit-Command "[*] Stop-Services : Error, aborted" $system_color  
    }
}

Function Remove-WindowsAppxs{
    [OutputType([bool])]
    Param()
    
    Show-Command "[*] Remove-WindowsAppxs : Started" $system_color

    Try{
        $appx = @("3d",
            "3dbuilder",
            "alarms",
            "appconnector",
            "appinstaller",
            "AutodeskSketchBook",
            "bing",
            "bingfinance",
            "bingnews",
            "bingsports",
            "bingweather",
            "BubbleWitch3Saga",
            "calculator",
            "camera",
            "candycrushsodasaga",
            "commsphone",
            "communicationsapps",
            "connectivitystore",
            "DisneyMagicKingdoms",
            "DrawboardPDF",
            "Duolingo",
            "Eclipse",
            "FarmVille",
            "feedback",
            "FLipboard",
            "FreshPaint",
            "getstarted",
            "holographic",
            "king.com",
            "Mahjong",
            "maps",
            "MarchofEmpires",
            "messaging",
            "MicrosoftSudoku",
            "mspaint",
            "NetworkSpeedTest",
            "NYTCrossword",
            "officehub",
            "oneconnect",
            "onenote",
            "pandora",
            "people",
            "phone",
            "photo",
            "photos",
            "skypeapp",
            "solit",
            "solitaire",
            "soundrec",
            "soundrecorder",
            "Spotify",
            "sticky",
            "sway",
            "twitter",
            "wallet",
            "windowscommunicationsapps",
            "windowsphone",
            "witch",
            "Wunderlist",
            "xbox",
            "zune",
            "zunemusic",
            "zunevideo")
        
        Foreach($app in $appx){
            try{
                Remove-AppxPackage $app
            } catch{ Write-Host $_ }   
        }
        
        Exit-Command "[*] Remove-WindowsAppxs : Completed" $system_color
        Return $true

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Remove-WindowsAppxs : Error, aborted" $system_color    
    Return $false  
}

Function Remove-WindowsAppx{
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $false)][string] $appName
    )

    Show-Command "[*] Remove-WindowsAppxs : Started" $system_color

    Try{

        if($null -eq $appName){
            $appName = Read-Host "appName"
        }

        if([string]::IsNullOrEmpty($appName)){
            $appName = Read-Host "appName"
            Exit-Command "[*] Remove-WindowsAppxs : No input, aborting" $system_color
            Return $false
        }

        Get-AppxPackage | where-object {$_.name -like "*$appName*"} | Remove-AppxPackage
        Get-AppxPackage -AllUsers | where-object {$_.name -like "*$appName*"} | Remove-AppxPackag
        
        Exit-Command "[*] Remove-WindowsAppxs : Completed" $system_color
        Return $true

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Remove-WindowsAppxs : Error, aborted" $system_color
    Return $false
}
