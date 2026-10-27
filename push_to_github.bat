@echo off
echo ========================================================
echo  iSecure EduMaster CCE Pro - GitHub Push and Deploy
echo  Repository: https://github.com/isecuredevelopers/iSecure-EduMaster-CCE-Pro
echo ========================================================
echo.

cd /d "%~dp0"

echo [1/3] Adding files to Git...
git add .
git commit -m "feat: iSecure EduMaster CCE Pro v1.0.0 - Full School Management & Auto-Updater" 2>nul

echo.
echo [2/3] Creating Release Tag v1.0.0...
git tag -fa v1.0.0 -m "iSecure EduMaster CCE Pro Release v1.0.0"

echo.
echo [3/3] Pushing code and tags to GitHub...
echo (जर ब्राउझर किंवा लॉगिन विंडो उघडली, तर कृपया GitHub वर Sign In / Authorize करा)
git push -u origin main --force
git push origin v1.0.0 --force

echo.
echo ========================================================
echo  यशस्वी! सर्व कोड आणि रिलीज टॅग GitHub वर पुश झाले आहेत.
echo  GitHub Actions वर्कफ्लो तपासण्यासाठी:
echo  https://github.com/isecuredevelopers/iSecure-EduMaster-CCE-Pro/actions
echo ========================================================
pause
