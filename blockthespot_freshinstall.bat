@echo off
::made by mahiatlinux, 2026
title BlockTheSpot Fresh Install
echo ============================================
echo  BlockTheSpot - Fresh Install Script
echo ============================================
echo.

echo Closing Spotify...
taskkill /f /im spotify.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo Removing Microsoft Store Spotify (if installed)...
powershell -Command "Get-AppxPackage *SpotifyAB* | Remove-AppxPackage" 2>nul

echo Cleaning old Spotify installation...
if exist "%APPDATA%\Spotify" rd /s /q "%APPDATA%\Spotify"
if exist "%LOCALAPPDATA%\Spotify" rd /s /q "%LOCALAPPDATA%\Spotify"

echo Downloading Spotify desktop installer...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing 'https://download.scdn.co/SpotifySetup.exe' -OutFile '%TEMP%\SpotifySetup.exe'"

echo Installing Spotify...
start /wait "" "%TEMP%\SpotifySetup.exe"
del "%TEMP%\SpotifySetup.exe" >nul 2>&1

echo Waiting for Spotify to finish setup...
timeout /t 15 /nobreak >nul
taskkill /f /im spotify.exe >nul 2>&1
timeout /t 3 /nobreak >nul

set "SPOTIFY_DIR=%APPDATA%\Spotify"

echo.
echo Patching Spotify with BlockTheSpot...
if exist "%SPOTIFY_DIR%\chrome_elf.dll" (
    if exist "%SPOTIFY_DIR%\chrome_elf_required.dll" del /f "%SPOTIFY_DIR%\chrome_elf_required.dll"
    ren "%SPOTIFY_DIR%\chrome_elf.dll" chrome_elf_required.dll
)

echo Downloading BlockTheSpot release...
powershell -Command ^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; " ^
    "$rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/mrpond/BlockTheSpot/releases/latest'; " ^
    "$zip = ($rel.assets | Where-Object { $_.name -like '*.zip' })[0].browser_download_url; " ^
    "Invoke-WebRequest -UseBasicParsing $zip -OutFile '%TEMP%\BlockTheSpot.zip'"

echo Extracting files...
powershell -Command "Expand-Archive -Path '%TEMP%\BlockTheSpot.zip' -DestinationPath '%TEMP%\BlockTheSpot' -Force"
copy /y "%TEMP%\BlockTheSpot\chrome_elf.dll" "%SPOTIFY_DIR%\" >nul 2>&1
copy /y "%TEMP%\BlockTheSpot\blockthespot.dll" "%SPOTIFY_DIR%\" >nul 2>&1
copy /y "%TEMP%\BlockTheSpot\config.ini" "%SPOTIFY_DIR%\" >nul 2>&1

echo Downloading latest config.ini...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/mrpond/BlockTheSpot/master/config.ini' -OutFile '%SPOTIFY_DIR%\config.ini'"

rd /s /q "%TEMP%\BlockTheSpot" >nul 2>&1
del "%TEMP%\BlockTheSpot.zip" >nul 2>&1

echo.
echo ============================================
echo  Done!
echo ============================================
pause
