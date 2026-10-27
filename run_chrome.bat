@echo off
title MySchool CCE Evaluation System - Launching Chrome Web
set "PATH=D:\flutter_windows_3.38.9-stable\flutter\bin;%PATH%"
cd /d "%~dp0"
echo ========================================================
echo   Launching MySchool CCE 8.1 Web App (Google Chrome)
echo ========================================================
flutter run -d chrome
pause
