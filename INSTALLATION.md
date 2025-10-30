# Installation Guide - Penrion OSU! Tablet Driver

## Prerequisites

### For iPad
- iPad with iOS 17.0 or higher
- iPad Air 3rd generation or newer recommended
- Apple Pencil (optional but recommended)
- 2GB free storage space

### For Windows PC
- Windows 10 version 1809 or Windows 11
- .NET 8.0 Runtime (auto-installed with app)
- 100MB free disk space
- 4GB RAM minimum
- WiFi adapter or Ethernet connection
- Administrator access

## Installation Steps

### Part 1: Windows PC Setup

#### Option A: Using Pre-built Executable (Recommended)

1. **Download the Application**
   - Download `OsuTabletDriver.exe` from the release folder
   - Or build from source using `build-windows.ps1`

2. **Extract Files**
   ```
   Penrion/
   └── release/
       ├── OsuTabletDriver.exe
       └── (additional DLL files)
   ```

3. **First Run**
   - Right-click `OsuTabletDriver.exe`
   - Select "Run as administrator"
   - Click "Yes" on the UAC prompt
   - Allow firewall access when prompted

4. **Firewall Configuration**
   - Windows Firewall will ask for permission
   - ✓ Check "Private networks"
   - ✓ Check "Public networks" (optional)
   - Click "Allow access"

5. **Verify Installation**
   - Application window should open
   - Status should show "Waiting for connection..."
   - System tray icon appears

#### Option B: Building from Source

1. **Install .NET SDK**
   - Download from: https://dotnet.microsoft.com/download
   - Install .NET 8.0 SDK

2. **Build the Application**
   ```powershell
   cd windows-app\OsuTabletDriver
   dotnet restore
   dotnet publish -c Release -r win-x64 --self-contained true
   ```

3. **Run the Application**
   ```powershell
   cd bin\Release\net8.0-windows\win-x64\publish
   .\OsuTabletDriver.exe
   ```

### Part 2: iPad Setup

#### Option A: Install from Xcode (Development)

1. **Requirements**
   - macOS computer with Xcode 15+
   - Apple Developer account (free tier works)
   - USB-C cable to connect iPad

2. **Open Project**
   ```bash
   cd ios-app/OsuTablet
   open OsuTablet.xcodeproj
   ```

3. **Configure Signing**
   - Select project in Xcode
   - Go to "Signing & Capabilities"
   - Select your Team
   - Xcode will auto-generate provisioning profile

4. **Build and Run**
   - Connect iPad via USB
   - Select iPad as target device
   - Click Run (Cmd + R)
   - Wait for build and installation

5. **Trust Developer**
   - On iPad: Settings > General > VPN & Device Management
   - Tap on your Apple ID
   - Tap "Trust [Your Name]"

#### Option B: Install from App Store (Future)

*Note: App Store version is planned for future release*

### Part 3: Network Configuration

1. **Connect Devices to Same Network**
   - Both iPad and PC must be on same WiFi network
   - 5GHz WiFi recommended for best performance
   - Disable VPN on both devices

2. **Find PC IP Address**
   ```powershell
   ipconfig
   ```
   Look for "IPv4 Address" under your WiFi adapter
   Example: `192.168.1.100`

3. **Configure Firewall (if needed)**
   - Open Windows Defender Firewall
   - Advanced Settings
   - Inbound Rules > New Rule
   - Port: 9876, TCP
   - Allow the connection

### Part 4: First Connection

1. **Start Windows App**
   - Run as Administrator
   - Wait for "Server started on port 9876" message

2. **Launch iPad App**
   - Open "Penrion" on iPad
   - App will auto-discover PC
   - Tap on your PC name when it appears

3. **Verify Connection**
   - iPad shows "Connected" status
   - Windows app shows iPad IP address
   - Green indicator on both devices

### Part 5: OSU! Configuration

1. **Launch OSU!**
   - Start osu!lazer or osu!stable on Windows

2. **Configure Input**
   - Open Options > Input
   - Set input mode to "Tablet"
   - Windows should detect tablet automatically

3. **Test in OSU!**
   - Open practice mode
   - Touch iPad screen
   - Cursor should move on PC
   - Check latency indicator

## Verification Checklist

### Windows App
- [ ] Application launches without errors
- [ ] Firewall permission granted
- [ ] "Waiting for connection..." status shown
- [ ] No error messages in console

### iPad App
- [ ] App launches successfully
- [ ] Permissions granted (local network)
- [ ] PC appears in device list
- [ ] Connection successful

### Connection Test
- [ ] iPad shows "Connected" status
- [ ] Windows shows iPad IP address
- [ ] Green indicators on both devices
- [ ] Latency < 20ms

### OSU! Test
- [ ] OSU! detects tablet input
- [ ] Cursor moves smoothly
- [ ] Touch works in-game
- [ ] No stuttering or lag

## Common Issues & Solutions

### Issue: PC not discovered
**Solutions:**
- Ensure both devices on same network
- Check firewall settings (port 9876)
- Try manual connection with IP address
- Disable WiFi isolation on router

### Issue: High latency (>50ms)
**Solutions:**
- Switch to 5GHz WiFi
- Move closer to router
- Close bandwidth-heavy apps
- Reduce screen mirroring quality

### Issue: Connection drops
**Solutions:**
- Disable power saving on WiFi
- Check router stability
- Use wired connection for PC
- Update network drivers

### Issue: Touch not working in OSU!
**Solutions:**
- Run Windows app as Administrator
- Set OSU! input mode to "Tablet"
- Restart OSU! after connecting
- Check OSU! tablet settings

### Issue: Screen mirroring not working
**Solutions:**
- Check network bandwidth
- Lower quality in settings
- Disable other screen capture apps
- Update graphics drivers

## Uninstallation

### Windows
1. Close OsuTabletDriver.exe
2. Delete installation folder
3. Remove firewall rule (optional)

### iPad
1. Press and hold app icon
2. Tap "Remove App"
3. Confirm deletion

## Advanced Configuration

### Custom Port
Edit settings to use different port:
- iOS: Settings > Network > Port
- Windows: Modify ConnectionServer constructor

### Active Area
Customize tablet area:
- iOS: Settings > Active Area
- Adjust width/height percentages
- Enable "Show Area Outline" for visual guide

### Pressure Curve
Adjust pressure response:
- iOS: Settings > Pressure Sensitivity
- Choose curve type (Linear/Exponential/Logarithmic)
- Adjust sensitivity slider

## Getting Help

If you encounter issues:
1. Check this installation guide
2. Review DEVELOPMENT.md for technical details
3. Check firewall and network settings
4. Open GitHub issue with details

## Next Steps

After successful installation:
1. Calibrate tablet area
2. Adjust pressure sensitivity
3. Test in OSU! practice mode
4. Fine-tune settings for your play style
5. Enjoy!

---

**Important Notes:**
- Always run Windows app as Administrator
- Keep both devices plugged in during play
- Use 5GHz WiFi for best performance
- iPad may get warm during extended use

**Support:**
- GitHub Issues for bug reports
- See PROGRESS.md for development status
- Check README.md for features and requirements
