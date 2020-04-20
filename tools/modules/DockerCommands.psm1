# --------------------------------------------------------------------
# Execute Docker Up
# --------------------------------------------------------------------

Function Invoke-DockerUp_HyperVIsolation {
    Write-Host "Starting docker in HyperV Isolation"
    Set-LocalEnvironmentVariables
    docker-compose -f .\docker-compose.yml -f .\docker-compose-process-isolation.yml up --detach
}

Function Invoke-DockerUp_ProcessIsolation {
    Write-Host "Starting docker in Process Isolation"
    Set-LocalEnvironmentVariables
	docker-compose -f .\docker-compose.yml up --detach
}

Function Invoke-DockerDown {
    Write-Host "Downing Docker"
    docker-compose down --remove-orphans
}

Function Reset-IIS {
    param(
        [Parameter(Mandatory = $true)][string] $ServerPrefix,
        [Parameter(Mandatory = $false)][string[]] $Servers = @("cm","cd")
    )
    $Servers | ForEach-Object {
        $containerName = "$($ServerPrefix)_$($_)_1"
        $isContainerRunning = docker inspect -f '{{.State.Running}}' $containerName
        # If container 
        if($isContainerRunning -eq $false) {
            Write-Host "Starting container: $containerName" -ForegroundColor Yellow
            docker start $containerName
        }
        Write-Host "Resetting IIS for $containerName" -ForegroundColor Yellow
        docker exec $(docker inspect $containerName --format='{{.Id}}') powershell "iisreset /restart"
    }
}

Function Get-RemoteDebuggerPath
{
	return (Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio" -Filter "Remote Debugger" -Recurse `
            | Where-Object { [regex]::Match($_.FullName, "\d{4}").Value -ge 2019 -and $_.FullName -notmatch "Community" } `
            | Select-Object -First 1).FullName
}

Function Set-LocalEnvironmentVariables {
    $env:REMOTE_DEBUGGER_PATH = Get-RemoteDebuggerPath
}