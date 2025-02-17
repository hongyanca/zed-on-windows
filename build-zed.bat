@echo off
:: Fetch the latest release of zed-industries/zed using GitHub API
:: Ensure jq is installed and accessible

:: Set variables
set REPO="zed-industries/zed"
set API_URL="https://api.github.com/repos/%REPO%/releases/latest"
set OUTPUT_FILE="latest-release.json"

:: Fetch the latest release details using curl
echo Fetching the latest release details for %REPO%...
curl -s %API_URL% -o %OUTPUT_FILE%

:: Parse the release tag using jq
for /f "tokens=*" %%A in ('jq -r ".tag_name" %OUTPUT_FILE%') do set TAG_NAME=%%A

:: Check if the TAG_NAME variable is populated
if "%TAG_NAME%"=="" (
    echo Failed to fetch the release tag. Exiting.
    del %OUTPUT_FILE%
    exit /b 1
)

echo Latest release: %TAG_NAME%

:: Construct the source code download URL
set DOWNLOAD_URL="https://github.com/zed-industries/zed/archive/refs/tags/%TAG_NAME%.zip"

:: Download the latest release source code
echo Downloading the latest release source code...
del "zed-src-%TAG_NAME%.zip"
curl -L -o "zed-src-%TAG_NAME%.zip" %DOWNLOAD_URL%

:: Check if the file was downloaded successfully
if not exist "zed-src-%TAG_NAME%.zip" (
    echo Failed to download the source code. Exiting.
    del %OUTPUT_FILE%
    exit /b 1
)

:: Clean up the JSON output file
del %OUTPUT_FILE%

:: Delete the "zed" folder if it exists
if exist "zed" (
    echo Deleting existing "zed" folder...
    rmdir /s /q "zed"
)

:: Unzip the downloaded source code to the "zed" folder
echo Extracting the source code to "zed" folder...
mkdir "zed"
tar -xf "zed-src-%TAG_NAME%.zip" -C "zed" --strip-components=1

echo Building zed...
cd "zed"
cargo run --release

cd ..
copy "zed\target\release\zed.exe" "zed-release\zed-%TAG_NAME%.exe"
