function Set-LocalEnvironmentVariables {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param($localEnvFile = ".\.env")

    #return if no env file
    if (!( Test-Path $localEnvFile)) {
        Throw "could not open $localEnvFile"
    }

    #read the local env file
    $content = Get-Content $localEnvFile -ErrorAction Stop
    Write-Verbose "Parsed .env file"

    #load the content to environment
    foreach ($line in $content) {
        if ($line.StartsWith("#")) { continue };
        if ($line.Trim()) {
            $line = $line.Replace("`"","")
            $kvp = $line -split "=",2
            if ($PSCmdlet.ShouldProcess("$($kvp[0])", "set value $($kvp[1])")) {
                [Environment]::SetEnvironmentVariable($kvp[0].Trim(), $kvp[1].Trim(), "Process") | Out-Null
            }
        }
    }
}

Function Set-CustomLocalEnvironmentVariables {
    $env:REMOTE_DEBUGGER_PATH = Get-RemoteDebuggerPath
}

Function Get-RemoteDebuggerPath
{
	return (Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio" -Filter "Remote Debugger" -Recurse `
            | Where-Object { [regex]::Match($_.FullName, "\d{4}").Value -ge 2019 -and $_.FullName -notmatch "Community" } `
            | Select-Object -First 1).FullName
}