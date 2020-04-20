Function Invoke-DockerPrerequisites {
    param(
        [Parameter(Mandatory = $true)][string] $ProjectName
    )
    $rootPath = "$(Get-Item ../)\Application\data"
    $applicationFolderPath = "$(Get-Item ../)\Application"
    
    Write-Host "Creating required directories"
    New-Item -ItemType directory -Force -Path "$rootPath\cd"
    New-Item -ItemType directory -Force -Path "$rootPath\cm"
    New-Item -ItemType directory -Force -Path "$rootPath\solr"
    New-Item -ItemType directory -Force -Path "$rootPath\sql"
    New-Item -ItemType directory -Force -Path "$rootPath\xconnect"
    New-Item -ItemType directory -Force -Path "$rootPath\xconnect-automationengine"
    New-Item -ItemType directory -Force -Path "$rootPath\xconnect-indexworker"
    New-Item -ItemType directory -Force -Path "$rootPath\xconnect-processingengine"
    New-Item -ItemType directory -Force -Path "$applicationFolderPath\Websites\$ProjectName.sc"
    
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
    
    Write-Host "You can start your development environment by running 'docker-compose up' in the '$((Get-Item ../).FullName)' folder"
    Write-Host "The CM is listening on port 44001, and the CD is listening on port 44002"
}
