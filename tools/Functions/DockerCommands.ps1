# --------------------------------------------------------------------
# Execute Docker Up
# --------------------------------------------------------------------

Function Invoke-DockerUp_HyperV_Isolation {
    Write-Host "Starting docker in HyperV Isolation"
    docker-compose -f .\docker-compose.yml up --detach
}

Function Invoke-DockerUp_Process_Isolation {
    Write-Host "Starting docker in Process Isolation"
    docker-compose -f .\docker-compose.yml -f .\docker-compose-process-isolation.yml up --detach
}

Function Invoke-DockerDown {
    Write-Host "Downing Docker"
    docker-compose down --remove-orphans
}

Function Get-NewHostEntryValues {
    $entries = @{}
    $containerPrefix = $env:SOLUTION_NAME.ToLower()

    $cmContainerIp = Get-ContainerIpAddress -ContainerName "$($containerPrefix)_cm_1"
    $cdContainerIp = Get-ContainerIpAddress -ContainerName "$($containerPrefix)_cd_1"
    $solrContainerIp = Get-ContainerIpAddress -ContainerName "$($containerPrefix)_solr_1"

    if(-Not [string]::IsNullOrEmpty($cmContainerIp)) {
        $cmUrl = Get-CM_URL
        $entries.Add($cmUrl, $cmContainerIp)
    }
    if(-Not [string]::IsNullOrEmpty($cdContainerIp)) {
        $cdUrl = Get-CD_URL
        $entries.Add($cdUrl, $cdContainerIp)
    }
    if(-Not [string]::IsNullOrEmpty($solrContainerIp)) {
        $solrUrl = Get-SOLR_URL
        $entries.Add($solrUrl, $solrContainerIp)
    }
    return $entries
}

Function Get-ContainerIpAddress {
    param (
        [Parameter(Mandatory = $true)][string] $ContainerName
    )
    $ipAddress = $null
    $count = 0
    do {       
        $ipAddress = Invoke-Expression `
            -Command "docker container inspect --format ""{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"" $ContainerName" `
            -ErrorAction SilentlyContinue
        
        if(-Not [string]::IsNullOrEmpty($ipAddress)) {
            $success = $true
        }
      
        $count++
        
    } until ($count -eq 10 -or $success)

    return $ipAddress
}

Function Reset-IIS {
    param(
        [Parameter(Mandatory = $false)][string[]] $Servers = @("cm","cd")
    )

    $serverPrefix = $env:SOLUTION_NAME
    $Servers | ForEach-Object {
        $containerName = "$($serverPrefix)_$($_)_1"
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

Function Get-CM_URL {
    param(
        [Parameter(Mandatory = $false)][switch] $IncludeProtocol
    )
    $domainPrefix = if ($IncludeProtocol) { "http://" } else { "" }
    $domainSuffix = $env:DOMAIN_SUFFIX.ToLower()
    return "$($domainPrefix)cms.$domainSuffix"
}

Function Get-CD_URL {
    param(
        [Parameter(Mandatory = $false)][switch] $IncludeProtocol
    ) 
    $domainPrefix = if ($IncludeProtocol) { "http://" } else { "" }
    $domainSuffix = $env:DOMAIN_SUFFIX.ToLower()
    return "$($domainPrefix)$($domainSuffix)"
}

Function Get-SOLR_URL {
    param(
        [Parameter(Mandatory = $false)][switch] $IncludeProtocol
    )
    $domainPrefix = if ($IncludeProtocol) { "http://" } else { "" }
    $domainSuffix = $env:DOMAIN_SUFFIX.ToLower()
    return "$($domainPrefix)solr.$domainSuffix"
}

Function Invoke-RemoveImages {
    docker-compose down -v
    docker inspect --format='{{.Id}} {{.Parent}}' $(docker images --filter=reference="$env:REGISTRY/*" since=<image_id> -q)
    docker rmi {sub_image_id} 

    docker inspect --format='{{.Id}} {{.Parent}}' \ $(docker images --filter since=f50f9524513f --quiet)

    #docker rmi -f $(docker images --filter=reference="$env:REGISTRY/*" -q)
}

Function Invoke-RemoveLogsAndDatabses {
    param(
        [Parameter(Mandatory = $true)][string] $RootPath
    )
    Get-ChildItem -Path (Join-Path $RootPath "_Application") -Include * | Remove-Item -Recurse 
}

Function Invoke-ResetAll {
    param(
        [Parameter(Mandatory = $true)][string] $RootPath
    )
    Write-host "Are you sure you want to contiue? All images, logs and databases will be removed." -ForegroundColor Yellow 
    $Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
     { 
       Y {
        Invoke-RemoveImages
        Invoke-RemoveLogsAndDatabses -RootPath $RootPath
       } 
       N {} 
       Default {} 
     } 
}