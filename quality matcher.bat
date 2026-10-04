@echo off
setlocal DisableDelayedExpansion

:: Default reference video
set "DEFAULT_REF=C:\Users\wrench\Downloads\YouCut_20260926_120253634.mp4"

:: Output folder
set "OUT_DIR=C:\Users\wrench\Downloads\exported videos"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

echo ====================================================
echo REFERENCE VIDEO SELECTION
echo ====================================================
echo Default: %DEFAULT_REF%
echo.
set "REF_VIDEO="
set /p "REF_VIDEO=Drag and drop REFERENCE video (or press Enter for default): "

if not defined REF_VIDEO set "REF_VIDEO=%DEFAULT_REF%"

:: Strip surrounding quotes safely
for /f "delims=" %%i in ("%REF_VIDEO%") do set "REF_VIDEO=%%~fi"

cls
echo ====================================================
echo Reading specs from reference video:
echo "%REF_VIDEO%"
echo ====================================================

setlocal EnableDelayedExpansion

:: Extract Video Properties
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams v:0 -show_entries stream^=width -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "WIDTH=%%a"
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams v:0 -show_entries stream^=height -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "HEIGHT=%%a"
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams v:0 -show_entries stream^=r_frame_rate -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "FPS=%%a"
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams v:0 -show_entries stream^=bit_rate -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "V_BITRATE=%%a"

if "!V_BITRATE!"=="" or "!V_BITRATE!"=="N/A" (
    for /f "tokens=*" %%a in ('ffprobe -v error -show_entries format^=bit_rate -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "V_BITRATE=%%a"
)

:: Extract Audio Properties
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams a:0 -show_entries stream^=sample_rate -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "A_RATE=%%a"
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams a:0 -show_entries stream^=channels -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "A_CHANNELS=%%a"
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams a:0 -show_entries stream^=bit_rate -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "A_BITRATE=%%a"

if "!A_BITRATE!"=="" or "!A_BITRATE!"=="N/A" (
    for /f "tokens=*" %%a in ('ffprobe -v error -select_streams a:0 -show_entries format^=bit_rate -of default^=nw^=1:nk^=1 "!REF_VIDEO!"') do set "A_BITRATE=%%a"
)

:: Fallbacks
if "!A_RATE!"=="" set "A_RATE=44100"
if "!A_CHANNELS!"=="" set "A_CHANNELS=2"
if "!A_BITRATE!"=="" or "!A_BITRATE!"=="N/A" set "A_BITRATE=32k"

echo Detected Specs:
echo  - Resolution: !WIDTH!x!HEIGHT!
echo  - FPS:        !FPS!
echo  - Video Bitrate: !V_BITRATE! bps
echo  - Audio Bitrate: !A_BITRATE! bps
echo  - Audio Sample Rate / Ch: !A_RATE! Hz / !A_CHANNELS! ch
echo ====================================================
echo.

endlocal & set "WIDTH=%WIDTH%" & set "HEIGHT=%HEIGHT%" & set "FPS=%FPS%" & set "V_BITRATE=%V_BITRATE%" & set "A_RATE=%A_RATE%" & set "A_CHANNELS=%A_CHANNELS%" & set "A_BITRATE=%A_BITRATE%"

:: Get Input Video safely
set "INPUT_FILE="
set /p "INPUT_FILE=Drag and drop your ORIGINAL video to convert: "
for /f "delims=" %%i in ("%INPUT_FILE%") do set "INPUT_FILE=%%~fi"

:: Get Output Filename
set "OUT_NAME="
set /p "OUT_NAME=Enter output filename (without .mp4): "
set "FINAL_OUTPUT=%OUT_DIR%\%OUT_NAME%.mp4"

:: Settings Toggles
set "USE_RES=1"
set "RES_MODE=2"
set "USE_FPS=1"
set "USE_VBIT=1"
set "USE_ABIT=1"
set "USE_ARATE=1"

:MENU
cls
echo ====================================================
echo OPTION TOGGLES (Type a number to toggle ON/OFF)
echo ====================================================

if "%USE_RES%"=="1" goto SHOW_RES_ON
echo [1] Resolution Match [%WIDTH%x%HEIGHT%] : DISABLED
goto SHOW_REST

:SHOW_RES_ON
if "%RES_MODE%"=="1" echo [1] Resolution Match [%WIDTH%x%HEIGHT%] : ENABLED (Fit + Black Bars)
if "%RES_MODE%"=="2" echo [1] Resolution Match [%WIDTH%x%HEIGHT%] : ENABLED (Force Stretch Fill)
if "%RES_MODE%"=="3" echo [1] Resolution Match [%WIDTH%x%HEIGHT%] : ENABLED (Crop Fill / Zoom)

:SHOW_REST
if "%USE_FPS%"=="1" (echo [2] Frame Rate Match [%FPS% FPS]       : ENABLED) else (echo [2] Frame Rate Match [%FPS% FPS]       : DISABLED)
if "%USE_VBIT%"=="1" (echo [3] Video Bitrate Match [%V_BITRATE%] : ENABLED) else (echo [3] Video Bitrate Match [%V_BITRATE%] : DISABLED)
if "%USE_ABIT%"=="1" (echo [4] Audio Bitrate Match [%A_BITRATE%] : ENABLED) else (echo [4] Audio Bitrate Match [%A_BITRATE%] : DISABLED)
if "%USE_ARATE%"=="1" (echo [5] Audio Sample Rate/Ch [%A_RATE%Hz/%A_CHANNELS%ch] : ENABLED) else (echo [5] Audio Sample Rate/Ch [%A_RATE%Hz/%A_CHANNELS%ch] : DISABLED)
echo ====================================================
echo [M] CYCLE RESOLUTION SCALING MODE
echo [R] RUN ENCODING
echo ====================================================
set "CHOICE="
set /p "CHOICE=Select an option [1-5], M, or R to start: "

if "%CHOICE%"=="1" (
    if "%USE_RES%"=="1" (set "USE_RES=0") else (set "USE_RES=1")
    goto MENU
)
if "%CHOICE%"=="2" (
    if "%USE_FPS%"=="1" (set "USE_FPS=0") else (set "USE_FPS=1")
    goto MENU
)
if "%CHOICE%"=="3" (
    if "%USE_VBIT%"=="1" (set "USE_VBIT=0") else (set "USE_VBIT=1")
    goto MENU
)
if "%CHOICE%"=="4" (
    if "%USE_ABIT%"=="1" (set "USE_ABIT=0") else (set "USE_ABIT=1")
    goto MENU
)
if "%CHOICE%"=="5" (
    if "%USE_ARATE%"=="1" (set "USE_ARATE=0") else (set "USE_ARATE=1")
    goto MENU
)

if /i "%CHOICE%"=="M" (
    if "%RES_MODE%"=="1" (set "RES_MODE=2") else if "%RES_MODE%"=="2" (set "RES_MODE=3") else (set "RES_MODE=1")
    goto MENU
)

if /i "%CHOICE%"=="R" goto PROCESS

goto MENU

:PROCESS
set "FF_VF="
set "FF_FPS="
set "FF_VBIT="
set "FF_ABIT="
set "FF_ARATE="

if "%USE_RES%"=="1" (
    if "%RES_MODE%"=="1" set FF_VF=-vf "scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=decrease,pad=%WIDTH%:%HEIGHT%:(ow-iw)/2:(oh-ih)/2,setsar=1,setdar=%WIDTH%/%HEIGHT%"
    if "%RES_MODE%"=="2" set FF_VF=-vf "scale=%WIDTH%:%HEIGHT%,setsar=1,setdar=%WIDTH%/%HEIGHT%"
    if "%RES_MODE%"=="3" set FF_VF=-vf "scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,setsar=1,setdar=%WIDTH%/%HEIGHT%"
)

if "%USE_FPS%"=="1" set "FF_FPS=-r %FPS%"
if "%USE_VBIT%"=="1" set "FF_VBIT=-b:v %V_BITRATE% -maxrate %V_BITRATE% -bufsize %V_BITRATE%"
if "%USE_ABIT%"=="1" set "FF_ABIT=-b:a %A_BITRATE%"
if "%USE_ARATE%"=="1" set "FF_ARATE=-ar %A_RATE% -ac %A_CHANNELS%"

echo.
echo Processing video with selected settings...
echo.

ffmpeg -i "%INPUT_FILE%" %FF_VF% %FF_FPS% %FF_VBIT% -c:a aac %FF_ARATE% %FF_ABIT% -aspect %WIDTH%:%HEIGHT% "%FINAL_OUTPUT%" -y

echo.
echo ====================================================
echo Done! Video saved to: "%FINAL_OUTPUT%"
echo ====================================================
pause