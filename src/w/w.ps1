<#

.Synopsis 
Multi-tool powershell module command launcher 

.Description
stuff

.Example
Start-W -c Update-System

.Notes
Version : 1.0
Author : Michael Rinderle

Import-Module ./w.psm1 -DisableNameChecking
#>

. "$PSScriptRoot\modules\app.ps1"

$global:configPath = "${PSScriptRoot}\config.json"

Function Start-W{
    [OutputType([void])]
    param (
        [Parameter(Mandatory=$false)]
        [ArgumentCompleter(
            {
                Param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                Get-Functions | Where-Object { $_ -like "${wordToComplete}" } 
            }
        )]
        [string] $c
    )
    
    Try{
        # check admin, restart if possible
        $isAdmin = Test-Admin
        if($isAdmin -eq $false) { Return }

        # get configuration file
        $success = Get-Config
        If($success -eq $false) { Return }

        # start application 
        $app = [App]::new($c)
        $Host.UI.RawUI.ForegroundColor = "White"

    } Catch {
        # something happened. 
        Write-Host $_
    } 
}

Function Test-Admin{
    [OutputType([bool])]
    Param()

    if (!([Security.Principal.WindowsPrincipal] `
          [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
          [Security.Principal.WindowsBuiltInRole] "Administrator")) 
          { 
            # check for shiny new powershell 7
            $ps7 = Test-Path -Path "C:\Program Files\PowerShell\7\pwsh.exe" 
            If($true -eq $ps7){
                Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
            }
            # everything else
            Else{
                Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
            }
            Exit 
    }

    Return $true
}

Function Get-Config{
    [OutputType([bool])]
    Param()
    Try{
        # get configuration file
        $global:Config = Get-Content "$configPath" `
        -Raw `
        -ErrorAction:SilentlyContinue `
        -WarningAction:SilentlyContinue | ConvertFrom-Json `
        -ErrorAction:SilentlyContinue `
        -WarningAction:SilentlyContinue

        # check if config is null
        If($null -eq $global:Config){
            Write-Host $_
            return $false
        }
        else{
            return $true
        }
    } Catch{
        Write-Host $_    
    }  

    return $false
}

Function Get-Functions{
    [OutputType([array])]
    Param()

    Try{
        If($null -eq $global:Config){
            $global:Config = Get-Content "$configPath" `
            -Raw `
            -ErrorAction:SilentlyContinue `
            -WarningAction:SilentlyContinue | ConvertFrom-Json `
            -ErrorAction:SilentlyContinue `
            -WarningAction:SilentlyContinue
        }
    
        [array]$masterFuncList = @()
        Foreach($domain in $global:Config.Domains){
            If([string]$domain.equals("Exit")){ continue }
    
            $functionList = Select-String -Path "${PSScriptRoot}\modules\${domain}.ps1" -Pattern "function"
            [array]$domainFuncts  = @()
            Foreach($funcDef in $functionList){
                # Get index into string where function definition is and skip the space
                $funcIndex = ([string]$funcDef).LastIndexOf(" ") + 1
                # Get the function name from the end of the string
                $functionExport = ([string]$funcDef).Substring($funcIndex).Replace("{", "")
                $domainFuncts += $functionExport
            }
    
            $masterFuncList += $domainFuncts
        }
    
        Return $masterFuncList | Sort-Object -CaseSensitive

    } Catch{
        Write-Host $_
    } 

    Return $null
}

Set-Alias -Name w -Value Start-W

If (!(Get-Module "w")) { Start-W }


