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
$PSDefaultParameterValues['New-Item:Verbose'] = $false

. "$PSScriptRoot\..\modules\install.ps1"
. "$PSScriptRoot\..\modules\common.ps1"
. "$PSScriptRoot\..\modules\registry.ps1"
. "$PSScriptRoot\..\modules\system.ps1"

class App {

    [string] $command

    App($command){
        $this.ParseCmdArguments($command)
    }

    [void] 
    ParseCmdArguments($command){
        $this.command = $command
        If([string]::IsNullOrEmpty($this.command)){
            $this.ShowMenu()
        }
        Else{
            $this.InvokeFunction($command)
        }
    }

    [void] 
    ShowMenu(){
        $global:Host.UI.RawUI.ForegroundColor = "darkgray"
        $domain_selection = $this.GetMenuUserInput("Domains", $global:Config.Domains)
        If([string]::IsNullOrEmpty($domain_selection)){
            $this.ShowMenu()
            Return
        }
        # top level exit menu
        If ($domain_selection -eq "exit") {
            Return
        }

        $domain_functions = $this.GetDomainFunction($domain_selection)
        $function = $this.GetMenuUserInput($domain_selection, $domain_functions)
        
        # sanity check, resetting main menu
        If([string]::IsNullOrEmpty($function)){
            $this.ShowMenu()
            Return
        }
        # second level exit 
        Elseif ($function -eq "exit") {
            Return
        }

        # invoke function, reset main menu
        $this.InvokeFunction($function)
        $this.ShowMenu()
    }

    [string] 
    GetMenuUserInput($domain, $methods){
        Clear-Host
        $current =  $global:Host.UI.RawUI.ForegroundColor
        $global:Host.UI.RawUI.ForegroundColor = "blue"

        Write-Host "[W][Menu][${domain}]"
        $global:Host.UI.RawUI.ForegroundColor = $current

        # adding exit option for main menu
        If($domain -eq "Domains"){
            $methods += "Exit"
        }

        # display domain methods 
        $counter = 1  
        Foreach($method in $methods){
            Write-Host "[${counter}] ${method}"
            $counter += 1
        }

        # get user input
        While(1){
            Write-Host "> " -NoNewLine
            $in = $global:Host.UI.ReadLine()
            If($in -match "^\d+$"){

                If($methods[$in-1] -eq "Exit"){
                    Clear-Host
                    Return "exit"
                }

                If(![string]::IsNullOrEmpty($in) -or
                $in -lt ($methods.length - 1)){
                  If($methods[$in-1] -eq "Back To Main Menu"){
                      Return $null
                  }
  
                  Return $methods[$in-1]
              }
            }

            Write-Host "Try again"
            Continue;
        }
        Return $null
    }

    [array] 
    GetDomainFunction($domain){
        $functionList = Select-String -Path "${PSScriptRoot}\${domain}.ps1" -Pattern "function"
        [array] $domainFuncts = @()
        Foreach($funcDef in $functionList){
            # Get index into string where function definition is and skip the space
            $funcIndex = ([string]$funcDef).LastIndexOf(" ") + 1
            # Get the function name from the end of the string
            $functionExport = ([string]$funcDef).Substring($funcIndex).Replace("{", "")
            $domainFuncts += $functionExport
        }

        $domainFuncts = $domainFuncts | Sort-Object -CaseSensitive
        $domainFuncts += "Back To Main Menu"
        $domainFuncts += "Exit"
        Return $domainFuncts
    }

    [void] 
    InvokeFunction($command){
        invoke-expression "${command}"
    }
}