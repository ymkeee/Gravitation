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

set /p GITHUB_USER="Enter your GitHub username: "
if "%GITHUB_USER%"=="" (
    echo [ERROR] Username cannot be empty!
    pause
    exit /b 1
)

echo.
echo GitHub Repository: https://github.com/%GITHUB_USER%/Gravitation
echo.
echo IMPORTANT: Create the repository on GitHub first!
echo 1. Go to https://github.com/new
echo 2. Repository name: Gravitation
echo 3. Make it Public or Private
echo 4. DO NOT add README, .gitignore, or license
echo 5. Click "Create repository"
echo.
set /p READY="Have you created the repository? (y/n): "
if /i not "%READY%"=="y" (
    echo.
    echo Exiting... Create the repository first, then run this script again.
    pause
    exit /b 0
)

echo.
echo Initializing Git repository...
git init
git branch -M main
git add .
git commit -m "Gravitation 2.0: RootHide Dopamine iOS 16.2 fix (no icon placement bugs, fixed widgets, iPhone 14 Pro Max support)"
git remote remove origin 2>nul
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
