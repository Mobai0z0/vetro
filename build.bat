@echo off
echo ============================================
echo   Vetro - Build Script
echo ============================================
echo.

REM Check Flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found. Please install Flutter SDK first.
    echo https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

REM Create project if not exists
if not exist "vetro" (
    echo [1/4] Creating Flutter project...
    flutter create vetro --org com.example --platforms windows,android
)

REM Copy source files
echo [2/4] Copying source files...
xcopy /E /Y /Q "lib" "vetro\lib\" >nul
copy /Y "pubspec.yaml" "vetro\pubspec.yaml" >nul
copy /Y "analysis_options.yaml" "vetro\analysis_options.yaml" >nul

REM Install dependencies
echo [3/4] Installing dependencies...
cd vetro
flutter pub get
cd ..

REM Build Windows
echo [4/4] Building Windows release...
cd vetro
flutter build windows --release
cd ..

if %errorlevel% equ 0 (
    echo.
    echo ============================================
    echo   BUILD SUCCESSFUL!
    echo ============================================
    echo   Windows EXE: vetro\build\windows\x64\runner\Release\
    echo ============================================
) else (
    echo.
    echo [ERROR] Build failed. Check errors above.
)

pause
