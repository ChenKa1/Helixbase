# param(
# 	[Parameter(Mandatory = $true)][string] $CmUrl,
# 	[Parameter(Mandatory = $true)][string] $CdUrl
# )

Function Invoke-WarmUp_Sites {
    param(
        [Parameter(Mandatory = $true)][string] $CmUrl,
        [Parameter(Mandatory = $true)][string] $CdUrl
    )

    Invoke-PingUrl "$CmUrl/sitecore"
    Invoke-PingUrl $CdUrl
    # Start-Process "$CmUrl/sitecore"
    # Start-Process $CdUrl
}

Function Invoke-PingUrl {
    param(
        [Parameter(Mandatory = $true)][string] $Url
    )
	Write-Host "Warming up $Url"
	
	Do {		
		$response = try { 
			(Invoke-WebRequest -Uri $Url -TimeoutSec 5 -ErrorAction Stop).BaseResponse
		} catch [System.Net.WebException] { 
			Write-Verbose "An exception was caught: $($_.Exception.Message)"
			$_.Exception.Response 
		} 

		$statusCode = [int]$response.BaseResponse.StatusCode

		Write-Host "Ok: $statusCode"
		if($statusCode -ne 200) {
			Start-Sleep -s 5
		}

	} While ($statusCode -ne 200)
}

#Invoke-WarmUp_Sites -CmUrl $CmUrl -CdUrl $CdUrl