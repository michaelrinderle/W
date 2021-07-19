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
. "$PSScriptRoot\registry.ps1"

$global:install_color = "Blue"

Function Install-WindowsFeatures{
    [OutputType([void])]
    Param()

    Show-Command "[*] Install-WindowsFeatures : Started" $install_color

    Write-Host "[*] Install-WindowsFeatures : Installing Powershell 7"
    iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI" 2>&1 | Out-Host

    $global:Host.UI.RawUI.ForegroundColor = "white"
    Foreach($feature in $global:Config.Packages.WindowsFeatures){
        Enable-WindowsOptionalFeature -Online -FeatureName $feature 2>&1 | Out-Host
    }

    Restart-Computer -Wait -For PowerShell -ComputerName $env:computername

    Exit-Command "[*] Install-WindowsFeatures : Completed" $install_color
}

Function Install-Winget{
    [OutputType([void])]
    Param()

    Show-Command "[*] Install-Winget : Started" $install_color 

    $global:Host.UI.RawUI.ForegroundColor = "white"
    Foreach($package in $global:Config.Packages.WingetPackages){
        Try{
            winget install -e --id $package 2>&1 | Out-Host 
        } Catch{
            Write-Host $_
        }            
    }

    Exit-Command "[*] Install-Winget : Completed" $install_color
}

Function Install-Chocolately{
    [OutputType([void])]
    Param()

    Show-Command "[*] Install-Chocolately : Started" $install_color

    Write-Host "[*] Install-Chocolately : Checking of choco.exe exists"
    $global:Host.UI.RawUI.ForegroundColor = "white"
    $choco = powershell choco -v
    If(-not($choco)){

        Set-ExecutionPolicy AllSigned
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    $global:Host.UI.RawUI.ForegroundColor = $install_color
    Write-Host "[*] Install-Chocolately : Installing packages"

    $global:Host.UI.RawUI.ForegroundColor = "white"
    Foreach($package in $global:Config.Packages.ChocolatelyPackages){
        Try{
            choco install -y --force $package 2>&1 | Out-Host 
        } Catch{
            Write-Host $_ 
        }  
    }

    Exit-Command "[*] Install-Chocolately : Completed" $install_color
}

Function Install-VsWorkloads{
    [OutputType([void])]
    Param()

    Show-Command "[*] Install-VsWorkloads : Started" $install_color
    # Set-Location("C:\Program Files (x86)\Microsoft Visual Studio\Installer")
    # Get-Childitem -recurse -filter "vs_installer.exe"

    # .\vs_installer.exe modify `
    # --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Buildtools" `
    # --add Microsoft.VisualStudio.Component.Azure.AuthoringTools `
    # --
    # --downloadThenInstall --quiet 2>&1 | Out-Host
    Exit-Command "[*] Install-VsWorkloads : Not implemented yet"  $install_color
}

Function Install-VSCodeExtensions{
    [OutputType([void])]
    Param()

    Show-Command "[*] Install-VSCodeExtensions : Started" $install_color 

    Write-host "[*] Install-VSCodeExtensions : Installing extensions"
    $global:Host.UI.RawUI.ForegroundColor = "white"
    Foreach($extension in $global:Config.Packages.VSCodeExtensions){
        Try{
            code --install-extension $extension 2>&1 | Out-Host
        } Catch{
            Write-Host $_
        }         
    }

    Exit-Command "[*] Install-VSCodeExtensions : Completed" $install_color 
}

Function Install-Vcpkg{
    [OutputType([void])]
    Param()

    Show-Command "[*] Install-Vcpkg : Started" $install_color 

    Try{
        $vcpkg = Test-Path c:\vcpkg
        If($vcpkg){
            Exit-Command "[*] Install-Vcpkg : Vcpkg dir already exists" $install_color
            return
        }

        $global:Host.UI.RawUI.ForegroundColor = "white"
        Set-Location c:\
        git clone https://github.com/Microsoft/vcpkg

        Set-Location c:\vcpkg
        .\bootstrap-vcpkg.bat -disableMetrics 2>&1 | Out-Host
        .\vcpkg integrate install 2>&1 | Out-Host

        Foreach($package in $global:Config.Packages.VcpkgPackages){
            Try{
                .\vcpkg install $package 2>&1 | Out-Host
            } Catch{
                Write-Host $_
            } 
        }

        Exit-Command "[*] Install-Vcpkg : Completed" $install_color

    } Catch{
        Write-Host $_
        Exit-Command "[*] Install-Vcpkg : Error, aborting" $install_color
    } 
}

Function Start-Tron{
    [OutputType([void])]
    Param()
    
    Show-Command "[*] Start-Tron : Starting" $install_color

    Try{
        Write-Host "[*] Start-Tron : Downloading script"
        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        Set-Location $DesktopPath
        Invoke-WebRequest -Uri "https://bmrf.org/repos/tron/Tron%20v11.2.1%20(2021-06-02).exe" -OutFile "${DesktopPath}\tron.exe"
        
        Write-Host "[*] Start-Tron : Unzipping script"
        # sanitize and unzip 
        Remove-Item "${DesktopPath}\tron" -Recurse -Force -Confirm:$false
        Remove-Item "${DesktopPath}\integrity_verification" -Recurse -Force -Confirm:$false
        .\tron.exe 2>&1 | Out-Host


        Write-Host "[*] Start-Tron : Running tron script in verbose and self destruct"
        Set-Location "${DesktopPath}\tron"
        wt --window 0 -p "Windows Powershell" -d . powershell -noExit "./tron.bat -a -v -x"

        Set-Location "${PSScriptRoot}\..\"
        
        Exit-Command "[*] Start-Tron : Installed" $install_color
        
    } Catch{
        Write-Host $_
        Exit-Command "[*] Start-Tron : Error, aborting" $install_color
    } 
}
