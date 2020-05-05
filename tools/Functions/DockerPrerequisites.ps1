Function Invoke-DockerPrerequisites {
    param (
        [Parameter(Mandatory = $true)][string] $RootPath,
        [Parameter(Mandatory = $true)][string] $DomainSuffix
    )

    $dataFolderPath = "$RootPath\_Application\data"
    $applicationFolderPath = "$RootPath\_Application"

    New-Item -ItemType directory -Force -Path "$dataFolderPath\cd" | Out-Null
    New-Item -ItemType directory -Force -Path "$dataFolderPath\cm" | Out-Null
    New-Item -ItemType directory -Force -Path "$dataFolderPath\solr" | Out-Null
    New-Item -ItemType directory -Force -Path "$dataFolderPath\sql" | Out-Null
    New-Item -ItemType directory -Force -Path "$dataFolderPath\xconnect" | Out-Null
    New-Item -ItemType directory -Force -Path "$dataFolderPath\xconnect-automationengine" | Out-Null
    New-Item -ItemType directory -Force -Path "$dataFolderPath\xconnect-indexworker" | Out-Null
    New-Item -ItemType directory -Force -Path "$dataFolderPath\xconnect-processingengine" | Out-Null
    New-Item -ItemType directory -Force -Path "$applicationFolderPath\Websites\$DomainSuffix" | Out-Null
    
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