# --------------------------------------------------------------------
# Run Docker
# --------------------------------------------------------------------


# Import Powershell Modules
  Get-ChildItem "$PSScriptRoot\Tools\Modules" -Filter *.psm1 | Foreach-Object {
    Import-Module $_.FullName -Force
}

$options = $host.ui.PromptForChoice("What would you like to do?", "Select an option", @(
    New-Object System.Management.Automation.Host.ChoiceDescription "Run Docker &Hyper-V isolation", "docker-hyperv"
    New-Object System.Management.Automation.Host.ChoiceDescription "Run Docker &Process isolation", "dokcer-process"
    New-Object System.Management.Automation.Host.ChoiceDescription "&IIS Reset", "iisreset"
    New-Object System.Management.Automation.Host.ChoiceDescription "&Install Prerequisites", "prerequisites"
    New-Object System.Management.Automation.Host.ChoiceDescription "&Docker Down", "prerequisites"
), 0)

switch($options){
    0 { 
        Invoke-DockerUp_HyperVIsolation 
    }
    1 { 
        Invoke-DockerUp_ProcessIsolation 
    }
    2 { 
        Reset-IIS -ServerPrefix "Helixbase" -Servers @("cm","cd")
    }
    3 {
        Invoke-DockerPrerequisites -ProjectName "Helixbase"
    }
    4 {
        Invoke-DockerDown
    }
 }