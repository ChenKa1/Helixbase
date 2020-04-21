Function Invoke-DockerPrerequisites {
    $rootPath = "$(Get-Item ../)\Application\data"
    $applicationFolderPath = "$(Get-Item ../)\Application"
    $domainSuffix = $env:DOMAIN_SUFFIX 

    New-Item -ItemType directory -Force -Path "$rootPath\cd" | Out-Null
    New-Item -ItemType directory -Force -Path "$rootPath\cm" | Out-Null
    New-Item -ItemType directory -Force -Path "$rootPath\solr" | Out-Null
    New-Item -ItemType directory -Force -Path "$rootPath\sql" | Out-Null
    New-Item -ItemType directory -Force -Path "$rootPath\xconnect" | Out-Null
    New-Item -ItemType directory -Force -Path "$rootPath\xconnect-automationengine" | Out-Null
    New-Item -ItemType directory -Force -Path "$rootPath\xconnect-indexworker" | Out-Null
    New-Item -ItemType directory -Force -Path "$rootPath\xconnect-processingengine" | Out-Null
    New-Item -ItemType directory -Force -Path "$ \Websites\$domainSuffix" | Out-Null
    
    $requiredWindowsVersion = (new-object 'Version' 10,0,17763,0)
    $currentWindowsVersion = [Environment]::OSVersion.Version;
    if($currentWindowsVersion.Major -ne $requiredWindowsVersion.Major -or $currentWindowsVersion.Build -lt $requiredWindowsVersion.Build)
    {
        Write-Error "The current windows version is ($currentWindowsVersion) lower then the required version ($requiredWindowsVersion)"
        exit
    }
    
    if ((Get-Command "docker" -errorAction SilentlyContinue) -eq $null)
    {
        Write-Error "Docker is not installed, please install docker"
        exit
    }
    Write-Host "`n-------------------------------------------------" -ForegroundColor Green
    Write-Host " Docker Prerequisites Complete                     " -ForegroundColor Green
    Write-Host "-------------------------------------------------" -ForegroundColor Green
}