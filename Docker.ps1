# --------------------------------------------------------------------
# Run Docker - Helixbase
# --------------------------------------------------------------------

# --------------------------------------------------------------------
# Setup
# --------------------------------------------------------------------
$ErrorActionPreference = "STOP"
$ProgressPreference = "SilentlyContinue"

# Import Powershell Functions
Get-ChildItem "$PSScriptRoot\Tools\Functions" -Filter *.ps1 | Foreach-Object {
    . $_.FullName
}

# Set Environment Variables
Set-LocalEnvironmentVariables
Set-CustomLocalEnvironmentVariables

# --------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------
Function Invoke-WarmUpSites {
    $newHostEntryValues = Get-NewHostEntryValues
    if($newHostEntryValues.Count -eq 0) {
        Write-Error "Docker Compose failed. Please check your setup."
        Exit
    }
    Set-HostEntries -Entries $newHostEntryValues

    # Warm Up CM AND CD
    $cmUrl = Get-CM_URL -IncludeProtocol
    $cdUrl = Get-CD_URL -IncludeProtocol
    Invoke-WarmUp_Sites `
        -CmUrl $cmUrl `
        -CdUrl $cdUrl
}

# --------------------------------------------------------------------
# Tasks
# --------------------------------------------------------------------

# Run Prerequisites
Invoke-DockerPrerequisites -RootPath $PSScriptRoot -DomainSuffix $env:DOMAIN_SUFFIX

$options = $host.ui.PromptForChoice("What would you like to do?", "Select an option", @(
    New-Object System.Management.Automation.Host.ChoiceDescription "Run Docker &Hyper-V isolation", "docker-hyperv"
    New-Object System.Management.Automation.Host.ChoiceDescription "Run Docker &Process isolation", "dokcer-process"
    New-Object System.Management.Automation.Host.ChoiceDescription "IIS &Reset", "iisreset"
    New-Object System.Management.Automation.Host.ChoiceDescription "&Docker Down", "prerequisites"
), 0)

switch($options){
    0 { 
        # Docker Compose
        Invoke-DockerUp_HyperV_Isolation 

        #Warm Up Sites
        Invoke-WarmUpSites
    }
    1 { 
        # Docker Compose
        Invoke-DockerUp_Process_Isolation 
        
        #Warm Up Sites
        Invoke-WarmUpSites
    }
    2 { 
        Reset-IIS-Servers @("cm","cd")
    }
    3 {
        Invoke-DockerDown
    }
    
 }
