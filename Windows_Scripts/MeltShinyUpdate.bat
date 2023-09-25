@echo off
setlocal

:: Define the URL of the latest ZIP archive
set ZIP_URL=https://github.com/oss-slu/MeltWin2.0/archive/refs/heads/main.zip

:: Determine the directory where the script is located (Windows_Scripts)
set SCRIPT_DIR=%~dp0

:: Define the directory where the program is installed
cd %SCRIPT_DIR%\..
set PROGRAM_DIR=%cd%
cd %SCRIPT_DIR%

:: Create a temporary directory
set TEMP_DIR=%TEMP%\UpdateTemp
mkdir "%TEMP_DIR%"
:: Download the latest ZIP archive
powershell -Command "& { Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%TEMP_DIR%\latest.zip' }"
:: Unzip the archive to a temporary location
powershell -Command "& { Expand-Archive -Path '%TEMP_DIR%\latest.zip' -DestinationPath '%TEMP_DIR%' -Force }"

:: Delete all existing files and directories inside MeltWin2.0, excluding Windows_Scripts and MacOS_Scripts
for /D %%A in ("%PROGRAM_DIR%\*") do (
    if /I not "%%~nxA"=="Windows_Scripts" if /I not "%%~nxA"=="MacOS_Scripts" (
        rd /s /q "%%~fA"
    )
)
:: Copy the contents of the unzipped folder to the program directory
xcopy /E /I /Y "%TEMP_DIR%\MeltWin2.0-main\*" "%PROGRAM_DIR%\"

:: Clean up the temporary directory
rd /s /q "%TEMP_DIR%"

echo Update complete! Your program is now up to date.
pause
