# Vetro - Platform Setup Guide

This document describes the platform-specific configurations needed after running `flutter create`.

## Android

### 1. AndroidManifest.xml

Add these permissions inside `<manifest>` tag (before `<application>`):

```xml
<!-- Storage permissions for Android < 13 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Full file access for Android 11+ -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

<!-- Granular media permissions for Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Video playback -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Keep app running during video playback -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### 2. android/app/build.gradle

Ensure `minSdkVersion` is at least 21:

```groovy
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 3. Android 11+ Scoped Storage

For full file access on Android 11+, add this to `AndroidManifest.xml` inside `<application>`:

```xml
<application
    ...
    android:requestLegacyExternalStorage="true"
    android:hasFragileUserData="true">
```

### 4. Play Store Declaration

If publishing to Play Store, you need to fill out the
"Declaration Form for MANAGE_EXTERNAL_STORAGE" permission.

---

## iOS

### 1. Info.plist

Add these usage descriptions inside `<dict>`:

```xml
<!-- Photo library access -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Vetro needs access to your photos to display them.</string>

<!-- Camera (if needed for future features) -->
<key>NSCameraUsageDescription</key>
<string>Vetro needs camera access to capture photos.</string>

<!-- Microphone (for video playback) -->
<key>NSMicrophoneUsageDescription</key>
<string>Vetro needs microphone access for video playback.</string>

<!-- File access -->
<key>UIFileSharingEnabled</key>
<true/>

<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

### 2. App Sandbox

In `ios/Runner.xcodeproj`, ensure the App Sandbox capability is enabled
with appropriate file access entitlements.

---

## macOS

### 1. macOS Debug Profile / Release Entitlements

Add these to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.downloads.read-write</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

### 2. Info.plist (macOS)

Add these inside `<dict>`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Vetro needs access to your photos to display them.</string>

<key>NSMusicLibraryUsageDescription</key>
<string>Vetro needs access to your music library.</string>
```

---

## Windows

No special configuration required.
The app has full file system access by default.

For video playback, ensure Windows Media Feature Pack is installed.

---

## Linux

### 1. Dependencies

The app may need these system libraries:

```bash
# For GTK file dialogs
sudo apt-get install libgtk-3-dev

# For video playback (if using GTK)
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

# For notifications
sudo apt-get install libnotify-dev
```

### 2. Desktop Integration

For proper file association support, create a `.desktop` file:

```ini
[Desktop Entry]
Name=Vetro
Exec=/path/to/vetro
Icon=vetro
Type=Application
Categories=Utility;FileTools;FileManager;
MimeType=inode/directory;
```
