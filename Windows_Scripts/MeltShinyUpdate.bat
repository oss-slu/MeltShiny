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

:: Get the name of the program directory
for %%a in (%PROGRAM_DIR%) do set PROGRAM_NAME=%%~nxa

:: Check if the program directory is named 'MeltWin2.0-main'
:: -main signifies this was locally installed by a user from the repository.
if /I not "%PROGRAM_NAME%"=="MeltShiny-main" (
    echo Error: The parent directory is not 'MeltShiny-main'! Exiting...
    pause
    exit /b 1
)

:: Define the 'code' subdirectory inside PROGRAM_DIR
set CODE_DIR=%PROGRAM_DIR%\code

:: Create a temporary directory
set TEMP_DIR=%TEMP%\UpdateTemp
mkdir "%TEMP_DIR%"
:: Download the latest ZIP archive
powershell -Command "& { Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%TEMP_DIR%\latest.zip' }"
:: Unzip the archive to a temporary location
powershell -Command "& { Expand-Archive -Path '%TEMP_DIR%\latest.zip' -DestinationPath '%TEMP_DIR%' -Force }"

:: Delete the existing 'code' subdirectory inside PROGRAM_DIR
rd /s /q "%CODE_DIR%"
:: Copy the 'code' subdirectory from the unzipped folder to PROGRAM_DIR
xcopy /E /I /Y "%TEMP_DIR%\MeltWin2.0-main\code\*" "%CODE_DIR%\"

:: Clean up the temporary directory
rd /s /q "%TEMP_DIR%"

echo Update complete! Your program's 'code' subdirectory is now up to date.
pause
