Function Invoke-WarmUp_Sites {
    param(
        [Parameter(Mandatory = $true)][string] $CmUrl,
        [Parameter(Mandatory = $true)][string] $CdUrl
    )

    Invoke-PingUrl $CmUrl
    Invoke-PingUrl $CdUrl
    Start-Process "$CmUrl/sitecore"
    Start-Process $CdUrl
}

Function Invoke-PingUrl {
    param(
        [Parameter(Mandatory = $true)][string] $Url
    )

    Write-Host "$(Get-Date -Format HH:mm:ss): Warming up $($Url)" -ForegroundColor Green
	
	Do {
		$time = Measure-Command {
			try {
				$res = Invoke-WebRequest $Url -UseBasicParsing -TimeoutSec 15 -ErrorAction SilentlyContinue
			}
			catch {
				Write-Host "`t$($_.Exception.Message)" -ForegroundColor Magenta
			}
		}
	
		$secs = $time.TotalSeconds
		
		if(-not($null -eq $res))
		{
			Write-Host "`t$($res.StatusCode) from $($Url) in $($secs)s" -ForegroundColor Yellow
		}
	} While ($res.StatusCode -ne 200)
}

