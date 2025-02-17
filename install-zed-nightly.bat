@echo off
setlocal enabledelayedexpansion

:: Define variables
set "REPO=deevus/zed-windows-builds"
set "ASSET_NAME=zed-windows.zip"
set "TEMP_FILE=temp.json"
set "DEST_DIR=%userprofile%\dev"
set "EXTRACTED_FOLDER=%DEST_DIR%\zed-release"
set "ZIP_FILE=%DEST_DIR%\%ASSET_NAME%"

:: Ensure destination directory exists
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

:: Remove existing zed-release folder
if exist "%EXTRACTED_FOLDER%" (
    echo Deleting existing folder: %EXTRACTED_FOLDER%
    rmdir /s /q "%EXTRACTED_FOLDER%"
)

:: Get latest release data from GitHub API
curl -s -H "Accept: application/vnd.github.v3+json" ^
     "https://api.github.com/repos/%REPO%/releases/latest" > %TEMP_FILE%

:: Extract asset download URL using jq
for /f "tokens=* USEBACKQ" %%F in (`jq -r ".assets[] | select(.name == \"%ASSET_NAME%\") | .browser_download_url" %TEMP_FILE%`) do (
    set "DOWNLOAD_URL=%%F"
)

:: Cleanup temp file
del %TEMP_FILE%

:: Check if URL was found
if "%DOWNLOAD_URL%"=="" (
    echo Failed to find %ASSET_NAME% in the latest release.
    exit /b 1
)

:: Download the file
echo Downloading %ASSET_NAME%...
curl -L -o "%ZIP_FILE%" "%DOWNLOAD_URL%"

:: Extract using 7z
echo Extracting %ASSET_NAME%...
7z x "%ZIP_FILE%" -o"%DEST_DIR%" -y

:: Delete zip file after extraction
del "%ZIP_FILE%"

echo Extraction completed to %EXTRACTED_FOLDER%
exit /b 0
