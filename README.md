# Eco Server Restarter Script
This is a PowerShell script will restart **Eco Server** at the specifed hours. It is designed to work on **Windows** hosts.

# Important notes

Script **MUST** be placed to **where EcoServer.exe file** resides.

Script can run on account **WITH** or **WITHOUT** administrative priviledges. In case of lack of admin rights, skip step 3 of How-To-Use section.

It operates at **24 hour** format so `9:00PM` should be defined as `21:00` and so on.

**If EcoServer crashes** for whatever reason it will also be automatically restarted. This check is made **every 10 seconds**.

Please **<ins>DO NOT</ins> define exact midnight** `00:00` as restart hour as at this time script resets its flags. If you want restart at midnight use `00:01` for example.

# File logger
**File logger** will be placed in the same directory as the script, its name can be changed in the `Configuration` section of the script. It saves the time of the events within the script.

# How to use the script
1. **Download** the script from the **releases** section.

2. **Unpack** files to where `EcoServer.exe` file sits. 

3. If you are **NOT on Windows Server** and you have **administrative priviledges** on operating system - **Allow execution** of **locally saved `PowerShell` scripts**. To do so `Open PowerShell` in `Windows Terminal` and execute the command:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

4. If you **DO NOT** have an account with **administrative priviledges** on the host system, skip step 3.

5. Generate **Eco User Token** on **https://play.eco/account** in **Server Authentication** section.

6. **Edit** the script _(**[VisualStudioCode](https://code.visualstudio.com//)** recommended)_ and **update** the line `"--userToken=YOUR_ECO_TOKEN_HERE"` with your token from the webpage. Make sure you preserve `--userToken=` and not replace it whole.

7. Declare restart times in `restartTimes` variable.
```powershell
$restartTimes = @(
    "01:00",
    "13:00"
)
```

8. Right click on both `NidEcoRestarterLauncher.cmd` and `NidEcoServerRestarter.ps1` and select `Unblock` then `Apply`. Files downloaded from internet are by default blocked on some systems.

9. **Run** `NidEcoRestarterLauncher.cmd` to run the script - it will run on accounts _without administrative priviledges_. It also ensures that script can be executed even on hosting systems with restrictive group policy. If you have full control over your host system you can also run script directly.

# Future updates

* Ensure the server saves before closing. To get this functionality now, use RCON command `manage save` bofore server exit.
