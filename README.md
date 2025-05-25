# Eco Server Restarter Script
This is a PowerShell script will restart **Eco Server** at the specifed hours. It is designed to work on **Windows** hosts.

# Important notes

Regular users **DO NOT NEED** to edit the `.ps1 script file` directly. Eco token and restart times can be defined in `NidEcoRestarter.json`. This ensures that when script is updated none of your settings are lost.

Script **MUST** be placed to **where EcoServer.exe file** resides.

It can run without admin priviledges on the host system.

It operates at **24 hour** format so `9:00PM` should be defined as `21:00` and so on.

**If EcoServer crashes** for whatever reason it will also be automatically restarted. This check is made **every 10 seconds**.

Please **<ins>DO NOT</ins> define exact midnight** `00:00` as restart hour as at this time script resets its flags. If you want restart at midnight use `00:01` for example.

# File logger
**File logger** will be placed in the same directory as the script, its name can be changed in the `Configuration` section of the script. It saves the time of the events within the script.

# How to use the script
1. **Download** the script from the **releases** section.

2. **Unpack** files to where `EcoServer.exe` file sits. 

3. Generate **Eco User Token** on **https://play.eco/account** in **Server Authentication** section.

4. **Edit** file `NidEcoRestarter.json` and:

    * Paste your token from step 3 into `"YOUR_ECO_TOKEN_HERE"` section. Make sure _you preserve quotations_ around it.
    * Edit Restart Times in `RestartTimes` section.

5. Right click on both `NidEcoRestarterLauncher.cmd` and `NidEcoServerRestarter.ps1` and select `Unblock` then `Apply`. Files downloaded from internet are by default blocked on some systems.

6. **Run** `NidEcoRestarterLauncher.cmd` to run the script - it will run on accounts _without administrative priviledges_. It also ensures that script can be executed even on hosting systems with restrictive group policy. Do not run .ps1 script file directly.

# Future updates

* Ensure the server saves before closing. To get this functionality now, use RCON command `manage save` bofore server exit.
