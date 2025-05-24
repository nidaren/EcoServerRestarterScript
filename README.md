# Eco Server Restarter Script
This is a PowerShell script will restart **Eco Server** at the specifed hours. It is designed to work on **Windows** hosts.

# Important notes

Script **MUST** be placed to **where EcoServer.exe file** resides.

It operates at **24 hour** format so `9:00PM` should be defined as `21:00` and so on.

**If EcoServer crashes** for whatever reason it will also be automatically restarted. This check is made **every 10 seconds**.

Please **<ins>DO NOT</ins> define exact midnight** `00:00` as restart hour as at this time script resets its flags. If you want restart at midnight use `00:01` for example.

# How to use the script
1. **Download** the script from the **releases** section.

2. **Unpack** script where `EcoServer.exe` file sits. 

3. If you are **NOT on Windows Server** operating system - **Allow execution** of **locally saved `PowerShell` scripts**. To do so `Open PowerShell` in `Windows Terminal` and execute the command:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

4. Generate **Eco User Token** on **https://play.eco/account** in **Server Authentication** section.

5. **Edit** the script _(**[VisualStudioCode](https://code.visualstudio.com//)** recommended)_ and **update** the line `"--userToken=YOUR_ECO_TOKEN_HERE"` with your token from the webpage. Make sure you preserve `--userToken=` and not replace it whole.

6. Declare restart times in `restartTimes` variable.
```powershell
$restartTimes = @(
    "01:00",
    "13:00"
)
```

7. **Run** the script. If Eco Server is not runnig, it will start it automatically.

# Future updates

* Ensure the server saves before closing. To get this functionality now, use RCON command `/manage save` bofore server exit.
