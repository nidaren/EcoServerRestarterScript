# ------------------------ INIT ------------------------
$host.UI.RawUI.WindowTitle = "Nid Eco Server Restarter"

# ------------------------ CONFIGURATION ------------------------
# Set restart times in 24-hour format (HH:mm), following the below example - multiple restart times may be added.
$restartTimes = @(
    "01:00",
    "13:00"
)

#EcoServer.exe
$ecoServerPath = "EcoServer.exe"
#EcoServer.exe arguments
$ecoServerArgs = "--userToken=YOUR_ECO_TOKEN_HERE"   # <-- set your user token here

# Name of the process without extension
$processName = "EcoServer"

# LogFile
$logFile = "EcoServerRestartLog.log"

# ------------------------ STARTUP CHECK ------------------------
Write-Host "Nid Eco Server Restarter is starting up..."
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue
if (-not $process) {
    Write-Host "EcoServer is not running. Starting it now..."
    try {
        Start-Process -FilePath $ecoServerPath -ArgumentList $ecoServerArgs
        Write-Host "EcoServer started successfully."
        $message = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] - Started EcoServer.exe at script startup"
        Add-Content -Path $logFile -Value $message
    }
    catch {
        Write-Host "Failed to start EcoServer: $_" -ForegroundColor Red
        $errorMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] - ERROR starting EcoServer at startup: $_"
        Add-Content -Path $logFile -Value $errorMsg
    }
}
else {
    Write-Host "EcoServer is already running."
}

Write-Host "Watching for restarts at: $($restartTimes -join ', ')"
Write-Host "---------------------------------------------------"

$alreadyRestarted = @{}
$lastCheckEcoServer = (Get-Date).AddSeconds(-10)

# ------------------------ MAIN LOOP ------------------------
while ($true) {
    $now = Get-Date
    $currentTime = $now.ToString("HH:mm")

    # Check EcoServer running status every 10 seconds
    if (($now - $lastCheckEcoServer).TotalSeconds -ge 10) {
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if (-not $process) {
            Write-Host "EcoServer is NOT running. Starting process..."
            try {
                Start-Process -FilePath $ecoServerPath -ArgumentList $ecoServerArgs
                Write-Host "EcoServer started successfully."
                $message = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] - Started EcoServer.exe (not running)"
                Add-Content -Path $logFile -Value $message
            }
            catch {
                Write-Host "Failed to start EcoServer: $_" -ForegroundColor Red
                $errorMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] - ERROR starting EcoServer: $_"
                Add-Content -Path $logFile -Value $errorMsg
            }
        }
        $lastCheckEcoServer = $now
    }

    # Check if it's time to restart
    foreach ($restartTime in $restartTimes) {
        if ($currentTime -eq $restartTime -and !$alreadyRestarted.ContainsKey($restartTime)) {
            try {
                Write-Host "`n[$($now.ToString("yyyy-MM-dd HH:mm:ss"))] Restart time matched: $restartTime"
                Write-Host "Force killing EcoServer.exe..."

                $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

                if ($process) {
                    $process.Kill()
                    Write-Host "EcoServer process killed."
                }
                else {
                    Write-Host "EcoServer process not found."
                }

                Start-Sleep -Seconds 5

                Write-Host "Starting EcoServer..."
                Start-Process -FilePath $ecoServerPath -ArgumentList $ecoServerArgs
                Write-Host "EcoServer restarted successfully."

                $message = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] - Restarted EcoServer.exe at $restartTime"
                Add-Content -Path $logFile -Value $message

                $alreadyRestarted[$restartTime] = $true
            }
            catch {
                $errorMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] - ERROR: $_"
                Add-Content -Path $logFile -Value $errorMsg
                Write-Host $errorMsg -ForegroundColor Red
            }
        }

        # Reset restart flags at midnight
        if ($currentTime -eq "00:00") {
            $alreadyRestarted.Clear()
            Write-Host "`n[Midnight] Restart flags reset."
        }
    }

    Start-Sleep -Seconds 1
}
