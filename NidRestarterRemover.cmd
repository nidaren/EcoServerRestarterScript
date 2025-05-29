@echo off
setlocal

echo NidEcoRestarter Remover
echo -----------------------
echo.

set FILES=NidEcoRestarter.json NidEcoRestarterLauncher.cmd NidEcoServerRestarter.ps1 NidEcoServerRestartLog.log License.txt
set EXE_PATH=NidEcoServerRestarter\wk.exe
set FOLDER=NidEcoServerRestarter

for %%F in (%FILES%) do (
    if exist "%%F" (
        attrib -r "%%F"
        del "%%F"
        echo Deleted %%F
    ) else (
        echo File %%F not found - no need to delete.
    )
)

if exist "%EXE_PATH%" (
    attrib -r "%EXE_PATH%"
    del "%EXE_PATH%"
    echo Deleted %EXE_PATH%
) else (
    echo File %EXE_PATH% not found - no need to delete.
)

if not exist "%FOLDER%" (
    echo Folder %FOLDER% not found - no need to delete.
) else (
    attrib -r -s -h "%FOLDER%" /D /S
    rd /s /q "%FOLDER%"
    if not exist "%FOLDER%" (
        echo Folder %FOLDER% deleted
    ) else (
        echo Failed to delete folder %FOLDER% (may still be in use)
    )
)
echo.
echo Done.
pause