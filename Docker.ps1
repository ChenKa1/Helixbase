# --------------------------------------------------------------------
# Run Docker
# --------------------------------------------------------------------


# --------------------------------------------------------------------
# Setup
# --------------------------------------------------------------------
# Import Powershell Functions
Get-ChildItem "$PSScriptRoot\Tools\Functions" -Filter *.ps1 | Foreach-Object {
    . $_.FullName
}

# Set Environment Variables
Set-LocalEnvironmentVariables
Set-CustomLocalEnvironmentVariables

# --------------------------------------------------------------------
# Tasks
# --------------------------------------------------------------------

# Run Prerequisites
Invoke-DockerPrerequisites

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

        $newHostEntryValues = Get-NewHostEntryValues
        Set-HostEntries -Entries $newHostEntryValues

        # Warm Up CM AND CD
        $cmUrl = Get-CM_URL -IncludeProtocol
        $cdUrl = Get-CM_URL -IncludeProtocol
        Invoke-WarmUp_Sites `
            -CmUrl $cmUrl `
            -CdUrl $cdUrl
    }
    1 { 
        # Docker Compose
        Invoke-DockerUp_Process_Isolation 
        
        # Set Host File Entries
        $newHostEntryValues = Get-NewHostEntryValues
        Set-HostEntries -Entries $newHostEntryValues
        
        # Warm Up CM AND CD
        $cmUrl = Get-CM_URL -IncludeProtocol
        $cdUrl = Get-CM_URL -IncludeProtocol
        Invoke-WarmUp_Sites `
            -CmUrl $cmUrl `
            -CdUrl $cdUrl
    }
    2 { 
        Reset-IIS-Servers @("cm","cd")
    }
    3 {
        Invoke-DockerDown
    }
    
 }
