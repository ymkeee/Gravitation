@echo off
REM Gravitation GitHub Setup Script
REM Automatically initializes Git and pushes to GitHub for automatic .deb compilation

echo ========================================
echo Gravitation (RootHide Dopamine iOS 16) Setup
echo ========================================
echo.

where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Git is not installed!
    echo Please install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo [OK] Git is installed
echo.

set /p GITHUB_USER="Enter your GitHub username (default ymkeee): "
if "%GITHUB_USER%"=="" set GITHUB_USER=ymkeee

echo.
echo GitHub Repository: https://github.com/%GITHUB_USER%/Gravitation
echo.

REM Configure git identity locally if not set
git config user.name >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    git config user.name "%GITHUB_USER%"
)
git config user.email >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    git config user.email "%GITHUB_USER%@users.noreply.github.com"
)
git config core.autocrlf false >nul 2>nul

echo Initializing Git repository...
git init >nul 2>nul
git branch -M main >nul 2>nul
git add .
git commit -m "Gravitation 2.0: RootHide Dopamine iOS 16.2 fix (no icon placement bugs, fixed widgets, iPhone 14 Pro Max support)" >nul 2>nul
git remote remove origin >nul 2>nul
git remote add origin https://github.com/%GITHUB_USER%/Gravitation.git

echo.
echo Pushing to GitHub...
git push -u origin main --force

echo.
echo ========================================
echo Done! Check GitHub Actions:
echo https://github.com/%GITHUB_USER%/Gravitation/actions
echo ========================================
pause
