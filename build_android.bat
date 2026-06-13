@echo off
echo ============================================
echo   Vetro - Android Build Script
echo ============================================
echo.

REM Check Flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found. Please install Flutter SDK first.
    pause
    exit /b 1
)

REM Check Java
where java >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java/JDK not found. Please install JDK 17+.
    pause
    exit /b 1
)

REM Create project if not exists
if not exist "vetro" (
    echo [1/5] Creating Flutter project...
    flutter create vetro --org com.example --platforms android
)

REM Copy source files
echo [2/5] Copying source files...
xcopy /E /Y /Q "lib" "vetro\lib\" >nul
copy /Y "pubspec.yaml" "vetro\pubspec.yaml" >nul

REM Install dependencies
echo [3/5] Installing dependencies...
cd vetro
flutter pub get

REM Build APK
echo [4/5] Building APK...
flutter build apk --release

REM Build AAB
echo [5/5] Building AAB (Play Store)...
flutter build appbundle --release
cd ..

echo.
echo ============================================
echo   BUILD COMPLETE!
echo ============================================
echo   APK: vetro\build\app\outputs\flutter-apk\app-release.apk
echo   AAB: vetro\build\app\outputs\bundle\release\app-release.aab
echo ============================================

pause
