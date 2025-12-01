# Windows Setup Guide

## NuGet Installation (Fixed ✅)

NuGet has been installed to: `%LOCALAPPDATA%\Microsoft\WindowsApps\nuget.exe`

### To make NuGet permanently available:

1. **Add to PATH permanently:**
   - Press `Win + X` → System → Advanced system settings
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add: `%LOCALAPPDATA%\Microsoft\WindowsApps`
   - Click OK on all dialogs
   - Restart your terminal/PowerShell

2. **Or verify it's working:**
   ```powershell
   nuget help
   ```
   Should show: `NuGet Version: 7.0.0.289`

## Running the App

```bash
# Clean build (if needed)
flutter clean
flutter pub get

# Run on Windows
flutter run -d windows

# Or build release
flutter build windows --release
```

## Troubleshooting

### If NuGet error persists:
1. Download NuGet manually from: https://www.nuget.org/downloads
2. Place `nuget.exe` in `C:\Windows\System32` or add to PATH
3. Restart terminal

### If build fails:
1. Ensure Visual Studio 2022+ is installed with:
   - Desktop development with C++
   - Windows 10/11 SDK
2. Run `flutter doctor` to check setup
3. Try `flutter clean` and rebuild

## Current Status

✅ NuGet installed and working
✅ Flutter dependencies installed
✅ Windows build environment ready

