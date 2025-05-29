# ------------------------ CONFIGURATION ------------------------
$flagsResetTime = "00:00"
$ecoServerPath = "EcoServer.exe"
$processName = "EcoServer"
$logFile = "NidEcoServerRestartLog.log"
$configFilePath = "NidEcoRestarter.json"

# ------------------------ TIMESTAMP FUNCTION ------------------------
function Get-Timestamp {
    return "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]"
}

# ------------------------ LOAD CONFIG FILE ------------------------
if (Test-Path $configFilePath) {
    try {
        $config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json

        # Assign values with fallbacks if null or empty
        $ecoUserToken = if ($config.EcoUserToken -and $config.EcoUserToken.Trim()) { 
            $config.EcoUserToken.Trim() 
        } else { 
            "default-user-token" 
        }

        $restartTimes = if ($config.RestartTimes) { 
            $config.RestartTimes 
        } else { 
            @("01:00", "13:00")  # Default restart times as array
        }

        $windowTitle = if ($config.WindowTitle) { 
            $config.WindowTitle 
        } else { 
            "Nid Eco Server Restarter" 
        }                

        $saveWaitTime = if ($config.SaveWaitTime) { 
            $config.SaveWaitTime 
        } else {             
            120
        }

        if (-not $config.SaveWaitTime) {
            Write-Host "$(Get-Timestamp) ERROR: Failed to load SaveWaitTime value from your config file." -ForegroundColor Yellow
            Write-Host "$(Get-Timestamp) Download updated config .json from GitHub project page. Or Add this value manually." -ForegroundColor Yellow
            Write-Host "$(Get-Timestamp) Default value of 120 seconds will be used." -ForegroundColor Yellow
        }

        $ecoServerArgs = "--userToken=$ecoUserToken"
    }
    catch {
        Write-Host "$(Get-Timestamp) ERROR: Failed to parse config file. $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "$(Get-Timestamp) ERROR: Config file '$configFilePath' not found." -ForegroundColor Red
    exit 1
}

# ------------------------ INIT ------------------------
$host.UI.RawUI.WindowTitle = $windowTitle

# Resolve script folder to get wk.exe path
$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$wkExePath = Join-Path $scriptFolder "NidEcoServerRestarter\wk.exe"
# Check if wk.exe exists
if (-not (Test-Path $wkExePath)) {
    $errorMsg = "$(Get-Timestamp) ERROR: wk.exe not found at '$wkExePath'. Exiting..."
    Write-Host $errorMsg -ForegroundColor Red
    Add-Content -Path $logFile -Value $errorMsg
    exit 1
}

# ------------------------ STARTUP CHECK ------------------------
Write-Host "$(Get-Timestamp) Nid Eco Server Restarter is starting up..."
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue
if (-not $process) {
    Write-Host "$(Get-Timestamp) EcoServer is not running. Starting it now..."
    try {
        Start-Process -FilePath $ecoServerPath -ArgumentList $ecoServerArgs
        Write-Host "$(Get-Timestamp) EcoServer started successfully."
        $message = "$(Get-Timestamp) - Started EcoServer.exe at script startup"
        Add-Content -Path $logFile -Value $message
    }
    catch {
        Write-Host "$(Get-Timestamp) Failed to start EcoServer: $_" -ForegroundColor Red
        $errorMsg = "$(Get-Timestamp) - ERROR starting EcoServer at startup: $_"
        Add-Content -Path $logFile -Value $errorMsg
    }
}
else {
    Write-Host "$(Get-Timestamp) EcoServer is already running."
}

Write-Host "$(Get-Timestamp) Watching for restarts at: $($restartTimes -join ', ')"
Write-Host "-----------------------------------------------------------------"

$alreadyRestarted = @{}
$hasResetFlags = $false
$lastCheckEcoServer = (Get-Date).AddSeconds(-10)

# ------------------------ MAIN LOOP ------------------------
while ($true) {
    $now = Get-Date
    $currentTime = $now.ToString("HH:mm")

    # Check EcoServer running status every 10 seconds
    if (($now - $lastCheckEcoServer).TotalSeconds -ge 10) {
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if (-not $process) {
            Write-Host "$(Get-Timestamp) EcoServer is NOT running. Starting process..."
            try {
                Start-Process -FilePath $ecoServerPath -ArgumentList $ecoServerArgs
                Write-Host "$(Get-Timestamp) EcoServer started successfully."
                $message = "$(Get-Timestamp) - Started EcoServer.exe (not running)"
                Add-Content -Path $logFile -Value $message
            }
            catch {
                Write-Host "$(Get-Timestamp) Failed to start EcoServer: $_" -ForegroundColor Red
                $errorMsg = "$(Get-Timestamp) - ERROR starting EcoServer: $_"
                Add-Content -Path $logFile -Value $errorMsg
            }
        }
        $lastCheckEcoServer = $now
    }

    # Check if it's time to restart
    foreach ($restartTime in $restartTimes) {
        if ($currentTime -eq $restartTime -and !$alreadyRestarted.ContainsKey($restartTime)) {
            try {
                Write-Host "$(Get-Timestamp) Restart time matched: $restartTime"

                $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
                if ($process) {
                    $processId = $process.Id

                    try {
                        Write-Host "$(Get-Timestamp) Sending SIGINT to EcoServer process ID $processId using wk.exe..."
                        Start-Process -FilePath $wkExePath -ArgumentList "-SIGINT $processId" -WindowStyle Hidden -Wait
                        Write-Host "$(Get-Timestamp) SIGINT sent successfully. Waiting $saveWaitTime seconds..."
                        Start-Sleep -Seconds $saveWaitTime
                    }
                    catch {
                        Write-Host "$(Get-Timestamp) WARNING: Error sending SIGINT: $_" -ForegroundColor Yellow
                    }

                    # Check if process still exists and kill if necessary
                    $procCheck = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($procCheck) {
                        Write-Host "$(Get-Timestamp) Process ID $processId is still running. Killing now..."
                        try {
                            $procCheck.Kill()
                            Write-Host "$(Get-Timestamp) Process ID $processId killed successfully."
                        }
                        catch {
                            Write-Host ("$(Get-Timestamp) ERROR killing process ID {0}: {1}" -f $processId, $_) -ForegroundColor Red
                        }
                    }
                    else {
                        Write-Host "$(Get-Timestamp) Process ID $processId exited gracefully after SIGINT."
                    }
                }
                else {
                    Write-Host "$(Get-Timestamp) EcoServer process not found before restart."
                }

                Write-Host "$(Get-Timestamp) Starting EcoServer..."
                Start-Process -FilePath $ecoServerPath -ArgumentList $ecoServerArgs
                Write-Host "$(Get-Timestamp) EcoServer restarted successfully."

                $message = "$(Get-Timestamp) - Restarted EcoServer.exe at $restartTime"
                Add-Content -Path $logFile -Value $message

                $alreadyRestarted[$restartTime] = $true
            }
            catch {
                Write-Host ("$(Get-Timestamp) ERROR during restart: {0}" -f $_) -ForegroundColor Red
                $errorMsg = "$(Get-Timestamp) - ERROR: $_"
                Add-Content -Path $logFile -Value $errorMsg
            }
        }
    }

    # Reset restart flags once at flagsResetTime
    if ($currentTime -eq $flagsResetTime -and -not $hasResetFlags) {
        $alreadyRestarted.Clear()
        Write-Host "$(Get-Timestamp) Restart flags reset."
        $hasResetFlags = $true
    }
    elseif ($currentTime -ne $flagsResetTime -and $hasResetFlags) {
        $hasResetFlags = $false
    }

    Start-Sleep -Seconds 1
}