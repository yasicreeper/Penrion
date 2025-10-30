# 📱 IPA Build & Installation Guide

## Building the IPA File

### Requirements
- **macOS computer** (required for building iOS apps)
- **Xcode 15 or higher** (free from Mac App Store)
- **10GB free disk space**

### Build Steps

1. **On your Mac**, open Terminal and navigate to the project:
```bash
cd /path/to/Penrion
```

2. **Make the build script executable:**
```bash
chmod +x build-ios.sh
```

3. **Run the build script:**
```bash
./build-ios.sh
```

4. **Wait for build to complete** (2-5 minutes)

5. **Find your IPA:**
```
Penrion/release/ios/Penrion-OsuTablet.ipa
```

---

## Installation Methods

### 🔓 Method 1: Jailbroken iPad (Easiest)

**Requirements:**
- Jailbroken iPad (iOS 17.x)
- AppSync Unified installed from Cydia/Sileo

**Steps:**
1. Install AppSync Unified if you haven't:
   - Open Cydia/Sileo
   - Search for "AppSync Unified"
   - Install it

2. Transfer IPA to iPad:
   - Use AirDrop, or
   - Upload to cloud storage (iCloud, Dropbox), or
   - Use Filza to download from a URL

3. Install the IPA:
   - Tap the IPA file in Files app or Filza
   - Tap "Install" or "Open in Filza"
   - If using Filza: Tap "Installer" → "Install"
   - Wait for installation
   - App will appear on home screen

**Advantage:** No signing required, permanent installation

---

### 📱 Method 2: AltStore (No Jailbreak Required)

**Requirements:**
- AltStore installed on iPad
- AltServer running on PC/Mac (same WiFi network)
- Free Apple ID

**Steps:**
1. **Install AltStore:**
   - Download from https://altstore.io
   - Follow installation instructions
   - Install AltStore on your iPad

2. **Install AltServer on PC:**
   - Download AltServer for Windows/Mac
   - Install and run it
   - Ensure PC and iPad are on same WiFi

3. **Install IPA:**
   - Open AltStore on iPad
   - Tap "+" icon (top left)
   - Browse to the IPA file
   - Wait for installation (2-3 minutes)

4. **Refresh every 7 days:**
   - Apps signed this way expire after 7 days
   - Open AltStore and tap "Refresh All" to re-sign
   - Must be on same WiFi as AltServer

**Advantage:** Works without jailbreak, easy to use

---

### 🔵 Method 3: SideStore (No Computer After Setup)

**Requirements:**
- Jailbroken device for initial setup (or WireGuard VPN method)
- Free Apple ID

**Steps:**
1. **Install SideStore:**
   - Download from https://sidestore.io
   - Follow jailbreak-free installation guide (WireGuard method)
   - Or install via jailbreak tweak injector

2. **Install IPA:**
   - Open SideStore
   - Tap "+" and select IPA
   - Sign and install
   - No computer needed after setup!

3. **Enable WiFi signing:**
   - Install pairing file during setup
   - Refresh apps wirelessly

**Advantage:** No computer needed after initial setup

---

### 🖥️ Method 4: Sideloadly (Windows/Mac)

**Requirements:**
- Sideloadly app
- Free Apple ID
- USB cable (or WiFi sync enabled)

**Steps:**
1. **Download Sideloadly:**
   - Visit https://sideloadly.io
   - Download for Windows or Mac
   - Install and open

2. **Connect iPad:**
   - Connect via USB or enable WiFi sync

3. **Sideload IPA:**
   - Drag IPA into Sideloadly
   - Enter Apple ID and password
   - Click "Start"
   - Wait for installation

4. **Trust certificate:**
   - Settings → General → VPN & Device Management
   - Tap your Apple ID
   - Tap "Trust"

**Needs renewal every 7 days** (free account)

**Advantage:** Works on Windows, reliable

---

### 💻 Method 5: Xcode (Mac Only)

**Requirements:**
- Mac with Xcode
- iPad connected via USB
- Free Apple ID

**Steps:**
1. **Connect iPad to Mac** via USB

2. **Open Xcode:**
   - Window → Devices and Simulators
   - Select your iPad

3. **Install IPA:**
   - Drag IPA file onto device in Xcode
   - Wait for installation
   - Or use: `xcrun devicectl device install app --device <UDID> Penrion-OsuTablet.ipa`

4. **Trust certificate:**
   - Settings → General → VPN & Device Management
   - Trust your Apple ID

**Needs renewal every 7 days**

**Advantage:** Official Apple method, reliable

---

### 🏢 Method 6: Enterprise Certificate (Advanced)

**Requirements:**
- Apple Developer Enterprise account ($299/year)
- Enterprise provisioning profile

**Steps:**
1. **Sign IPA with enterprise certificate:**
   ```bash
   # Use tools like zsign or ios-app-signer
   ```

2. **Distribute IPA:**
   - Upload to web server
   - Create manifest.plist for OTA installation
   - Install via Safari

**Advantage:** No 7-day expiration, no computer needed

---

### 🎯 Method 7: Developer Account (Best for Personal Use)

**Requirements:**
- Paid Apple Developer account ($99/year)
- Mac with Xcode

**Steps:**
1. **Open project in Xcode:**
   ```bash
   cd ios-app/OsuTablet
   open OsuTablet.xcodeproj
   ```

2. **Configure signing:**
   - Select your team in Xcode
   - Choose automatic signing
   - Xcode will create provisioning profile

3. **Build for device:**
   - Connect iPad
   - Select iPad as target
   - Product → Archive
   - Distribute App → Development
   - Install via Xcode

**Apps last 1 year before needing renewal**

**Advantage:** Best long-term solution, professional

---

## Comparison Table

| Method | Jailbreak Needed | Cost | Renewal | Difficulty |
|--------|-----------------|------|---------|------------|
| Jailbreak + AppSync | Yes | Free | Never | Easy |
| AltStore | No | Free | 7 days | Easy |
| SideStore | No* | Free | 7 days | Medium |
| Sideloadly | No | Free | 7 days | Easy |
| Xcode | No | Free | 7 days | Medium |
| Developer Account | No | $99/yr | 1 year | Medium |
| Enterprise Cert | No | $299/yr | 1 year | Hard |

*SideStore needs jailbreak OR WireGuard VPN trick for initial setup only

---

## Recommended Methods

### For Jailbroken Users:
✅ **Method 1: AppSync Unified** - Easiest and permanent

### For Non-Jailbroken Users:
✅ **Method 2: AltStore** - Easiest to set up
✅ **Method 3: SideStore** - Best after setup (no computer)

### For Long-Term Use:
✅ **Method 7: Paid Developer Account** - Worth it for 1-year signing

---

## Troubleshooting

### "Untrusted Developer" Error
**Solution:**
- Settings → General → VPN & Device Management
- Tap your Apple ID or certificate
- Tap "Trust"

### "Unable to Install"
**Solution:**
- Ensure iOS 17.0 or higher
- Delete old version if installed
- Restart iPad and try again
- Check available storage (need 200MB+)

### App Crashes on Launch
**Solution:**
- Ensure proper signing
- Check device logs in Xcode
- Verify minimum iOS 17.0

### "App is No Longer Available"
**Solution:**
- Re-sign the app (expired certificate)
- Use AltStore "Refresh" feature
- Or reinstall with Sideloadly

### Can't Connect to PC
**Solution:**
- Ensure both on same WiFi network
- Check Windows firewall allows port 9876
- Verify iPad can see PC in discovery

---

## Building on Windows (Alternative)

While iOS apps require macOS to build, you can:

1. **Use a Virtual Machine:**
   - Install macOS in VMware/VirtualBox
   - Install Xcode in VM
   - Build IPA as normal

2. **Use a Cloud Mac:**
   - Services like MacStadium or MacInCloud
   - Rent macOS for a few hours
   - Build via remote desktop

3. **Ask Someone with a Mac:**
   - Share source code
   - They build and send you IPA

4. **Use CI/CD Service:**
   - GitHub Actions (includes macOS runners)
   - Set up automated builds
   - Download IPA from artifacts

---

## Post-Installation

### First Launch:
1. Open Penrion app on iPad
2. Allow local network access when prompted
3. Keep iPad on same WiFi as PC

### Connect to PC:
1. Run OsuTabletDriver.exe on Windows (as Administrator)
2. Open Penrion on iPad
3. Tap "Find PC" or enter IP manually
4. Tap your PC name to connect

### Start Playing:
1. Launch osu! on PC
2. Switch to "OSU! Mode" in Penrion
3. Start tapping!

---

## Questions?

- **IPA won't install:** Check iOS version (need 17.0+)
- **App crashes:** Check device logs, ensure proper signing
- **Can't build IPA:** macOS + Xcode required
- **Need help signing:** Use AltStore or Sideloadly

---

## Legal Note

This app is for personal use only. Sideloading is allowed by Apple for development purposes. Free accounts are limited to 3 apps and 7-day signing. For production distribution, use the App Store or an Enterprise certificate.

---

**Ready to build?** Run `./build-ios.sh` on your Mac!

**Need Windows app too?** Run `.\build.ps1` in PowerShell!
