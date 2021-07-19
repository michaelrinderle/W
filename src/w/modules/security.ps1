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

$global:system_color = "darkread"

Function Install-Tor{
    [OutputType([void])]
    Param()

    Show-Command "[*] Install-Tor : Started" $system_color

    Try{
        Update-Packages
        Exit-Command "[*] Install-Tor : Not implemented yet" $system_color

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Install-Tor : Error, aborted" $system_color
}

Function Lock-Hostfile{
    [OutputType([void])]
    Param()

    Show-Command "[*] Lock-Hostfile : Started" $system_color

    Try{
        Update-Packages
        Exit-Command "[*] Lock-Hostfile : Not implemented yet" $system_color

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Lock-Hostfile : Error, aborted" $system_color
}

Function Restore-Hostfile{
    [OutputType([void])]
    Param()

    Show-Command "[*] Restore-Hostfile : Started" $system_color

    Try{
        Update-Packages
        Exit-Command "[*] Restore-Hostfile : Not implemented yet" $system_color

    } Catch{
        Write-Host $_
    }

    Exit-Command "[*] Restore-Hostfile : Error, aborted" $system_color
}
