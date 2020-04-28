Function Invoke-WarmUp_Sites {
    param(
        [Parameter(Mandatory = $true)][string] $CmUrl,
        [Parameter(Mandatory = $true)][string] $CdUrl
    )

    Invoke-PingUrl "$CmUrl/sitecore"
    Invoke-PingUrl $CdUrl
    Start-Process "$CmUrl/sitecore"
    Start-Process $CdUrl
}

Function Invoke-PingUrl {
    param(
        [Parameter(Mandatory = $true)][string] $Url
    )

    Write-Host "$(Get-Date -Format HH:mm:ss): Warming up $($Url)" -ForegroundColor Green
	$responsePassed = $false;
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
		
		if ($res.StatusCode -eq 200) 
		{
			$responsePassed = $true
		} 
		elseif ($res.StatusCode -eq 302) 
		{
			# If redirected to the nolayout.aspx page (This could happen on a first time build).
			if($Results.Headers.Location.StartsWith("/sitecore/service/nolayout.aspx")) {
				$responsePassed = $true
			}
		} 

		if(-not($null -eq $res))
		{
			Write-Host "`t$($res.StatusCode) from $($Url) in $($secs)s" -ForegroundColor Yellow
		}
	} While ($responseOK -eq $false)
}

