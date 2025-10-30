# 🎮 Penrion - iPad OSU! Tablet Driver

Transform your iPad into a professional OSU! drawing tablet with real-time PC screen mirroring.

## 🌟 Features

- **Ultra-Low Latency Touch Input** - Professional-grade tablet performance optimized for OSU!
- **Real-Time Screen Mirroring** - See your PC screen on your iPad while playing
- **Pressure Sensitivity** - Full Apple Pencil pressure support (8192 levels)
- **Customizable Active Area** - Match your preferred tablet size and ratio
- **OSU! Mode** - Dedicated interface optimized for rhythm gaming
- **Virtual Tablet Driver** - Acts as a native Windows tablet device
- **Auto-Detection** - Automatically detects OSU! and applies optimal settings

## 📱 Requirements

### iPad (iOS App)
- iOS 17.0 or higher
- iPad Air 3rd gen or newer recommended
- Apple Pencil (optional, for pressure sensitivity)
- WiFi connection (5GHz recommended for best performance)

### Windows PC (Companion App)
- Windows 10 version 1809 or higher
- .NET 8.0 Runtime
- WiFi adapter or Ethernet connection
- 4GB RAM minimum

## 🚀 Quick Start

### 1. Install iOS App
1. Open Xcode and build the project to your iPad
2. Trust the developer certificate in Settings > General > VPN & Device Management
3. Launch "Penrion" app on your iPad

### 2. Install Windows Companion
1. Run `OsuTabletDriver.exe` from the release folder
2. Allow firewall access when prompted
3. Grant administrator privileges for driver installation

### 3. Connect Devices
1. Ensure both devices are on the same WiFi network
2. Launch the Windows app first
3. Open the iOS app - it will auto-discover the PC
4. Tap "Connect" when your PC appears

### 4. Start Playing!
1. Switch to "OSU! Mode" in the iOS app
2. Launch OSU! on your PC
3. The screen will automatically mirror to your iPad
4. Start tapping!

## 🎨 Usage Modes

### OSU! Mode
Optimized for rhythm gaming with:
- Minimal UI for maximum play area
- Touch visualization
- Latency monitor
- Quick calibration access

### Windows Screen Mode
Full PC control with:
- Complete screen mirroring
- Mouse emulation
- Keyboard shortcuts
- Multi-monitor support (planned)

## ⚙️ Configuration

### iOS App Settings
- **Active Area**: Define your tablet region
- **Pressure Curve**: Customize pressure response
- **Touch Feedback**: Visual and haptic options
- **Network Settings**: Port and discovery options

### Windows App Settings
- **Tablet Area**: Map to screen regions
- **Pressure Mapping**: Linear, exponential, or custom curves
- **Screen Quality**: Balance between quality and latency
- **Auto-Start**: Launch with Windows

## 🔧 Building from Source

### iOS App
```bash
cd ios-app/OsuTablet
open OsuTablet.xcodeproj
# Build in Xcode (Cmd + B)
```

### Windows App
```powershell
cd windows-app/OsuTabletDriver
dotnet restore
dotnet publish -c Release -r win-x64 --self-contained true
# Output in bin/Release/net8.0-windows/win-x64/publish/
```

## 📊 Performance

- **Touch Latency**: <5ms (measured iPad touch to Windows event)
- **Network Latency**: 8-15ms (typical on 5GHz WiFi)
- **Screen Refresh**: 60 FPS @ 1080p
- **Pressure Resolution**: 8192 levels (13-bit)

## 🐛 Troubleshooting

### Connection Issues
- Ensure both devices are on the same network
- Check firewall isn't blocking port 9876
- Try disabling VPN software temporarily

### High Latency
- Use 5GHz WiFi instead of 2.4GHz
- Close bandwidth-intensive apps
- Reduce screen mirroring quality in settings

### Touch Not Detected
- Restart the Windows app with admin privileges
- Check OSU! tablet input mode is enabled
- Recalibrate in settings

## 🗺️ Roadmap

- [ ] v1.0: Initial release with core features
- [ ] v1.1: Android tablet support
- [ ] v1.2: Bluetooth LE connection option
- [ ] v2.0: Cloud settings sync
- [ ] v2.1: Gesture shortcuts
- [ ] v3.0: Multiple device support

## 📄 License

This project is for educational purposes. See LICENSE file for details.

## 🤝 Contributing

While this is a personal project, suggestions and bug reports are welcome! Please open an issue to discuss proposed changes.

## 💬 Support

For questions and support:
- Open an issue on GitHub
- Check the wiki for detailed guides
- Review the PROGRESS.md file for development status

## ⚠️ Disclaimer

This is an unofficial tool not affiliated with OSU! or peppy. Use at your own discretion. Performance may vary based on hardware and network conditions.

---

Made with ❤️ for the OSU! community
