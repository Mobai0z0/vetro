# Vetro 打包指南

## 前置条件
- 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.32)
- 安装 [Git](https://git-scm.com/)

## 快速打包步骤

### 1. 创建项目并复制代码

```bash
# 创建 Flutter 项目
flutter create vetro --org com.example

# 用我们的代码覆盖
# Windows PowerShell:
Copy-Item -Path ".\lib" -Destination ".\vetro\lib" -Recurse -Force
Copy-Item -Path ".\pubspec.yaml" -Destination ".\vetro\pubspec.yaml" -Force
Copy-Item -Path ".\analysis_options.yaml" -Destination ".\vetro\analysis_options.yaml" -Force

# macOS / Linux:
# cp -r lib/ vetro/lib/
# cp pubspec.yaml vetro/pubspec.yaml
# cp analysis_options.yaml vetro/analysis_options.yaml
```

### 2. 安装依赖

```bash
cd vetro
flutter pub get
```

### 3. 按 PLATFORM_SETUP.md 配置各平台权限

特别是 Android 的 `AndroidManifest.xml` 需要添加存储权限。

### 4. 打包

#### Windows (生成 .exe 安装包)
```bash
flutter build windows --release
# 输出: build/windows/x64/runner/Release/
```

#### macOS (生成 .app / .dmg)
```bash
flutter build macos --release
# 输出: build/macos/Build/Products/Release/
```

#### Linux (生成可执行文件 / .deb)
```bash
flutter build linux --release
# 输出: build/linux/x64/release/bundle/
```

#### Android (生成 .apk / .aab)
```bash
# Debug APK (快速测试)
flutter build apk --debug

# Release APK
flutter build apk --release

# Release AAB (上架 Google Play)
flutter build appbundle --release
# 输出: build/app/outputs/
```

#### iOS (需要 macOS + Xcode)
```bash
flutter build ios --release
# 然后在 Xcode 中 Archive 并导出 IPA
```

### 5. 一键打包脚本 (Windows PowerShell)

```powershell
# 在 vetro 项目根目录运行
Write-Host "Building Vetro for all platforms..." -ForegroundColor Cyan

Write-Host "`n[1/5] Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n[2/5] Building Windows..." -ForegroundColor Yellow
flutter build windows --release

Write-Host "`n[3/5] Building Android APK..." -ForegroundColor Yellow
flutter build apk --release

Write-Host "`n[4/5] Building Android AAB..." -ForegroundColor Yellow
flutter build appbundle --release

Write-Host "`n[5/5] Build complete!" -ForegroundColor Green
Write-Host "Windows: build\windows\x64\runner\Release\" -ForegroundColor Cyan
Write-Host "Android APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
Write-Host "Android AAB: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Cyan
```
